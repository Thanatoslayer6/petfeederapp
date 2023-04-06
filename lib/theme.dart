import 'package:flutter/material.dart';
import 'package:petfeederapp/preferences.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences extends StatefulWidget {
  const ThemePreferences({super.key});

  @override
  State<ThemePreferences> createState() => _ThemePreferencesState();
}

class _ThemePreferencesState extends State<ThemePreferences> {
  String selectedTheme = UserInfo.selectedTheme;

  Theme themeItem(String themeName) {
    return Theme(
      data: Theme.of(context)
          .copyWith(unselectedWidgetColor: Theme.of(context).disabledColor),
      child: RadioListTile(
        title: Text(themeName),
        value: themeName,
        groupValue: selectedTheme,
        onChanged: (value) {
          setState(() {
            selectedTheme = value as String;
            // _selectedTheme.setTheme("Light");
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // print(selectedTheme);
    return AlertDialog(
      title: const Text('Select a theme'),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          themeItem("Light"),
          themeItem("Dark"),
          themeItem("Abyss"),
          themeItem("Midnight")
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
            // Save the selected theme to shared_preferences
            UserInfo.preferences.setString("selectedTheme", selectedTheme);
            UserInfo.selectedTheme = selectedTheme;
            // You can pass the selected theme value back to the calling screen using Navigator
            Navigator.of(context).pop(selectedTheme);
          },
        ),
      ],
    );
  }
}

// TODO: Fix the themes and stuff
class ThemeModel {
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
      bodyText1: TextStyle(color: Colors.black87, fontWeight: FontWeight.w300),
      headline1: TextStyle(color: Colors.black87),
      headline2: TextStyle(color: Colors.black87),
      headline6: TextStyle(color: Colors.black87),
    ),
  );
  static ThemeData abyss = ThemeData(
    primaryColor: const Color.fromARGB(255, 250, 250, 250),
    scaffoldBackgroundColor: const Color.fromARGB(255, 33, 31, 103),
    unselectedWidgetColor: const Color.fromARGB(255, 42, 39, 150),
    secondaryHeaderColor: const Color.fromARGB(255, 243, 243, 243),
    selectedRowColor: const Color.fromARGB(255, 101, 145, 211),
    textTheme: const TextTheme(
      subtitle1: TextStyle(color: Color.fromARGB(255, 243, 243, 243)),
      subtitle2: TextStyle(color: Color.fromARGB(255, 243, 243, 243)),
      bodyText1: TextStyle(
          color: Color.fromARGB(255, 243, 243, 243),
          fontWeight: FontWeight.w300),
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
  static ThemeData midnight = ThemeData(
    primaryColor: const Color.fromARGB(255, 8, 2, 23),
    scaffoldBackgroundColor: const Color.fromARGB(255, 16, 10, 50),
    accentColor: const Color.fromARGB(255, 91, 73, 193),
    disabledColor: const Color.fromARGB(200, 140, 140, 140),
    unselectedWidgetColor: const Color.fromARGB(200, 140, 140, 140),
    selectedRowColor: const Color.fromARGB(255, 121, 108, 211),
    textTheme: const TextTheme(
      subtitle1: TextStyle(color: Colors.white),
      subtitle2: TextStyle(color: Colors.white),
      bodyText2: TextStyle(color: Colors.white),
      headline6: TextStyle(color: Colors.white),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(color: const Color.fromARGB(255, 156, 156, 156)),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: const Color.fromARGB(255, 121, 108, 211)),
      ),
    ),
  );

  static ThemeData dark = ThemeData(
    scaffoldBackgroundColor: const Color(0xFF1A1A1A),
    primaryColor: const Color(0xFF0D47A1),
    accentColor: const Color(0xFF1E88E5),
    unselectedWidgetColor: const Color(0xFFBDBDBD),
    textTheme: TextTheme(
      bodyText2: TextStyle(color: const Color(0xFFE0E0E0)),
      subtitle1: TextStyle(color: const Color(0xFFE0E0E0)),
      subtitle2: TextStyle(color: const Color(0xFFE0E0E0)),
      headline6: TextStyle(color: const Color(0xFFE0E0E0)),
    ),
  );
}

class ThemeProvider extends ChangeNotifier {
  ThemeData theme = ThemeData();
  late SharedPreferences _prefs;

  ThemeProvider() {
    SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
      String storedTheme = _prefs.getString('selectedTheme') ?? "Light";
      toggleTheme(storedTheme);
    });
  }

  ThemeData get currentTheme => theme;

  void toggleTheme(String themeName) {
    switch (themeName) {
      case "Light":
        theme = ThemeModel.light;
        break;
      case "Dark":
        theme = ThemeModel.dark;
        break;
      case "Abyss":
        theme = ThemeModel.abyss;
        break;
      case "Midnight":
        theme = ThemeModel.midnight;
        break;
    }
    notifyListeners();
  }
}
