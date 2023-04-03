import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:petfeederapp/adaptive.dart';
import 'notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'preferences.dart';
import 'service.dart';
import 'theme.dart';
/* import 'package:timezone/timezone.dart' as tz; */
/* import 'package:timezone/data/latest.dart' as tz; */

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String _sharedPrefsData = "";
  bool serviceStatus = UserInfo.isNotificationsEnabled ?? false;
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
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
          // ElevatedButton(
          //   onPressed: () {
          //     NotificationAPI.show(title: "Hello World", body: "What's up?");
          //   },
          //   child: const Text('Notify'),
          // ),
          // NOTIFICATIONS
          Row(
            children: [
              Expanded(
                flex: 1,
                child: NotificationWidget(context),
              ),
              Expanded(
                  flex: 0,
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: Switch(
                        // activeColor: Theme.of(context).primaryColor,

                        // thumbColor: Theme.of(context).secondaryHeaderColor,
                        // activeColor: Theme.of(context).secondaryHeaderColor,
                        // activeTrackColor: Theme.of(context).primaryColor,
                        // activeColor: Theme.of(context).secondaryHeaderColor,
                        // inactiveThumbColor: Theme.of(context).primaryColor,
                        inactiveTrackColor:
                            Theme.of(context).secondaryHeaderColor,
                        value: serviceStatus,
                        onChanged: (value) async {
                          if (value) {
                            print("Enabling notifications...");
                            await BackgroundTask().initService();
                            UserInfo.preferences
                                .setBool('isNotificationsEnabled', true);
                            BackgroundTask.service.invoke('setAsForeground');
                          } else {
                            UserInfo.preferences
                                .setBool('isNotificationsEnabled', false);
                            BackgroundTask.service.invoke('stopService');
                          }
                          setState(() {
                            UserInfo.isNotificationsEnabled = value;
                            serviceStatus = value;
                          });
                        }),
                  ))
            ],
          ),
          Container(
            margin: const EdgeInsets.all(16),
            child: Divider(
              height: 0,
              thickness: 1,
              color: Theme.of(context).disabledColor,
              indent: 8,
              endIndent: 8,
            ),
          ),

          // Dark mode... theming
          GestureDetector(
            onTap: (() {
              // showGeneralDialog(
              //   context: context,
              //   pageBuilder: (context, a1, a2) {
              //     return Container();
              //   },
              //   transitionBuilder: (ctx, a1, a2, child) {
              //     var curve = Curves.easeInOut.transform(a1.value);
              //     return Transform.scale(
              //       scale: curve,
              //       child: const ThemePreferences(),
              //     );
              //   },
              //   transitionDuration: const Duration(milliseconds: 500),
              // ).then((_) => setState(() {}));
            }),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ThemeCustomizationWidget(context),
                ),
                Expanded(
                    flex: 0,
                    child: Container(
                        margin: const EdgeInsets.only(right: 16),
                        child: Icon(
                          Icons.keyboard_arrow_right_rounded,
                          color: Theme.of(context).primaryColor,
                          size: 32,
                        )))
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.all(16),
            child: Divider(
              height: 0,
              thickness: 1,
              color: Theme.of(context).disabledColor,
              indent: 8,
              endIndent: 8,
            ),
          ),

          // Help and support
          GestureDetector(
            onTap: (() {
              print("tapped on support");
            }),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: HelpAndSupportWidget(context),
                ),
                Expanded(
                    flex: 0,
                    child: Container(
                        margin: const EdgeInsets.only(right: 16),
                        child: Icon(
                          Icons.keyboard_arrow_right_rounded,
                          color: Theme.of(context).primaryColor,
                          size: 32,
                        )))
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.all(16),
            child: Divider(
              height: 0,
              thickness: 1,
              // color: Color.fromARGB(70, 111, 111, 111),

              color: Theme.of(context).disabledColor,
              indent: 8,
              endIndent: 8,
            ),
          ),

          // About us
          GestureDetector(
            onTap: (() {
              print("tapped on about us");
            }),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: AboutUsWidget(context),
                ),
                Expanded(
                    flex: 0,
                    child: Container(
                        margin: const EdgeInsets.only(right: 16),
                        child: Icon(
                          Icons.keyboard_arrow_right_rounded,
                          color: Theme.of(context).primaryColor,
                          size: 32,
                        )))
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.all(16),
            child: Divider(
              height: 0,
              thickness: 1,
              color: Theme.of(context).disabledColor,
              // color: Color.fromARGB(70, 111, 111, 111),
              indent: 8,
              endIndent: 8,
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: non_constant_identifier_names
Widget NotificationWidget(BuildContext context) {
  return Row(
    children: [
      Container(
        margin: const EdgeInsets.only(right: 16, left: 16),
        child: Icon(
          Icons.notifications_none_rounded,
          color: Theme.of(context).primaryColor,
          size: 48,
        ),
      ),
      Text(
        "Notifications",
        style: TextStyle(fontSize: getadaptiveTextSize(context, 22)),
      )
    ],
  );
}

// ignore: non_constant_identifier_names
Widget ThemeCustomizationWidget(BuildContext context) {
  return Row(
    children: [
      Container(
        margin: const EdgeInsets.only(right: 16, left: 16),
        child: Icon(
          Icons.palette_outlined,
          color: Theme.of(context).primaryColor,
          size: 48,
        ),
      ),
      Text(
        "Themes/Accent",
        style: TextStyle(fontSize: getadaptiveTextSize(context, 22)),
      )
    ],
  );
}

// ignore: non_constant_identifier_names
Widget HelpAndSupportWidget(BuildContext context) {
  return Row(
    children: [
      Container(
        margin: const EdgeInsets.only(right: 16, left: 16),
        child: Icon(
          Icons.contact_support_outlined,
          color: Theme.of(context).primaryColor,
          size: 48,
        ),
      ),
      Text(
        "Help & Support",
        style: TextStyle(fontSize: getadaptiveTextSize(context, 22)),
      )
    ],
  );
}

// ignore: non_constant_identifier_names
Widget AboutUsWidget(BuildContext context) {
  return Row(
    children: [
      Container(
        margin: const EdgeInsets.only(right: 16, left: 16),
        child: Icon(
          Icons.info_outline_rounded,
          color: Theme.of(context).primaryColor,
          size: 48,
        ),
      ),
      Text(
        "About us",
        style: TextStyle(fontSize: getadaptiveTextSize(context, 22)),
      )
    ],
  );
}
