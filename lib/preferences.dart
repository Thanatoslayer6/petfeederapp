import 'package:shared_preferences/shared_preferences.dart';

class UserInfo {
  static bool? isUserNew;
  static String? productId;
  static String? devicePassword;
  static String? wifiPassword;

  // TODO: Theme preferences in the future

  static int MQTTAuthenticationStatus = -3;
  static int WifiAuthenticationStatus = 0;
  static int ProductAuthenticationStatus = 3;
  static bool isSubscribedToAuthTopic = false;
  late SharedPreferences preferences;
  Future getStoredData() async {
    preferences = await SharedPreferences.getInstance();
    // ignore: unnecessary_null_in_if_null_operators
    isUserNew = preferences.getBool('isUserNew') ??
        true; // Just set to true if user is new
    productId = preferences.getString('productId');
    devicePassword = preferences.getString('devicePassword');
  }
}
