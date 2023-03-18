import 'dart:convert';
import 'dart:io';

// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:petfeederapp/mqtt.dart';

import 'preferences.dart';
// import 'package:image/image.dart' as img;

class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  late FlutterSoundRecorder recorder;
  bool isRecorderReady = false;
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
  }

  @override
  void dispose() {
    if (MQTT.isConnected) {
      MQTT.client.unsubscribe("${UserInfo.productId}/stream");
      MQTT.publish("${UserInfo.productId}/toggle_stream", "off");
    }
    recorder.closeRecorder();
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

    await recorder.startRecorder(toFile: 'voice.mp3');
  }

  Future stop() async {
    if (!isRecorderReady) return;

    final path = await recorder.stopRecorder();
    final audioFile = File(path!);
    print("Recorded audio is at: $audioFile");
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
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
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
            )));
  }
}
