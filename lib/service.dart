import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'mqtt.dart';
import 'notification.dart';
import 'preferences.dart';

Future<void> initService() async {
  // if (MQTT.isConnected) {
  //   print("MQTT is already connected");
  //   MQTT.client
  //       .subscribe("${UserInfo.productId}/notifications", MqttQos.atMostOnce);

  //   StreamSubscription subscription =
  //       MQTT.client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
  //     final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
  //     final String message =
  //         MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

  //     if (c[0].topic == "${UserInfo.productId}/notifications" &&
  //         message == "feed-success") {
  //       NotificationAPI.show(title: "Feeding log", body: "Success!");
  //     } else if (c[0].topic == "${UserInfo.productId}/notifications" &&
  //         message == "uv-success") {
  //     } else if (c[0].topic == "${UserInfo.productId}/notifications" &&
  //         message == "feed-fail") {
  //     } else if (c[0].topic == "${UserInfo.productId}/notifications" &&
  //         message == "uv-fail") {}
  //   });
  // } else {
  //   print("Not connected so first we connect... implement below");
  // }
  final service = FlutterBackgroundService();
  await service.configure(
      iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration(
          onStart: onStart,
          isForegroundMode: true,
          autoStart: true,
          autoStartOnBoot: true));
  await service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // TODO: Literally use another thread with dotenv but different name.... connect to broker then check for stuff
  DartPluginRegistrant.ensureInitialized();
  // if (isConnectedToMQTT == false) {
  //   print("Reconnecting to MQTT Client");
  //   // MQTT.connectToBroker("${UserInfo.productId}-notifications");
  //   MQTT.connectToBroker("${UserInfo.productId}-notif-${const Uuid().v1()}");
  // } else {
  //   print("Subscribing to topics here maybe?");
  // }
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });

    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  }

  // TODO: Ios?
  Timer.periodic(const Duration(seconds: 2), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
            title: "Waiting for next schedule",
            content: "Updated at ${DateTime.now()}");
        print("I'm running in the foreground...");
      } else {
        print("I'm running in the background...");
      }
    }
  });
}
