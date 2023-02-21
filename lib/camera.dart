import 'dart:convert';

// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:petfeederapp/mqtt.dart';
// import 'package:image/image.dart' as img;

class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  @override
  void initState() {
    super.initState();
    // Subscribe to the needed topic
    // In this case the stream 'client.updates' will only provide the image data
    MQTT.publish("toggle_stream", "on");
    MQTT.client.subscribe("stream", MqttQos.atMostOnce);
  }

  @override
  void dispose() {
    MQTT.client.unsubscribe("stream");
    MQTT.publish("toggle_stream", "off");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey.shade300,
      child: StreamBuilder(
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
            final String base64Image = base64Encode(binaryImageData.codeUnits);
            print(base64Image);
            return Image.memory(
              base64.decode(base64Image),
              gaplessPlayback: true,
            );
            /*
            final decodedImageBytes = Uint8List.fromList(receivedPayload.payload.message);
            img.Image? jpegImage = img.decodeJpg(decodedImageBytes);
            return Image.memory(
              img.encodeJpg(jpegImage!),
              gaplessPlayback: true,
            );
            */
          }
        },
      ),
    );
  }
}
