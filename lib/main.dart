// import 'dart:io';

import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:petfeederapp/camera.dart';
import 'package:petfeederapp/settings.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:uuid/uuid.dart';
import 'adaptive.dart';
import 'mqtt.dart';
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
  // Get random identifier if user is just starting up...
  // Then call runApp() as normal
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _formKey = GlobalKey<FormState>();
  bool _wifiPassVisibility = true;
  TextEditingController productIdInputController = TextEditingController();
  TextEditingController wifiPasswordInputController = TextEditingController();
  TextEditingController devicePasswordInputController = TextEditingController();

  // @override
  // void initState() {
  //   super.initState();
  //   // Get random ID
  //   // setState(() {
  //   //   productIdInputController.text = UserInfo.identifier;
  //   // });
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: Connectivity().onConnectivityChanged,
        builder: ((context, snapshot) {
          final result = snapshot.data;
          if (UserInfo.isUserNew == true) {
            // TODO: ESPTouch smart config, database connection, persistent config (Remember me?)
            return Scaffold(
                resizeToAvoidBottomInset: false,
                body: Form(
                  key: _formKey,
                  child: ListView(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            top: getadaptiveTextSize(context, 64),
                            bottom: getadaptiveTextSize(context, 16)),
                        child: SvgPicture.asset('assets/images/logo.svg',
                            semanticsLabel: 'ClevTech Logo',
                            color: const Color.fromARGB(255, 42, 39, 150),
                            width: 128,
                            height: 128),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
                        child: Text("Welcome to CleverFeeder!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: const Color.fromARGB(255, 33, 31, 103),
                                fontFamily: 'Poppins',
                                fontSize: getadaptiveTextSize(context, 32),
                                fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
                        child: Text(
                            "One Time Setup - Please fill out all the fields",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: const Color.fromARGB(255, 33, 31, 103),
                                fontFamily: 'Poppins',
                                fontSize: getadaptiveTextSize(context, 14),
                                fontWeight: FontWeight.w300)),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Product ID';
                            }
                            return null;
                          },
                          controller: productIdInputController,
                          // key: const Key('username-input'),
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: const InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 33, 31, 103),
                                    width: 2.0),
                              ),
                              hintText: "Product ID",
                              border: OutlineInputBorder()),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Device Password';
                            }
                            if (value.length < 8) {
                              return 'Device Password must be 8 characters or more';
                            }
                            return null;
                          },
                          controller: devicePasswordInputController,
                          // key: const Key('user-password-input'),
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: const InputDecoration(
                              hintText: "Device Password",
                              errorMaxLines: 2,
                              focusedBorder: OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 33, 31, 103),
                                    width: 2.0),
                              ),
                              border: OutlineInputBorder()),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the Wi-Fi password for your home network';
                            }
                            return null;
                          },
                          controller: wifiPasswordInputController,
                          // key: const Key('wifi-password-input'),
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: _wifiPassVisibility,
                          decoration: InputDecoration(
                              errorMaxLines: 2,
                              focusedBorder: const OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 33, 31, 103),
                                    width: 2.0),
                              ),
                              hintText: "Wi-Fi Password",
                              helperText:
                                  "Wi-Fi password of the network you're connected to",
                              helperMaxLines: 2,
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _wifiPassVisibility =
                                          !_wifiPassVisibility;
                                    });
                                  },
                                  icon: _wifiPassVisibility
                                      ? const Icon(Icons.visibility_off,
                                          color:
                                              Color.fromARGB(200, 33, 31, 103))
                                      : const Icon(Icons.visibility,
                                          color: Color.fromARGB(
                                              200, 33, 31, 103))),
                              border: const OutlineInputBorder()),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            top: 32, left: 48, right: 48, bottom: 32),
                        child: ElevatedButton(
                          onPressed: () {
                            // Validate returns true if the form is valid, or false otherwise.
                            if (_formKey.currentState!.validate()) {
                              // If the form is valid, display a snackbar. In the real world,
                              // you'd often call a server or save the information in a database.
                              if (result == ConnectivityResult.none ||
                                  result == null) {
                                // NO INTERNET
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('No internet connection...')),
                                );
                              } else {
                                // First we set the important variables
                                UserInfo.productId =
                                    productIdInputController.text;
                                UserInfo.devicePassword =
                                    devicePasswordInputController.text;
                                UserInfo.wifiPassword =
                                    wifiPasswordInputController.text;
                                // Connect the esp device
                                // TODO: Validate  if the device connected has the same credentials (product id, device password) as the one inputted by the user
                                // connectESPDevice();

                                showDialog(
                                    context: context,
                                    barrierDismissible:
                                        true, // Set to true for now...
                                    builder: (context) =>
                                        ConnectingDialog()).then((value) {
                                  setState(() {});
                                  print(
                                      "The dialog returned a value of: $value");
                                  if (value == 1) {
                                    // WIFI AUTH FAIL
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Failed to configure WiFi network")));
                                  } else if (value == 3) {
                                    // PRODUCT AUTH FAIL
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Failed to authenticate product")));
                                  }
                                });
                              }
                            }
                          },
                          // child: const Text('CONTINUE'),

                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 33, 31, 103),
                            padding: const EdgeInsets.only(top: 16, bottom: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text("CONTINUE",
                              style: TextStyle(
                                  // color: const Color.fromARGB(255, 33, 31, 103),

                                  color:
                                      const Color.fromARGB(255, 243, 243, 243),
                                  fontFamily: 'Poppins',
                                  fontSize: getadaptiveTextSize(context, 16),
                                  letterSpacing: 6.0,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
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
  static String? productId;
  static String? devicePassword;
  static String? wifiPassword;
}

// 0 - Loading
// 1 - Fail
// 2 - Success
// Future<int> espSmartConfig() async {
//   final info = NetworkInfo();
//   var temp = await info.getWifiName();
//   var wifiName = temp?.substring(1, temp.length - 1);
//   var wifiBSSID = await info.getWifiBSSID();
//   int didWifiConnect = 0; // Loading
//   Timer timeout = Timer(const Duration(seconds: 15), () {
//     didWifiConnect = 1; // Means fail....
//   });

//   final provisioner = Provisioner.espTouchV2();
//   provisioner.listen((response) {
//     print("$response has been connected to WiFi!");
//     didWifiConnect = 2; // Success
//     timeout.cancel(); // Cancel the timer, no need to wait
//   });
//   // Send in the password as well as the client identifier so that the MQTT broker is specified
//   await provisioner.start(ProvisioningRequest.fromStrings(
//     ssid: wifiName as String,
//     bssid: wifiBSSID as String,
//     password: UserInfo.wifiPassword,
//   ));

//   provisioner.stop();
//   print("Returning $didWifiConnect (fail = 1, success = 2) now!!!");
//   return didWifiConnect;
// }

Future<int> espSmartConfig() async {
  final info = NetworkInfo();
  var temp = await info.getWifiName();
  var wifiName = temp?.substring(1, temp.length - 1);
  var wifiBSSID = await info.getWifiBSSID();
  int didWifiConnect = 0; // Loading
  Completer completer =
      Completer(); // Create a completer to wait for the listen method

  Timer timeout = Timer(const Duration(seconds: 15), () {
    if (!completer.isCompleted) {
      // Check if the completer has already completed
      didWifiConnect = 1; // Means fail....
      completer.complete();
    }
  });

  final provisioner = Provisioner.espTouchV2();
  provisioner.listen((response) {
    print("$response has been connected to WiFi!");
    didWifiConnect = 2; // Success
    timeout.cancel();
    // completer.complete();
    provisioner.stop();
    /*
    if (!completer.isCompleted) {
      // Check if the completer has already completed
      timeout.cancel(); // Cancel the timer, no need to wait
      completer.complete();
    }
    */
  });

  // Send in the password as well as the client identifier so that the MQTT broker is specified
  await provisioner.start(ProvisioningRequest.fromStrings(
    ssid: wifiName as String,
    bssid: wifiBSSID as String,
    password: UserInfo.wifiPassword,
  ));

  // provisioner.stop();

  await completer.future; // Wait for the listen method to complete
  print("Returning $didWifiConnect (fail = 1, success = 2) now!!!");
  return didWifiConnect;
}

// 3 - Loading
// 4 - Fail
// 5 - Success
Future<int> validateProductCredentials() async {
  late StreamSubscription subscription;
  int isProductValid = 3; // Loading

  // Listen for MQTT messages
  MQTT.client
      .subscribe("auth/${UserInfo.productId}/status", MqttQos.exactlyOnce);
  subscription =
      MQTT.client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
    final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
    final String message =
        MqttPublishPayload.bytesToString(recMess.payload.message);
    if (c[0].topic == "auth/${UserInfo.productId}/status" &&
        message == "valid") {
      isProductValid = 5; // Success
    }
  });
  // TOPICS:
  // auth/CLIENT_ID - App sends in credentials, device watches for published credentials
  // auth/CLIENT_ID/status - Device publishes status (0 - fail, 1 - success), app watches for status

  // PUBLISH DATA
  Map<String, String?> credentials = {
    'product_id': UserInfo.productId,
    'device_password': UserInfo.devicePassword
  };
  String payload = json.encode(credentials);
  print(payload);
  MQTT.publish("auth/${UserInfo.productId}", payload);
  // END PUBLISH DATA

  // Wait for about 10 seconds or so...
  await Future.delayed(const Duration(seconds: 10));
  if (isProductValid == 3) {
    isProductValid = 4; // Fail
  }

  MQTT.client.unsubscribe("auth/${UserInfo.productId}/status");
  subscription.cancel();
  print("Returning $isProductValid (fail = 4, success = 5) now!!!");
  return isProductValid;
}

class ConnectingDialog extends StatefulWidget {
  const ConnectingDialog({super.key});

  @override
  State<ConnectingDialog> createState() => _ConnectingDialogState();
}

class _ConnectingDialogState extends State<ConnectingDialog> {
  Timer? _timeoutTimer;
  bool isAuthenticated = false;
  bool didAuthenticationFail = false;
  // NOTE:
  // WIFI
  // 0 - Loading
  // 1 - Fail
  // 2- Success
  // PRODUCT
  // 3 - Loading
  // 4 - Fail
  // 5 - Success
  // ignore: non_constant_identifier_names
  int WifiAuthenticationStatus = 0;
  // ignore: non_constant_identifier_names
  int ProductAuthenticationStatus = 0;

  void deviceWifiConfiguration() async {
    int status = await espSmartConfig();
    setState(() {
      WifiAuthenticationStatus = status;
    });
    if (WifiAuthenticationStatus == 1) {
      Timer(const Duration(seconds: 2), () {
        Navigator.of(context)
            .pop(1); // Return '1' which means failure to connect via wifi
      });
    }
    return;
  }

  void productConfiguration() async {
    int status = await validateProductCredentials();
    setState(() {
      ProductAuthenticationStatus = status;
    });
    if (ProductAuthenticationStatus == 4) {
      Timer(const Duration(seconds: 2), () {
        Navigator.of(context)
            .pop(4); // Return '4' which means failure to validate credentials
      });
    }
    return;
  }

  @override
  void initState() {
    // Connect to the MQTT Broker
    if (MQTT.isConnected == false) {
      print("I'm here and I need to connect bru");
      MQTT.connectToBroker(UserInfo.productId).then((value) {
        print("wutttt $value");
        deviceWifiConfiguration();
        // productConfiguration();
        return;
      });
      print("Where am i now?");
    }
    print("Nandito check");
    // deviceWifiConfiguration();
    // productConfiguration();
    // ESPSmartConfig().then((status) {
    //   setState(() {
    //     WifiAuthenticationStatus = status;
    //   });
    //   print("Wifi auth status is: $WifiAuthenticationStatus");
    //   return;
    // });

    // if (WifiAuthenticationStatus == 1) {
    //   print("I'm here right?");
    //   Navigator.of(context).pop();
    //   ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: const Text("Failed to configure WiFi network")));
    // }
    // _wifiConfiguration();
    // Future.wait(_wifiConfiguration());
    // Device failed to cnnect to WiFi network
    // connectESPDevice(); // First we connect the device to wifi
    // WifiAuthenticationStatus =
    // ProductAuthenticationStatus = await ValidateProduct();
    // Listen for MQTT messages
    // MQTT.client.subscribe("feed_duration_response", MqttQos.exactlyOnce);
    // subscription =
    //     MQTT.client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
    //   final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
    //   final String message =
    //       MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    if (didAuthenticationFail) {
      // Wait for 3 seconds then inform user
      Timer(const Duration(seconds: 3), () {
        Navigator.of(context).pop();
      });
    }
  }

  @override
  void dispose() {
    if (_timeoutTimer != null && _timeoutTimer!.isActive) {
      _timeoutTimer!.cancel();
    }
    print("Closing the dialog nowwwwwwwwww");
    // Unsubscribe from MQTT messages
    MQTT.client.unsubscribe("auth/${UserInfo.productId}/status");
    // subscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _wifiConfiguration();
    return AlertDialog(
      title: const Text("Provisioning Status"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 32,
                width: 32,
                child: (WifiAuthenticationStatus == 2)
                    ? Icon(
                        Icons.check_rounded,
                        size: 32,
                      )
                    : (WifiAuthenticationStatus == 0)
                        ? CircularProgressIndicator(
                            backgroundColor: Colors.green,
                          )
                        : Icon(Icons.warning_rounded),
              ),
              Container(
                  padding: EdgeInsets.only(left: 16, bottom: 16, top: 16),
                  child: Text(
                    isAuthenticated
                        ? "Device connected"
                        : "Sending WiFi credentials",
                  )),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              isAuthenticated
                  ? Icon(
                      Icons.check_rounded,
                      size: 32,
                    )
                  : SizedBox(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.green,
                      ),
                      height: 32,
                      width: 32,
                    ),
              Container(
                  // color: Colors.yellow,
                  padding: EdgeInsets.only(left: 16, bottom: 16, top: 16),
                  child: Text(
                    "Validating product info",
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
