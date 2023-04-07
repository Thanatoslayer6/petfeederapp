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
          themeItem("Solarized Light"),
          themeItem("Solarized Dark"),
          themeItem("Sweet"),
          themeItem("Tangerine"),
          themeItem("Nord"),
          themeItem("Night Blue"),
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
        bodyText1:
            TextStyle(color: Colors.black87, fontWeight: FontWeight.w300),
        headline1: TextStyle(color: Colors.black87),
        headline2: TextStyle(color: Colors.black87),
        headline6: TextStyle(color: Colors.black87),
      ),
      timePickerTheme: const TimePickerThemeData(
        dayPeriodTextColor: Color.fromARGB(255, 42, 39, 150),
        hourMinuteTextColor: Color.fromARGB(255, 42, 39, 150),
        backgroundColor: Color.fromARGB(255, 250, 250, 250),
      ));

  static ThemeData dark = ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color.fromARGB(255, 55, 72, 191),
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      unselectedWidgetColor: const Color.fromARGB(255, 54, 54, 54),
      secondaryHeaderColor: const Color.fromARGB(255, 50, 90, 200),
      textTheme: const TextTheme(
        bodyText2: TextStyle(color: Color(0xFFE0E0E0)),
        bodyText1:
            TextStyle(color: Color(0xFFE0E0E0), fontWeight: FontWeight.w300),
        subtitle1: TextStyle(color: Color(0xFFE0E0E0)),
        subtitle2: TextStyle(color: Color(0xFFE0E0E0)),
        headline1: TextStyle(color: Color(0xFFE0E0E0)),
        headline2: TextStyle(color: Color(0xFFE0E0E0)),
        headline6: TextStyle(color: Color(0xFFE0E0E0)),
      ),
      disabledColor: const Color.fromARGB(255, 70, 70, 70),
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
      timePickerTheme: const TimePickerThemeData(
        dialTextColor: Color.fromARGB(255, 50, 90, 200),
        dayPeriodTextColor: Color.fromARGB(255, 50, 90, 200),
        hourMinuteTextColor: Color.fromARGB(255, 50, 90, 200),
        dayPeriodColor: Color(0xFF1A1A1A),
        dialHandColor: Color.fromARGB(255, 50, 90, 200),
        backgroundColor: Color(0xFF1A1A1A),
      ));

  static ThemeData nightBlue = ThemeData(
      brightness: Brightness.dark,
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
      timePickerTheme: const TimePickerThemeData(
        dayPeriodTextColor: Color.fromARGB(255, 243, 243, 243),
        dialTextColor: Color.fromARGB(255, 243, 243, 243),
        hourMinuteTextColor: Color.fromARGB(255, 243, 243, 243),
        backgroundColor: Color.fromARGB(255, 33, 31, 103),
      ));

  static final ThemeData solarizedLight = ThemeData(
      brightness: Brightness.light,
      primaryColor: Color(0xff268bd2),
      scaffoldBackgroundColor: Color(0xfffdf6e3),
      secondaryHeaderColor: const Color(0xffd33682),
      disabledColor: Color(0xff93a1a1),
      selectedRowColor: Color(0xffeee8d5),
      // disabledColor: Color(0xff586e75),
      unselectedWidgetColor: Color(0xffeee8d5),
      textTheme: const TextTheme(
        subtitle1: TextStyle(color: Color(0xff586e75)),
        subtitle2: TextStyle(color: Color(0xff586e75)),
        bodyText1:
            TextStyle(color: Color(0xff586e75), fontWeight: FontWeight.w300),
        bodyText2: TextStyle(color: Color(0xff586e75)),
        headline6: TextStyle(color: Color(0xff586e75)),
      ),
      timePickerTheme: const TimePickerThemeData(
        dayPeriodTextColor: Color(0xffd33682),
        hourMinuteTextColor: Color(0xffd33682),
        backgroundColor: Color(0xfffdf6e3),
      ));

  static ThemeData tangerine = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xff0d1117),
      primaryColor: const Color(0xfff9826c),
      secondaryHeaderColor: const Color.fromARGB(255, 155, 231, 169),
      disabledColor: const Color.fromARGB(255, 68, 73, 80),
      dividerColor: const Color(0xff30363d),
      // unselectedWidgetColor: const Color(0xff6e7681),

      unselectedWidgetColor: const Color.fromARGB(255, 70, 70, 85),
      textTheme: const TextTheme(
        headline1: TextStyle(color: Color(0xffc9d1d9)),
        headline2: TextStyle(color: Color(0xffc9d1d9)),
        headline6: TextStyle(color: Color(0xffc9d1d9)),
        subtitle1: TextStyle(color: Color(0xffc9d1d9)),
        subtitle2: TextStyle(color: Color(0xffc9d1d9)),
        bodyText1:
            TextStyle(color: Color(0xffc9d1d9), fontWeight: FontWeight.w300),
        bodyText2: TextStyle(color: Color(0xffc9d1d9)),
      ),
      timePickerTheme: const TimePickerThemeData(
        // dayPeriodTextColor: Color.fromARGB(255, 243, 243, 243),
        dialTextColor: Color.fromARGB(255, 155, 231, 169),
        dialHandColor: Color(0xfff9826c),
        backgroundColor: Color(0xff0d1117),
        dayPeriodTextColor: Color.fromARGB(255, 155, 231, 169),
        hourMinuteTextColor: Color.fromARGB(255, 155, 231, 169),
      ));

  static ThemeData nord = ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color.fromARGB(255, 143, 188, 187),
      backgroundColor: const Color.fromARGB(255, 46, 52, 64),
      secondaryHeaderColor: const Color.fromARGB(255, 130, 195, 190),
      scaffoldBackgroundColor: const Color.fromARGB(255, 46, 52, 64),
      disabledColor: const Color.fromARGB(255, 68, 73, 80),
      dividerColor: const Color(0xff30363d),
      unselectedWidgetColor: const Color.fromARGB(255, 68, 68, 75),
      textTheme: const TextTheme(
        bodyText2: TextStyle(color: Colors.white),
        bodyText1: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
        subtitle1: TextStyle(color: Color.fromARGB(255, 216, 222, 233)),
        subtitle2: TextStyle(color: Color.fromARGB(255, 153, 170, 181)),
        headline6: TextStyle(color: Color.fromARGB(255, 216, 222, 233)),
        headline2: TextStyle(
          color: Color.fromARGB(255, 216, 222, 233),
        ),
        headline1: TextStyle(
          color: Color.fromARGB(255, 216, 222, 233),
        ),
      ),
      timePickerTheme: const TimePickerThemeData(
        dialHandColor: Color.fromARGB(255, 130, 195, 190),
        backgroundColor: Color.fromARGB(255, 46, 52, 64),
        dayPeriodTextColor: Color.fromARGB(255, 130, 195, 190),
        hourMinuteTextColor: Color.fromARGB(255, 130, 195, 190),
      ));

  static ThemeData sweetLight = ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xffFF5D9E),
      backgroundColor: const Color.fromARGB(255, 246, 246, 246),
      secondaryHeaderColor: const Color(0xffFFC529),
      scaffoldBackgroundColor: const Color.fromARGB(255, 240, 240, 240),
      // scaffoldBackgroundColor: Color.fromARGB(255, 248, 218, 236),
      disabledColor: Color.fromARGB(255, 139, 139, 139),
      dividerColor: const Color(0xffE0E0E0),
      // unselectedWidgetColor: const Color(0xff9E9E9E),
      unselectedWidgetColor: Color.fromARGB(255, 230, 230, 230),
      textTheme: const TextTheme(
        bodyText2: TextStyle(color: Colors.black),
        bodyText1: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
        subtitle1: TextStyle(color: Color(0xff333333)),
        subtitle2: TextStyle(color: Color(0xff666666)),
        headline6: TextStyle(color: Colors.black),
        headline2: TextStyle(color: Colors.black),
        headline1: TextStyle(color: Colors.black),
      ),
      timePickerTheme: const TimePickerThemeData(
        dialHandColor: Color(0xffFF5D9E),
        hourMinuteTextColor: Color(0xffFFC529),
        backgroundColor: Color.fromARGB(255, 240, 240, 240),
      ));

  static ThemeData solarizedDark = ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xff839496),
      backgroundColor: const Color(0xff002b36),
      secondaryHeaderColor: const Color(0xff93a1a1),
      scaffoldBackgroundColor: const Color(0xff002b36),
      disabledColor: const Color(0xff586e75),
      dividerColor: const Color(0xff586e75),
      unselectedWidgetColor: const Color(0xff586e75),
      textTheme: const TextTheme(
        bodyText2: TextStyle(color: const Color(0xff839496)),
        bodyText1: TextStyle(
            color: const Color(0xff93a1a1), fontWeight: FontWeight.w300),
        subtitle1: TextStyle(color: const Color(0xff839496)),
        subtitle2: TextStyle(color: const Color(0xff657b83)),
        headline6: TextStyle(color: const Color(0xff839496)),
        headline2: TextStyle(color: const Color(0xff839496)),
        headline1: TextStyle(color: const Color(0xff839496)),
      ),
      timePickerTheme: const TimePickerThemeData(
        dayPeriodTextColor: Color(0xff93a1a1),
        dialHandColor: Color(0xff002b36),
        dialTextColor: Color(0xff93a1a1),
        hourMinuteTextColor: Color(0xff93a1a1),
        backgroundColor: Color(0xff002b36),
      ));
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
      case "Solarized Light":
        theme = ThemeModel.solarizedLight;
        break;
      case "Solarized Dark":
        theme = ThemeModel.solarizedDark;
        break;
      case "Tangerine":
        theme = ThemeModel.tangerine;
        break;
      case "Nord":
        theme = ThemeModel.nord;
        break;
      case "Dark":
        theme = ThemeModel.dark;
        break;
      case "Sweet":
        theme = ThemeModel.sweetLight;
        break;
      case "Night Blue":
        theme = ThemeModel.nightBlue;
        break;
      // case "Midnight":
      //   theme = ThemeModel.midnight;
      //   break;
    }
    notifyListeners();
  }
}
