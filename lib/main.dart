import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './navigation.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        appBar: CustomTitleBar(),
        // appBar: AppBar(title: const Text('CleverFeeder')),
        body: Center(child: Text('Hello World!')),
        bottomNavigationBar: Navigation(),
      ),
    );
  }
}

class CustomTitleBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: Column(
      children: const [
        Text("CleverFeeder",
            textAlign: TextAlign.left,
            style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold)),
        ClockWidget()
      ],
    )
        // title: const Text('CleverFeeder'),

        // titleTextStyle: const TextStyle(fontSize: 16, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ClockWidget extends StatelessWidget {
  const ClockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        return Text(
            DateFormat('EEE, MMM d yyyy - hh:mm:ss a').format(DateTime.now()),
            textAlign: TextAlign.left,
            style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400));
      },
    );
  }
}
