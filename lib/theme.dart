import 'package:flutter/material.dart';

// TODO: Theme customization widget
class ThemePreferences extends StatefulWidget {
  const ThemePreferences({super.key});

  @override
  State<ThemePreferences> createState() => _ThemePreferencesState();
}

class _ThemePreferencesState extends State<ThemePreferences> {
  ThemeManager something = ThemeManager();
  String selectedTheme = "Light";
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select a theme'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          RadioListTile<String>(
            title: const Text('Light'),
            value: 'Light',
            groupValue: selectedTheme,
            onChanged: (value) {
              setState(() {
                selectedTheme = value as String;
                // _selectedTheme.setTheme("Light");
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Dark'),
            value: 'Dark',
            groupValue: selectedTheme,
            onChanged: (value) {
              setState(() {
                print("Dark theme is not available yet");
                selectedTheme = value as String;
                // _selectedTheme = value!;
                // _selectedTheme.setTheme("Dark");
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Abyss'),
            value: 'Abyss',
            groupValue: selectedTheme,
            onChanged: (value) {
              setState(() {
                selectedTheme = value as String;
                // _selectedTheme = value!;
                // _selectedTheme.setTheme("Dark");
              });
            },
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('CANCEL'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            // something.setTheme(selectedTheme);
            // You can pass the selected theme value back to the calling screen using Navigator
            // Navigator.of(context).pop(_selectedTheme);
            Navigator.of(context).pop(selectedTheme);
          },
        ),
      ],
    );
  }
}

class ThemeManager {
  static ThemeData light = ThemeData(
    scaffoldBackgroundColor: const Color.fromARGB(255, 250, 250, 250),
    primaryColor: const Color.fromARGB(255, 33, 31, 103),
    secondaryHeaderColor: const Color.fromARGB(255, 42, 39, 150),
    unselectedWidgetColor: const Color.fromARGB(255, 243, 243, 243),
    disabledColor: const Color.fromARGB(255, 204, 204, 204),
    selectedRowColor: const Color.fromARGB(255, 101, 145, 211),
    textTheme: const TextTheme(
      subtitle1: TextStyle(color: Colors.black87),
      subtitle2: TextStyle(color: Colors.black87),
      bodyText2: TextStyle(color: Colors.black87),
      headline6: TextStyle(color: Colors.black87),
    ),
  );
  static ThemeData dark = ThemeData(
    primaryColor: const Color.fromARGB(255, 250, 250, 250),
    // scaffoldBackgroundColor: ,
    scaffoldBackgroundColor: const Color.fromARGB(255, 33, 31, 103),
    unselectedWidgetColor: const Color.fromARGB(255, 42, 39, 150),
    secondaryHeaderColor: const Color.fromARGB(255, 243, 243, 243),
    selectedRowColor: const Color.fromARGB(255, 101, 145, 211),
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

  static ThemeData current = light;

  // ThemeManager() {
  //   // Set the default theme to light
  //   // current = light;
  // }

  // ThemeData get currentTheme => current;

  static void setTheme(String themeName) {
    switch (themeName) {
      case "Light":
        current = light;
        break;
      case "Dark":
        current = dark;
        break;
      case "Abyss":
        current = dark;  
        print("Setting up Abyss theme...");
        break;
    }
  }
}
