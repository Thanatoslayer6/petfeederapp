import 'dart:async';

import 'package:flutter/material.dart';
import 'package:petfeederapp/camera.dart';
import 'package:petfeederapp/settings.dart';
import 'package:flutter/services.dart';
import 'navigation.dart';
import 'titlebar.dart';
import 'homepage.dart';
import 'time.dart';
// import 'package:connectivity/connectivity.dart';
import 'internet.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Force portrait mode
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Don't show status bar, only show bottom bar if possible
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    SystemUiOverlay.bottom, //This line is used for showing the bottom bar
  ]);

  // Start time
  DateTimeService.init();

  // Then call runApp() as normal
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // void initState() {
  //   super.initState();
  /*
    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult nowresult) {
      // Means there is no internet connection
      if (nowresult == ConnectivityResult.none) {
        print("Nonineter");
        // Show alert dialog
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("No Internet"),
              content: const Text(
                  "Please connect to the Internet to use the application"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(14),
                    child: const Text("Exit"),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Container(
                    color: Colors.black87,
                    padding: const EdgeInsets.all(14),
                    child: const Text("Retry"),
                  ),
                ),
              ],
            ),
          );
        });
      } else {
        print("Idk man");
      }
      */
  // previousresult = nowresult;
  // });
  // }

  // @override
  // void dispose() {
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        // theme: ThemeData(
        //     highlightColor: Colors.transparent,
        //     splashColor: Colors.transparent),
        home: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: TitleBar(),
            bottomNavigationBar: Navigation(),
            body: TabBarView(children: [Homepage(), Camera(), Settings()]),
          ),
        ));
  }

  // Future<bool> checkInternetConnection() async {
  //   // ConnectivityResult connectivityResult =
  //   //     await Connectivity().checkConnectivity();
  //   // return connectivityResult != ConnectivityResult.none;
  //   // var connectivityResult = await (Connectivity().checkConnectivity());
  //   // return connectivityResult != ConnectivityResult.none;
  // }
}
