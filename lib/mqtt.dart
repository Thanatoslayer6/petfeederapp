import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';

class MQTT {
  static MqttServerClient client =
      MqttServerClient(dotenv.env['MQTT_SERVER']!, '');
  static bool isConnected = false;
  static String clientId = "ESP32-${const Uuid().v4()}";

  static connectToBroker() async {
    print("Connecting to MQTT Broker");
    ByteData rootCA = await rootBundle.load('assets/certs/RootCA.pem');
    SecurityContext context = SecurityContext.defaultContext;
    context.setClientAuthoritiesBytes(rootCA.buffer.asUint8List());
    client.setProtocolV311();
    client.securityContext = context;
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.port = 8883;
    client.secure = true;
    // Authenticate with username and password, also use the generated clientid
    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .authenticateAs(dotenv.env['MQTT_USER'], dotenv.env['MQTT_PASS']);
    client.connectionMessage = connMess;

    await client.connect();

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print("Connected to HiveMQ MQTT Broker successfully!");
      isConnected = true;
    } else {
      print("Failed to HiveMQ MQTT Broker!");
      return false;
    }
    return true;
  }

  static void publish(String topic, String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }
}
