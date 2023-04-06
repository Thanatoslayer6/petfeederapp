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
import 'time.dart';

class BackgroundTask {
  static final service = FlutterBackgroundService();
  Future<void> initService() async {
    // final service = FlutterBackgroundService();
    await service.configure(
        iosConfiguration: IosConfiguration(),
        androidConfiguration: AndroidConfiguration(
            onStart: onStart,
            isForegroundMode: true,
            initialNotificationTitle: "Notification Service",
            autoStart: true,
            autoStartOnBoot: true));
    await service.startService();
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  // Probably use shared preferences and dotenv to connect...
  await dotenv.load(fileName: "assets/.env");
  // SharedPreferences config = SharedPreferences;
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String productId = preferences.getString('productId') as String;
  print("The product ID is: $productId");
  if (!MQTT.isConnected) {
    print("Connecting/Reconnecting to MQTT Client");
    // Just connect to the broker with any name for now, since this is a separate thread
    await MQTT.connectToBroker("$productId-notification-${const Uuid().v1()}");
    // Subscribe to the topic
    print("Subscribing service to necessary topic $productId/notifications");
    try {
      MQTT.client.subscribe("$productId/notifications", MqttQos.atMostOnce);
    } catch (e) {
      print("MQTT Service cannot subscribe to notifications topic - $e");
    }
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

  Timer.periodic(const Duration(seconds: 10), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
            title: "Notification Service",
            content: "Waiting for the next schedule...");

        if (MQTT.isConnected) {
          // Start listening
          MQTT.client.updates!
              .listen((List<MqttReceivedMessage<MqttMessage>> c) {
            final MqttPublishMessage recMess =
                c[0].payload as MqttPublishMessage;
            final String message = MqttPublishPayload.bytesToStringAsString(
                recMess.payload.message);

            if (c[0].topic == "$productId/notifications" &&
                message == "feed-success") {
              NotificationAPI.show(
                  title:
                      "Feed | ${DateTimeService.getCurrentDateTimeFormatted()}",
                  body: "Successful task!");
            } else if (c[0].topic == "$productId/notifications" &&
                message == "uv-success") {
              NotificationAPI.show(
                  title:
                      "UV-Light | ${DateTimeService.getCurrentDateTimeFormatted()}",
                  body: "Successful task!");
            } else if (c[0].topic == "$productId/notifications" &&
                message == "feed-fail") {
              // NotificationAPI.show(title: "Feeding log", body: "Failed!");

              NotificationAPI.show(
                  title:
                      "Feed | ${DateTimeService.getCurrentDateTimeFormatted()}",
                  body: "Failed task!");
            } else if (c[0].topic == "$productId/notifications" &&
                message == "uv-fail") {
              // NotificationAPI.show(title: "UV-Light log", body: "Failed!");

              NotificationAPI.show(
                  title:
                      "UV-Light | ${DateTimeService.getCurrentDateTimeFormatted()}",
                  body: "Failed task!");
            }
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
