// import 'dart:io';

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:petfeederapp/camera.dart';
import 'package:petfeederapp/settings.dart';
import 'package:flutter/services.dart';
import 'package:petfeederapp/start.dart';
import 'adaptive.dart';
import 'preferences.dart';
import 'navigation.dart';
import 'titlebar.dart';
import 'homepage.dart';
import 'time.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Force portrait mode
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Don't show status bar, only show bottom bar if possible
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    SystemUiOverlay.bottom, //This line is used for showing the bottom bar
  ]);

  // Start time
  DateTimeService.init();
  // Load environment variables
  await dotenv.load(fileName: "assets/.env");
  // Get random identifier if user is just starting up...
  // Then call runApp() as normal
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  UserInfo app = UserInfo();
  // This method will be used for updating user status
  void updateUserStatus(bool status) {
    UserInfo.isUserNew = status;
    app.preferences.setBool('isUserNew', status);
    app.preferences.setString('productId', UserInfo.productId as String);
    app.preferences
        .setString('devicePassword', UserInfo.devicePassword as String);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    app.getStoredData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: Connectivity().onConnectivityChanged,
        builder: ((context, snapshot) {
          final result = snapshot.data;
          if (UserInfo.isUserNew == true) {
            return StartScreen(
                result: result, updateUserStatus: updateUserStatus);
          } else {
            if (result == ConnectivityResult.none || result == null) {
              return const DefaultTabController(
                length: 3,
                child: Scaffold(
                  appBar: TitleBar(),
                  bottomNavigationBar: Navigation(),
                  body: TabBarView(children: [
                    NoInternetConnection(),
                    NoInternetConnection(),
                    Settings()
                  ]),
                ),
              );
            } else {
              // Connected to a network...
              // First we connect to the MQTT Broker
              return const DefaultTabController(
                length: 3,
                child: Scaffold(
                  appBar: TitleBar(),
                  bottomNavigationBar: Navigation(),
                  body:
                      TabBarView(children: [Homepage(), Camera(), Settings()]),
                ),
              );
            }
          }
        }),
      ),
    );
    // TESTING BELOW
  }
}

class NoInternetConnection extends StatelessWidget {
  const NoInternetConnection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Icon(
              Icons.signal_wifi_statusbar_connected_no_internet_4_rounded,
              size: 128,
              color: Color.fromARGB(255, 33, 31, 103),
            ),
          ),
          Container(
            margin: EdgeInsets.all(getadaptiveTextSize(context, 8)),
            child: Text(
              "Whoops!",
              style: TextStyle(
                  color: const Color.fromARGB(255, 33, 31, 103),
                  fontFamily: 'Poppins',
                  fontSize: getadaptiveTextSize(context, 32),
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                top: getadaptiveTextSize(context, 4),
                bottom: getadaptiveTextSize(context, 32)),
            child: Text(
              "Slow or no internet connection.\nPlease check your internet settings",
              style: TextStyle(
                  color: const Color.fromARGB(255, 33, 31, 103),
                  fontFamily: 'Poppins',
                  fontSize: getadaptiveTextSize(context, 18),
                  fontWeight: FontWeight.w300),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
