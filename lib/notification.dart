import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
    await _notifications.initialize(settings);
  }

  //TODO THIS SCHEDULE BACKGROUND NOTIF
  // Future scheduleNotification(
  //     {int id = 0, String? title, String? body, String? payload}) async {
  //   return _notifications.zonedSchedule(
  //       id, title, body, tz.TZDateTime, notificationDetails,
  //       uiLocalNotificationDateInterpretation:
  //           UILocalNotificationDateInterpretation.absoluteTime,
  //       androidAllowWhileIdle: true);
  // }

  static Future show(
      {int id = 0, String? title, String? body, String? payload}) async {
    _notifications.show(id, title, body, await _notificationDetails(),
        payload: payload);
    // FlutterLocalNotificationsPlugin().show(id, title, body, notificationDetails)
  }
}
