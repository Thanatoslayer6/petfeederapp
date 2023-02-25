import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:petfeederapp/camera.dart';
import 'package:petfeederapp/settings.dart';
import 'package:flutter/services.dart';
// import 'package:esptouch_flutter/esptouch_flutter.dart';
import 'adaptive.dart';
import 'navigation.dart';
import 'titlebar.dart';
import 'homepage.dart';
import 'time.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Force portrait mode
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Don't show status bar, only show bottom bar if possible
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    SystemUiOverlay.bottom, //This line is used for showing the bottom bar
  ]);

  // Start time
  DateTimeService.init();
  // Load environment variables
  await dotenv.load(fileName: "assets/.env");
  // Then call runApp() as normal
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _wifiPassVisibility = true;
  bool _userPassVisibility = true;
  TextEditingController userInputController = TextEditingController();
  TextEditingController wifiPasswordInputController = TextEditingController();
  TextEditingController userPasswordInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: Connectivity().onConnectivityChanged,
        builder: ((context, snapshot) {
          final result = snapshot.data;
          if (UserInfo.isUserNew == true) {
            return Scaffold(
                resizeToAvoidBottomInset: false,
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Image(
                        image: ResizeImage(AssetImage('assets/images/logo.png'),
                            width: 128, height: 128)),
                    Container(
                      // color: Colors.yellow,
                      // margin: const EdgeInsets.only(top),
                      padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
                      child: Text("Welcome to CleverFeeder!",
                          // textAlign: TextAlign.center,
                          style: TextStyle(
                              color: const Color.fromARGB(255, 33, 31, 103),
                              fontFamily: 'Poppins',
                              fontSize: getadaptiveTextSize(context, 36),
                              fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
                      child: TextField(
                        controller: userInputController,
                        key: const Key('username-input'),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: const InputDecoration(
                            hintText: "Username", border: OutlineInputBorder()),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
                      child: TextField(
                        controller: userPasswordInputController,
                        key: const Key('user-password-input'),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: _userPassVisibility,
                        decoration: InputDecoration(
                            hintText: "Password",
                            helperText:
                                "Temporary Account password for Database/MQTT",
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _userPassVisibility = !_userPassVisibility;
                                  });
                                },
                                icon: _userPassVisibility
                                    ? const Icon(Icons.visibility_off)
                                    : const Icon(Icons.visibility)),
                            border: const OutlineInputBorder()),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
                      child: TextField(
                        controller: wifiPasswordInputController,
                        key: const Key('wifi-password-input'),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: _wifiPassVisibility,
                        decoration: InputDecoration(
                            hintText: "Wi-Fi Password",
                            helperText:
                                "Wi-Fi Password of the Network you're Connected to",
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _wifiPassVisibility = !_wifiPassVisibility;
                                  });
                                },
                                icon: _wifiPassVisibility
                                    ? const Icon(Icons.visibility_off)
                                    : const Icon(Icons.visibility)),
                            border: const OutlineInputBorder()),
                      ),
                    ),
                    MaterialButton(
                      onPressed: () {
                        UserInfo.isUserNew = false;
                        setState(() {});
                      },
                      child: const Text("SUBMIT"),
                    )
                  ],
                ));
          } else {
            if (result == ConnectivityResult.none || result == null) {
              return const DefaultTabController(
                length: 3,
                child: Scaffold(
                  appBar: TitleBar(),
                  bottomNavigationBar: Navigation(),
                  body: TabBarView(children: [
                    NoInternetConnection(),
                    NoInternetConnection(),
                    Settings()
                  ]),
                ),
              );
            } else {
              // Connected to a network...
              // First we connect to the MQTT Broker
              return const DefaultTabController(
                length: 3,
                child: Scaffold(
                  appBar: TitleBar(),
                  bottomNavigationBar: Navigation(),
                  body:
                      TabBarView(children: [Homepage(), Camera(), Settings()]),
                ),
              );
            }
          }
        }),
      ),
    );
    // TESTING BELOW
  }
}

class NoInternetConnection extends StatelessWidget {
  const NoInternetConnection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Icon(
              Icons.signal_wifi_statusbar_connected_no_internet_4_rounded,
              size: 128,
              color: Color.fromARGB(255, 33, 31, 103),
            ),
          ),
          Container(
            margin: EdgeInsets.all(getadaptiveTextSize(context, 8)),
            child: Text(
              "Whoops!",
              style: TextStyle(
                  color: const Color.fromARGB(255, 33, 31, 103),
                  fontFamily: 'Poppins',
                  fontSize: getadaptiveTextSize(context, 32),
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                top: getadaptiveTextSize(context, 4),
                bottom: getadaptiveTextSize(context, 32)),
            child: Text(
              "Slow or no internet connection.\nPlease check your internet settings",
              style: TextStyle(
                  color: const Color.fromARGB(255, 33, 31, 103),
                  fontFamily: 'Poppins',
                  fontSize: getadaptiveTextSize(context, 18),
                  fontWeight: FontWeight.w300),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class UserInfo {
  static bool isUserNew = true;
  late String _name;
  late String _password;
  late String _wifiPassword;

  set name(String value) {
    _name = value;
  }

  set password(String value) {
    _password = value;
  }

  set wifiPassword(String value) {
    _wifiPassword = value;
  }

  String get name => _name;
  String get password => _password;
  String get wifiPassword => _wifiPassword;
}
