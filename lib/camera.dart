import 'dart:convert';
import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:ffmpeg_kit_flutter_audio/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_audio/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_audio/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:petfeederapp/mqtt.dart';
import 'package:uuid/uuid.dart';

import 'music.dart';
import 'preferences.dart';
// import 'package:image/image.dart' as img;

class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  late FlutterSoundRecorder recorder;
  static bool isMusicPlaying = false;
  bool isRecorderReady = false;
  bool isConversionSuccessful = false;

  @override
  void initState() {
    super.initState();
    // Initialize recorder
    initRecorder();
    // Subscribe to the needed topic
    // In this case the stream 'client.updates' will only provide the image data
    if (MQTT.isConnected) {
      MQTT.publish("${UserInfo.productId}/toggle_stream", "on");
      MQTT.client.subscribe("${UserInfo.productId}/stream", MqttQos.atMostOnce);
    }

    if (MQTTPublic.isConnected == false) {
      // MQTTPublic.connectToBroker("${UserInfo.productId}");
      MQTTPublic.connectToBroker("${UserInfo.productId}-${const Uuid().v1()}");
    }
  }

  @override
  void dispose() {
    if (MQTT.isConnected) {
      MQTT.client.unsubscribe("${UserInfo.productId}/stream");
      MQTT.publish("${UserInfo.productId}/toggle_stream", "off");
    }
    recorder.closeRecorder();
    // recorder.closeAudioSession();
    super.dispose();
  }

  Future initRecorder() async {
    setState(() {
      recorder = FlutterSoundRecorder();
    });
    await recorder.openRecorder();
    isRecorderReady = true;
  }

  Future record() async {
    if (!isRecorderReady) return;
    // Record audio in aac format, then convert to mp3 afterwards...
    await recorder.startRecorder(
        toFile: 'voice.aac',
        codec: Codec.aacADTS,
        numChannels: 2,
        bitRate: 128000);
  }

  // Function to convert aac format into mp3
  void convertAACtoMP3(String inputFilePath, String outputFilePath) {
    /* FFmpeg command starts with '-y' for overwrite, '-i' for input file (next argument)'-b:a' for bitrate
       and '-ar' for sample rate, then for the last argument the output file path */
    String ffmpegCommand =
        "-y -i $inputFilePath -b:a 128k -ar 44100 $outputFilePath";

    FFmpegKit.execute(ffmpegCommand).then((session) async {
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        print("Conversion successful");
        isConversionSuccessful = true;

        if (isConversionSuccessful) {
          // Once done, we will send in the audio url
          if (MQTTPublic.isConnected) {
            String? serverIp = await NetworkInfo().getWifiIP(); // Get local ip
            String? audioURL = "http://$serverIp:8080/voice.mp3";
            print(audioURL);
            MQTTPublic.publish(
                "${UserInfo.productId}/${UserInfo.devicePassword}/audio",
                audioURL);
            // Once successful and done we reset the flag
            isConversionSuccessful = false;
          }
        }

        // return;
      } else if (ReturnCode.isCancel(returnCode)) {
        print("Conversion cancelled");
        isConversionSuccessful = false;
        // return;
      } else {
        print("Conversion failed");
        isConversionSuccessful = false;
        // return;
      }
    });
  }

  Future stop() async {
    if (!isRecorderReady) return;

    final Directory cacheDirectory = await getTemporaryDirectory();
    final path = await recorder.stopRecorder();
    final audioFile = File(path!);
    print("Recorded audio is at: $audioFile, converting to mp3 now...");
    convertAACtoMP3(audioFile.path, "${cacheDirectory.path}/voice.mp3");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blueGrey.shade300,
        body: StreamBuilder(
          stream: MQTT.client.updates,
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            } else {
              final receivedPayload =
                  snapshot.data![0].payload as MqttPublishMessage;

              final String binaryImageData =
                  MqttPublishPayload.bytesToStringAsString(
                      receivedPayload.payload.message);
              final String base64Image =
                  base64Encode(binaryImageData.codeUnits);
              return Column(
                children: [
                  Expanded(
                    child: Image.memory(
                      base64.decode(base64Image),
                      gaplessPlayback: true,
                      fit: BoxFit.cover, // adjust the fit property as needed
                    ),
                  ),
                ],
              );
            }
          },
        ),
        // PLAY MUSIC BUTTON
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            FloatingActionButton.extended(
                heroTag: "musicBtn",
                backgroundColor: isMusicPlaying
                    ? const Color.fromARGB(200, 33, 31, 103)
                    : Colors.blueGrey.shade400,
                onPressed: recorder.isRecording == true
                    ? null
                    : () {
                        if (isMusicPlaying) {
                          if (MQTTPublic.isConnected) {
                            MQTTPublic.publish(
                                "${UserInfo.productId}/${UserInfo.devicePassword}/audio",
                                "stop");
                            // Once successful and done we reset the flag
                            print("stopping the music!");
                            setState(() {
                              isMusicPlaying = false;
                            });
                          }
                        } else {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const MusicPage()))
                              .then((status) {
                            // // Simply update page after exiting the page
                            setState(() {
                              isMusicPlaying = status;
                            });
                          });
                        }
                      },
                label:
                    isMusicPlaying ? const Text("Stop") : const Text("Music"),
                icon: Icon(
                  isMusicPlaying
                      ? Icons.music_off_rounded
                      : Icons.music_note_rounded,
                  size: 32,
                )),
            Expanded(child: Container()),
            // SPEAK BUTTON
            FloatingActionButton.extended(
                heroTag: "speakBtn",
                backgroundColor: recorder.isRecording
                    ? const Color.fromARGB(200, 33, 31, 103)
                    : Colors.blueGrey.shade400,
                onPressed: isMusicPlaying
                    ? null
                    : () async {
                        if (recorder.isRecording) {
                          await stop();
                        } else {
                          await record();
                        }
                        setState(() {});
                      },
                label: recorder.isRecording ? Text("Stop") : Text("Speak"),
                icon: Icon(
                  recorder.isRecording ? Icons.stop : Icons.mic,
                  size: 32,
                )),
          ]),
        ));
  }
}
