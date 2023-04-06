import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:petfeederapp/adaptive.dart';
import 'package:url_launcher/url_launcher.dart';
import 'notification.dart';
import 'package:provider/provider.dart';
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

          // Theming
          GestureDetector(
            onTap: (() {
              showGeneralDialog(
                context: context,
                pageBuilder: (context, a1, a2) {
                  return Container();
                },
                transitionBuilder: (ctx, a1, a2, child) {
                  var curve = Curves.easeInOut.transform(a1.value);
                  return Transform.scale(
                    scale: curve,
                    child: const ThemePreferences(),
                    // child: Container(),
                  );
                },
                transitionDuration: const Duration(milliseconds: 500),
              ).then((returnedTheme) {
                if (returnedTheme != null) {
                  context
                      .read<ThemeProvider>()
                      .toggleTheme(returnedTheme as String);
                } else {
                  print("User cancelled selecting themes...");
                }
                setState(() {});
              });
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HelpAndSupportPage()));
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

final List<Item> faq = [
  Item(
      header: "What technologies are used to develop this application?",
      body:
          "This application is developed using the Flutter framework and MongoDB as its database. Flutter is an open-source mobile application development framework that allows developers to build natively compiled applications for mobile, web, and desktop from a single codebase. MongoDB is a NoSQL document database that allows developers to store and retrieve data using flexible and dynamic schemas."),
  Item(
      header: "How do I set up a feeding schedule for my pet? (Automatic mode)",
      body:
          "To set up a feeding schedule, navigate to the Homepage tab in the app and select the 'Set Schedule' button. From there, you can add specific schedules that you want your pet to be fed, simply enable/disable said schedules that you want to incorporate, then return back to the Homepage to save your configuration."),
  Item(
      header: "How do I dispense food manually? (Manual mode)",
      body:
          "First make sure you don't have any active schedules set and your mode is on Manual Mode, after which you will see in the Homepage a 'Feed Now' button."),
  Item(
      header: "What is the UV-C light feature and how do I use it?",
      body:
          "The UV-C light feature is a sterilization function that can be used to clean the feeder's bowl. To enable the UV-C light, navigate to the Homepage and click the 'Activate UV Light' button then select the amount of time that you want the light to run for. Please note that this feature should be used sparingly and only when necessary, as prolonged exposure to UV-C light can be harmful to pets and humans."),
  Item(
      header: "How do I view the camera feed from the feeder?",
      body:
          "To view the camera feed, navigate to the 'Camera' tab in the app. The camera will automatically stream a live feed of your pet's feeding area."),
  Item(
      header: "How do I record and play audio through the feeder?",
      body:
          "To record and play audio, navigate to the 'Camera' tab in the app, there exists two action buttons one for recording voice and one for playing specific audio/music. You can record your voice by pressing the 'Speak' button and once you're done you can play it back by stopping the recording instance by pressing 'Stop'. The user can also play any audio file like music as long as it is an MP3 file by pressing the 'Play Music' button, note that the user must provide and select the desired file from your device's storage."),
  Item(
      header: "Can I adjust the amount of food dispensed by the feeder?",
      body:
          "Unfortunately, the feeder does not have a load/weight cell module, so you cannot adjust the amount of food dispensed based on the weight of the food. However, you can adjust the amount of time the dispenser/servo motor is open to control the amount of food dispensed.\n\nTypically, the shortest duration ranging from which is 1-2 seconds will dispense about 5-8 pellets of food, while the 3-5 seconds will dispense more than 10 or so."),
  // Item(
  //     header: "How can I provide feedback about the app?",
  //     body:
  //         "We always welcome feedback from our users! If you have any suggestions for how we can improve the app, or if you encounter any issues while using it, please let us know by sending an email to clevtechcompany@gmail.com, or you can click the 'Request a feature or suggest an idea' button above. We appreciate your input and are committed to making the app as user-friendly as possible.")
  Item(
    header: "How can I provide feedback about the app?",
    richBody: RichText(
      text: TextSpan(
        text:
            "We always welcome feedback from our users! If you have any suggestions for how we can improve the app, or if you encounter any issues while using it, please let us know by sending an email to ",
        // style: DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          TextSpan(
            text: "clevtechcompany@gmail.com",
            style: const TextStyle(
              // color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrl(Uri.parse('mailto:clevtechcompany@gmail.com'));
              },
          ),
          const TextSpan(
            text:
                ", or you can click the 'Request a feature or suggest an idea' button above. We appreciate your input and are committed to making the app as user-friendly as possible.",
          ),
        ],
      ),
    ),
  )
];

class Item {
  final String header;
  final String? body;
  final Widget? richBody;
  bool isExpanded;

  Item(
      {required this.header,
      this.body,
      this.richBody,
      this.isExpanded = false});
}

class HelpAndSupportPage extends StatefulWidget {
  const HelpAndSupportPage({super.key});

  @override
  State<HelpAndSupportPage> createState() => _HelpAndSupportPageState();
}

class _HelpAndSupportPageState extends State<HelpAndSupportPage> {
  @override
  Widget build(BuildContext context) {
    // return const Placeholder();
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Help & Support",
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontFamily: 'Poppins',
                fontSize: getadaptiveTextSize(context, 24),
                fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: Theme.of(context).primaryColor),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "FREQUENTLY ASKED QUESTIONS",
                  style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor,
                    fontSize: getadaptiveTextSize(context, 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).disabledColor.withOpacity(0.2),
                      // color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 1,
                      // offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ExpansionPanelList(
                    dividerColor: Theme.of(context).disabledColor,
                    elevation: 0,
                    expansionCallback: (index, isExpanded) {
                      setState(() {
                        faq[index].isExpanded = !isExpanded;
                      });
                    },
                    children: faq
                        .map((item) => ExpansionPanel(
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              isExpanded: item.isExpanded,
                              canTapOnHeader: true,
                              // value: item.header,
                              headerBuilder: (context, isExpanded) => ListTile(
                                title: Text(
                                  item.header,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize:
                                          getadaptiveTextSize(context, 16)),
                                ),
                              ),
                              body: Padding(
                                padding: const EdgeInsets.only(
                                    top: 0, left: 16, right: 16, bottom: 16),
                                child: item.body == null
                                    ? item.richBody
                                    : Text(item.body as String,
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize:
                                              getadaptiveTextSize(context, 14),
                                        )),
                              ),
                            ))
                        .toList()),
              ),

              /*
              child: ExpansionPanelList(
                  dividerColor: Theme.of(context).disabledColor,
                  elevation: 4,
                  expansionCallback: (index, isExpanded) {
                    setState(() {
                      faq[index].isExpanded = !isExpanded;
                    });
                  },
                  children: faq
                      .map((item) => ExpansionPanel(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            isExpanded: item.isExpanded,
                            canTapOnHeader: true,
                            // value: item.header,
                            headerBuilder: (context, isExpanded) => ListTile(
                              title: Text(
                                item.header,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: getadaptiveTextSize(context, 16)),
                              ),
                            ),
                            body: Padding(
                              padding: const EdgeInsets.only(
                                  top: 0, left: 16, right: 16, bottom: 16),
                              child: Text(item.body,
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: getadaptiveTextSize(context, 14),
                                  )),
                            ),
                          ))
                      .toList()
              ),
              */
            ),
          ],
        ));
  }
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
