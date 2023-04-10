import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTT {
  static MqttServerClient client =
      MqttServerClient(dotenv.env['MQTT_SERVER0']!, '');
  static bool isConnected = false;
  // static String clientId = "ESP32-${const Uuid().v4()}";
  static String? productId;

  static connectToBroker(String? id) async {
    productId = id ?? "UnknownClientUser"; // Assign productId
    log("Connecting to Private MQTT Broker using id: $productId");
    ByteData letsEncryptCA =
        await rootBundle.load('assets/certs/lets-encrypt-r3.pem');
    SecurityContext context = SecurityContext.defaultContext;
    context.setTrustedCertificatesBytes(letsEncryptCA.buffer.asUint8List());
    client.setProtocolV311();
    client.securityContext = context;
    client.logging(on: false);
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onAutoReconnect = onAutoReconnect;
    client.onAutoReconnected = onAutoReconnected;
    client.autoReconnect = true;
    client.keepAlivePeriod = 20;
    client.port = 8883;
    client.secure = true;
    // Authenticate with username and password, also use the generated clientid
    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(productId as String)
        .startClean()
        .authenticateAs(dotenv.env['MQTT_USER'], dotenv.env['MQTT_PASS']);
    client.connectionMessage = connMess;
    try {
      await client.connect();
    } catch (e) {
      log("Service cannot connect to MQTT Broker - $e");
    }
  }

  static void publish(String topic, String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    if (MQTT.isConnected) {
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    }
    return;
  }

  /// The successful connect callback
  static void onConnected() {
    log("Connected to Private HiveMQ MQTT Broker successfully!");
    isConnected = true;
  }

  /// The unsolicited disconnect callback
  static void onDisconnected() {
    log('EXAMPLE::OnDisconnected client callback - Client disconnection from private broker');
    isConnected = false;
    if (client.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      log('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    } else {
      log('EXAMPLE::OnDisconnected callback is unsolicited or none, this is incorrect - exiting');
      exit(-1);
    }
  }

  /// The pre auto re connect callback
  static void onAutoReconnect() {
    log('EXAMPLE::onAutoReconnect client callback - Client auto reconnection sequence will start');
  }

  /// The post auto re connect callback
  static void onAutoReconnected() {
    log('EXAMPLE::onAutoReconnected client callback - Client auto reconnection sequence has completed');
  }
}

class MQTTPublic {
  static MqttServerClient client =
      MqttServerClient(dotenv.env['MQTT_SERVER1']!, '');
  static bool isConnected = false;
  static String? productId;

  static connectToBroker(String? id) async {
    productId = id ?? "UnknownClientUser"; // Assign productId
    log("Connecting to Public MQTT Broker using id: $productId");
    // ByteData letsEncryptCA =
    //     await rootBundle.load('assets/certs/lets-encrypt-r3.pem');
    // SecurityContext context = SecurityContext.defaultContext;
    // context.setTrustedCertificatesBytes(letsEncryptCA.buffer.asUint8List());
    client.setProtocolV311();
    // client.securityContext = context;
    client.logging(on: false);
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onAutoReconnect = onAutoReconnect;
    client.onAutoReconnected = onAutoReconnected;
    client.autoReconnect = true;
    client.keepAlivePeriod = 20;
    client.port = 1883;
    // client.secure = true;
    // Authenticate with username and password, also use the generated clientid
    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(productId as String)
        .startClean();
    // .authenticateAs(dotenv.env['MQTT_USER'], dotenv.env['MQTT_PASS']);
    client.connectionMessage = connMess;

    await client.connect();
  }

  static void publish(String topic, String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    if (MQTT.isConnected) {
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    }
    return;
  }

  /// The successful connect callback
  static void onConnected() {
    log("Connected to Public HiveMQ MQTT Broker successfully!");
    isConnected = true;
  }

  /// The unsolicited disconnect callback
  static void onDisconnected() {
    log('EXAMPLE::OnDisconnected client callback - Client disconnection from public broker');
    isConnected = false;
    if (client.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      log('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    } else {
      log('EXAMPLE::OnDisconnected callback is unsolicited or none, this is incorrect - exiting');
      exit(-1);
    }
  }

  /// The pre auto re connect callback
  static void onAutoReconnect() {
    log('EXAMPLE::onAutoReconnect client callback - Client auto reconnection sequence will start');
  }

  /// The post auto re connect callback
  static void onAutoReconnected() {
    log('EXAMPLE::onAutoReconnected client callback - Client auto reconnection sequence has completed');
  }
}
