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

  // Then call runApp() as normal
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
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
