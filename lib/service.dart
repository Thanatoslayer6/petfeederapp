import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
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
  // Set up a boolean variable to know if the service is subscribed
  bool isAlreadySubscribedToTopic = false;
  // Probably use shared preferences and dotenv to connect...
  await dotenv.load(fileName: "assets/.env");
  // SharedPreferences config = SharedPreferences;
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String productId = preferences.getString('productId') ?? "Demo";
  print("The product ID is: $productId");
  if (!MQTT.isConnected) {
    print("Connecting/Reconnecting to MQTT Client");
    // Just connect to the broker with any name for now, since this is a separate thread
    MQTT.connectToBroker("$productId-notif-${const Uuid().v1()}");
    MQTT.isConnected = true;
  }

  if (!isAlreadySubscribedToTopic) {
    // Subscribe to the topic
    print("Subscribing service to necessary topic");
    MQTT.client.subscribe("$productId/notifications", MqttQos.atMostOnce);
    isAlreadySubscribedToTopic = true;
  }

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

  Timer.periodic(const Duration(seconds: 2), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
            title: "Waiting for next schedule",
            content: "Updated at ${DateTime.now()}");
        print("I'm running in the foreground...");

        if (MQTT.isConnected) {
          print("MQTT is already connected");
          if (!isAlreadySubscribedToTopic) {
            MQTT.client
                .subscribe("$productId/notifications", MqttQos.atMostOnce);
            isAlreadySubscribedToTopic = true;
          } else {}
          // Start listening
          MQTT.client.updates!
              .listen((List<MqttReceivedMessage<MqttMessage>> c) {
            final MqttPublishMessage recMess =
                c[0].payload as MqttPublishMessage;
            final String message = MqttPublishPayload.bytesToStringAsString(
                recMess.payload.message);

            if (c[0].topic == "$productId/notifications" &&
                message == "feed-success") {
              NotificationAPI.show(title: "Feeding log", body: "Success!");
            } else if (c[0].topic == "$productId/notifications" &&
                message == "uv-success") {
            } else if (c[0].topic == "$productId/notifications" &&
                message == "feed-fail") {
            } else if (c[0].topic == "$productId/notifications" &&
                message == "uv-fail") {}
          });
        } else {
          print("Not connected so first we connect... implement logic below");
        }
      } else {
        print("I'm running in the background...");
      }
    }
  });
}
