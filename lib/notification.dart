import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationAPI {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future _notificationDetails() async {
    return const NotificationDetails(
        android: AndroidNotificationDetails("Channel ID", "Channel Name",
            importance: Importance.max),
        iOS: DarwinNotificationDetails());
  }

  static Future init({bool initScheduled = false}) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const IOS = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: IOS);
    await _notifications.initialize(settings,
        onDidReceiveNotificationResponse: (payload) async {
      print("You clicked on the notification");
    });
  }

  static Future scheduleNotification(
      {int id = 0,
      String? title,
      String? body,
      String? payload,
      required DateTime timeToShow}) async {
    tz.initializeTimeZones();
    return await _notifications.zonedSchedule(id, title, body,
        tz.TZDateTime.from(timeToShow, tz.local), await _notificationDetails(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  static Future show(
      {int id = 0, String? title, String? body, String? payload}) async {
    _notifications.show(id, title, body, await _notificationDetails(),
        payload: payload);
    // FlutterLocalNotificationsPlugin().show(id, title, body, notificationDetails)
  }
}
