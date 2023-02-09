import 'package:flutter/material.dart';
import 'package:petfeederapp/camera.dart';
import 'package:petfeederapp/settings.dart';
import 'package:flutter/services.dart';
import 'navigation.dart';
import 'titlebar.dart';
import 'homepage.dart';
import 'time.dart';

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
}
