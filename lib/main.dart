import 'package:flutter/material.dart';
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
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Poppins',
        //   textTheme: const TextTheme(
        //       displayLarge:
        //           TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
        //       titleLarge: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
        //       regular: TextStyle(fontSize: 10, fontStyle: FontStyle.normal)
        //       // regularSize: TextStyle(fontSize: 16)),
      ),
      home: const Scaffold(
        bottomNavigationBar: Navigation(),
      ),
    );
  }
}
