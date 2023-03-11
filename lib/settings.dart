import 'package:flutter/material.dart';
import 'package:petfeederapp/time.dart';
import 'notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
/* import 'package:timezone/timezone.dart' as tz; */
/* import 'package:timezone/data/latest.dart' as tz; */

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String _sharedPrefsData = "";
  Future<void> _getSharedPrefsData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    String data = '';
    for (var key in keys) {
      data += "$key : ${prefs.get(key)}\n";
    }
    setState(() {
      _sharedPrefsData = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _getSharedPrefsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(_sharedPrefsData),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              // Perform any other actions you need after clearing shared preferences
            },
            child: const Text('Clear Data'),
          ),
          ElevatedButton(
            onPressed: () async {
              NotificationAPI.show(title: "Hello World", body: "What's up?");
              // var scheduledTime = DateTimeService.getDateWithHourAndMinuteSet(,);
              // NotificationAPI.scheduleNotification(title: "This is scheduled", body: "Successfully feeded pet!", timeToShow: scheduledTime);
              // final prefs = await SharedPreferences.getInstance();
              // await prefs.clear();
              // Perform any other actions you need after clearing shared preferences
            },
            child: const Text('Notify'),
          )
        ],
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     child: Text(data),
  //     color: Colors.lightBlue[300],
  //   );
  // }
}
