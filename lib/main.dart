import 'dart:async';
import 'package:flutter/material.dart';
import 'package:petfeederapp/camera.dart';
import 'package:petfeederapp/settings.dart';
import 'package:flutter/services.dart';
import 'navigation.dart';
import 'titlebar.dart';
import 'homepage.dart';

void main() {
  // Add these 2 lines to disable statusbar/topbar
  WidgetsFlutterBinding.ensureInitialized();
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

// late TabController controller;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent),
        home: const DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: TitleBar(),
            bottomNavigationBar: Navigation(),
            body: TabBarView(children: [Homepage(), Camera(), Settings()]),
          ),
        ));
  }
}

class DateTimeService {
  // ignore: prefer_final_fields
  static StreamController<DateTime> _streamController =
      StreamController<DateTime>.broadcast();

  static void init() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _streamController.add(DateTime.now());
    });
  }

  static Stream<DateTime> get stream => _streamController.stream;

  static DateTime get timeNow => DateTime.now();
}
