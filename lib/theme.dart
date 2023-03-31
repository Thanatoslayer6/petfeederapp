import 'package:flutter/material.dart';

ThemeData light = ThemeData(
    scaffoldBackgroundColor: const Color.fromARGB(255, 250, 250, 250),
    primaryColor: const Color.fromARGB(255, 33, 31, 103),
    secondaryHeaderColor: const Color.fromARGB(255, 42, 39, 150),
    unselectedWidgetColor: const Color.fromARGB(255, 243, 243, 243),
    disabledColor: const Color.fromARGB(255, 204, 204, 204),
    textTheme: const TextTheme(bodyText2: TextStyle(color: Colors.black87)));

ThemeData dark = ThemeData(
  primaryColor: const Color.fromARGB(255, 250, 250, 250),
  // scaffoldBackgroundColor: ,
  scaffoldBackgroundColor: const Color.fromARGB(255, 33, 31, 103),
  unselectedWidgetColor: const Color.fromARGB(255, 42, 39, 150),
  secondaryHeaderColor: const Color.fromARGB(255, 243, 243, 243),
  textTheme: const TextTheme(
    subtitle1: TextStyle(color: Color.fromARGB(255, 243, 243, 243)),
    subtitle2: TextStyle(color: Color.fromARGB(255, 243, 243, 243)),
    bodyText2: TextStyle(color: Color.fromARGB(255, 243, 243, 243)),
    headline6: TextStyle(color: Color.fromARGB(255, 243, 243, 243)),
  ),
  disabledColor: const Color.fromARGB(200, 140, 140, 140),
  inputDecorationTheme: const InputDecorationTheme(
    // Other input decoration theme properties...
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey, // Change this to the desired color
      ),
    ),
    focusedBorder: OutlineInputBorder(
      // width: 0.0 produces a thin "hairline" border
      borderSide:
          BorderSide(color: Color.fromARGB(255, 250, 250, 250), width: 2.0),
    ),
    hintStyle: TextStyle(
      color: Colors.grey, // Change this to the desired color
    ),
  ),
);

// TODO: Theme customization widget
class ThemePreferences extends StatefulWidget {
  const ThemePreferences({super.key});

  @override
  State<ThemePreferences> createState() => _ThemePreferencesState();
}

class _ThemePreferencesState extends State<ThemePreferences> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog();
  }
}