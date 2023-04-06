import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfo {
  static bool? isUserNew;
  static String? productId;
  static String? devicePassword;
  static String? wifiPassword;
  static String? generalScheduleDatabaseId;
  static String? generalHistoryDatabaseId;
  static late String selectedTheme;
  static bool? isNotificationsEnabled;
  static bool isUVLightActivated = false;
  static ConnectivityResult? isAppConnectedToWiFi;
  // TODO: Theme preferences in the future

  static int MQTTAuthenticationStatus = -3;
  static int WifiAuthenticationStatus = 0;
  static int ProductAuthenticationStatus = 3;
  static bool isSubscribedToAuthTopic = false;
  static late SharedPreferences preferences;

  Future initializeSharedPreferences() async {
    preferences = await SharedPreferences.getInstance();
    print("Shared preferences now initialized...");
  }

  void getStoredData() {
    // preferences = await SharedPreferences.getInstance();
    // ignore: unnecessary_null_in_if_null_operators
    isUserNew = preferences.getBool('isUserNew') ??
        true; // Just set to true if user is new
    productId = preferences.getString('productId');
    devicePassword = preferences.getString('devicePassword');
    isNotificationsEnabled =
        preferences.getBool('isNotificationsEnabled') ?? false;
    generalScheduleDatabaseId =
        preferences.getString('generalScheduleDatabaseId');
    generalHistoryDatabaseId =
        preferences.getString('generalHistoryDatabaseId');
    selectedTheme = preferences.getString('selectedTheme') ?? "Light";
  }
}
