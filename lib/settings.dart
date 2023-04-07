import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:petfeederapp/adaptive.dart';
import 'package:petfeederapp/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'notification.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'preferences.dart';
import 'service.dart';
import 'theme.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String _sharedPrefsData = "";
  String? wifiName = "";
  String? localIP = "";
  bool serviceStatus = UserInfo.isNotificationsEnabled ?? false;
  Future<void> _getSharedPrefsData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    String data = '';
    for (var key in keys) {
      data += "$key : ${prefs.get(key)}\n";
    }

    final info = NetworkInfo();
    var temp = await info.getWifiName();
    wifiName = temp?.substring(1, temp.length - 1);

    // var wifiName = temp?.substring(1, temp.length - 1);
    print(wifiName);
    localIP = await info.getWifiIP(); // Get local ip
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
          Container(
              padding: EdgeInsets.only(bottom: getadaptiveTextSize(context, 8)),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              height: getadaptiveTextSize(context, 96),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Theme.of(context).secondaryHeaderColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: ListTile(
                leading: Icon(
                  (UserInfo.isAppConnectedToWiFi == ConnectivityResult.none ||
                          UserInfo.isAppConnectedToWiFi == null)
                      ? Icons.wifi_off_rounded
                      : Icons.wifi_rounded,
                  size: getadaptiveTextSize(context, 64),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                title: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        text: 'SSID: ',
                        style: TextStyle(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            fontWeight: FontWeight.w600,
                            fontSize: getadaptiveTextSize(context, 18)),
                        children: [
                          TextSpan(
                            text: (UserInfo.isAppConnectedToWiFi ==
                                        ConnectivityResult.none ||
                                    UserInfo.isAppConnectedToWiFi == null)
                                ? "None"
                                : wifiName,
                            style: TextStyle(
                                fontSize: getadaptiveTextSize(context, 16),
                                fontWeight: FontWeight.w300,
                                color: (UserInfo.isAppConnectedToWiFi ==
                                            ConnectivityResult.none ||
                                        UserInfo.isAppConnectedToWiFi == null)
                                    ? Theme.of(context).disabledColor
                                    : Theme.of(context)
                                        .scaffoldBackgroundColor),
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: 'Status: ',
                        style: TextStyle(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            fontWeight: FontWeight.w600,
                            fontSize: getadaptiveTextSize(context, 18)),
                        children: [
                          TextSpan(
                            text: (UserInfo.isAppConnectedToWiFi ==
                                        ConnectivityResult.none ||
                                    UserInfo.isAppConnectedToWiFi == null)
                                ? "Offline"
                                : "Online",
                            style: TextStyle(
                                fontSize: getadaptiveTextSize(context, 16),
                                fontWeight: FontWeight.w300,
                                color: (UserInfo.isAppConnectedToWiFi ==
                                            ConnectivityResult.none ||
                                        UserInfo.isAppConnectedToWiFi == null)
                                    ? const Color.fromARGB(255, 255, 69, 0)
                                    : const Color.fromARGB(255, 0, 150, 136)),
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: 'Local IP: ',
                        style: TextStyle(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            fontWeight: FontWeight.w600,
                            fontSize: getadaptiveTextSize(context, 18)),
                        children: [
                          TextSpan(
                              text: (UserInfo.isAppConnectedToWiFi ==
                                          ConnectivityResult.none ||
                                      UserInfo.isAppConnectedToWiFi == null)
                                  ? "0.0.0.0"
                                  : localIP,
                              style: TextStyle(
                                  fontSize: getadaptiveTextSize(context, 16),
                                  fontWeight: FontWeight.w300,
                                  color: (UserInfo.isAppConnectedToWiFi ==
                                              ConnectivityResult.none ||
                                          UserInfo.isAppConnectedToWiFi == null)
                                      ? Theme.of(context).disabledColor
                                      : Theme.of(context)
                                          .scaffoldBackgroundColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
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
              print("Clicked on themes and accent");
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
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
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
              print("Clicked on help and support");
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HelpAndSupportPage()));
            }),
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
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
              print("Clicked on About us");
              showGeneralDialog(
                barrierDismissible: true, // this makes the dialog dismissible
                barrierLabel:
                    MaterialLocalizations.of(context).modalBarrierDismissLabel,
                context: context,
                pageBuilder: (context, a1, a2) {
                  return Container();
                },
                transitionBuilder: (ctx, a1, a2, child) {
                  var curve = Curves.easeInOut.transform(a1.value);
                  return Transform.scale(
                    scale: curve,
                    child: const AboutUsPage(),
                  );
                },
                transitionDuration: const Duration(milliseconds: 500),
              );
            }),
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
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
  Item(
      header: "What is the recommended dog/cat food size for the feeder",
      body:
          "The feeder is designed to handle dry dog/cat food that is smaller than 1.5cm (0.6 inches) in diameter. It is important to use food that is within this size range to ensure that the feeder functions properly and does not become clogged or jammed.The feeder is designed to handle dry dog/cat food that is smaller than 1.5cm (0.6 inches) in diameter. It is important to use food that is within this size range to ensure that the feeder functions properly and does not become clogged or jammed."),
  Item(
      header: "How can I provide feedback about the app?",
      richBody: (BuildContext context) {
        return RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyText1,
            // style: const TextStyle(fontWeight: FontWeight.w300),
            text:
                "If you have any suggestions for the app, or if you encounter any issues while using it, please let us know by sending us an email to ",
            children: <TextSpan>[
              TextSpan(
                text: "clevtechcompany@gmail.com",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).secondaryHeaderColor,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchUrl(Uri.parse('mailto:clevtechcompany@gmail.com'),
                        mode: LaunchMode.externalApplication);
                  },
              ),
              const TextSpan(
                text:
                    ", or you can click the button above. We appreciate your input and are committed to making the app as user-friendly as possible.",
              ),
            ],
          ),
        );
      }),
  Item(
      header: "What should I do if I experience a bug in the app?",
      richBody: (BuildContext context) {
        return RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyText1,
            text:
                "If you encounter a bug while using the app, please report it to us by sending an email to our support team at ",
            children: <TextSpan>[
              TextSpan(
                text: "clevtechcompany@gmail.com",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).secondaryHeaderColor,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchUrl(Uri.parse('mailto:clevtechcompany@gmail.com'),
                        mode: LaunchMode.externalApplication);
                  },
              ),
              const TextSpan(
                text:
                    " in your email, please include a detailed description of the bug, along with any error messages that you may have seen. Alternatively, you can click the button above ",
              ),
            ],
          ),
        );
      }),
];

class Item {
  final String header;
  final String? body;
  final Function? richBody;
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
            const SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                launchUrl(
                    Uri.parse(
                        'https://github.com/Thanatoslayer6/petfeederapp/'),
                    mode: LaunchMode.externalApplication);
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: ListTile(
                  leading: Icon(
                    Icons.code_rounded,
                    size: 32,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    "GitHub",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).secondaryHeaderColor,
                        fontSize: getadaptiveTextSize(context, 18)),
                  ),
                  subtitle: Text(
                    "View the source code",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                launchUrl(
                    Uri.parse(
                        'https://github.com/Thanatoslayer6/petfeederapp/issues/new'),
                    mode: LaunchMode.externalApplication);
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: ListTile(
                  leading: Icon(
                    Icons.report_rounded,
                    size: 32,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    "Report an issue/Suggest an idea",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).secondaryHeaderColor,
                        fontSize: getadaptiveTextSize(context, 18)),
                  ),
                  subtitle: Text(
                    "You will be redirected to GitHub's issue section",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Frequently Asked Questions/FAQs",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Theme.of(context).secondaryHeaderColor,
                    fontSize: getadaptiveTextSize(context, 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
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
                                headerBuilder: (context, isExpanded) =>
                                    ListTile(
                                  title: Text(
                                    item.header,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize:
                                            getadaptiveTextSize(context, 16)),
                                  ),
                                ),
                                body: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 0, left: 16, right: 16, bottom: 16),
                                  child: item.body == null
                                      ? item.richBody!(context)
                                      : Text(item.body as String,
                                          textAlign: TextAlign.justify,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: getadaptiveTextSize(
                                                context, 14),
                                          )),
                                ),
                              ))
                          .toList()),
                ),
              ),
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

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  // String version = "Unknown";

  PackageInfo package = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((value) => {
          setState(() {
            package = value;
            print(
                "${package.appName} - ${package.version} - ${package.buildNumber}");
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          SvgPicture.asset('assets/images/logo.svg',
              semanticsLabel: 'ClevTech Logo',
              color: Theme.of(context).secondaryHeaderColor,
              width: 128,
              height: 128),
          const SizedBox(
            width: 16,
          ),
          Column(
            children: [
              Text(
                package.appName,
                style: TextStyle(
                    fontSize: getadaptiveTextSize(context, 20),
                    color: Theme.of(context).secondaryHeaderColor),
              ),
              Text(
                package.version,
                // UserInfo.package.version,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ],
          )
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(
              Icons.person,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text(
              'Follow the Author',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              print("Tapped on authors");
              launchUrl(Uri.parse('https://github.com/Thanatoslayer6'),
                  mode: LaunchMode.externalApplication);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.facebook_rounded,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text(
              'Like us on Facebook',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              print("Tapped on facebook");
              launchUrl(Uri.parse('https://facebook.com/ClevTechPH'),
                  mode: LaunchMode.externalApplication);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.star,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text(
              'Star us on GitHub',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              launchUrl(
                  Uri.parse('https://github.com/Thanatoslayer6/petfeederapp'),
                  mode: LaunchMode.externalApplication);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.copyright_outlined,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text(
              'Licenses',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              launchUrl(
                  Uri.parse(
                      'https://github.com/Thanatoslayer6/petfeederapp/blob/main/LICENSE'),
                  mode: LaunchMode.externalApplication);
            },
          )
        ],
      ),
    );
  }
}
