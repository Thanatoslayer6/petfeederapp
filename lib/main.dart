// import 'dart:io';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:petfeederapp/service.dart';
import 'notification.dart';
import 'start.dart';
import 'adaptive.dart';
import 'preferences.dart';
import 'navigation.dart';
import 'titlebar.dart';
import 'homepage.dart';
import 'time.dart';
import 'camera.dart';
import 'settings.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Force portrait mode
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Don't show status bar, only show bottom bar if possible
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    SystemUiOverlay.bottom, //This line is used for showing the bottom bar
  ]);

  // Start time, and initialize notification api
  DateTimeService.init();
  // await initService();
  NotificationAPI.init();
  // Load environment variables
  await dotenv.load(fileName: "assets/.env");
  // This will start the service which will help us connect to the mqtt broker for notifications and other stuff

  // Request location permissions for smartconfig
  if (await Permission.location.request().isGranted) {
    print("Location permissions are granted");
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This method will be used for updating user status
  void updateUserStatus(bool status) {
    UserInfo.isUserNew = status;
    UserInfo.preferences.setBool('isUserNew', status);
    UserInfo.preferences.setString('productId', UserInfo.productId as String);
    UserInfo.preferences
        .setString('devicePassword', UserInfo.devicePassword as String);
    setState(() {});
  }

  // Initialize and fet stored data from shared preferences
  @override
  void initState() {
    super.initState();
    sharedPrefInit();
  }

  sharedPrefInit() async {
    final app = UserInfo();
    await app.initializeSharedPreferences();
    app.getStoredData();
    // UserInfo.preferences.setString('productId', "demo1234");
    // Start the notification service...
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: Connectivity().onConnectivityChanged,
        builder: ((context, snapshot) {
          final result = snapshot.data;
          // TODO: Set this condition to false for demoing in order to bypass start screen for new users
          // if (UserInfo.isUserNew == false) {
          if (UserInfo.isUserNew == true) {
            return StartScreen(
                result: result, updateUserStatus: updateUserStatus);
          } else {
            // START (remove this after testing)
            // UserInfo.productId = "demo1234";
            // UserInfo.devicePassword = "demo1234";
            // END
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
