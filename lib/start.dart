import 'dart:async';
import 'dart:convert' as convert;
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'adaptive.dart';
import 'mqtt.dart';
import 'preferences.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({
    Key? key,
    required this.result,
    required this.updateUserStatus,
  }) : super(key: key);

  final ConnectivityResult? result;
  final void Function(bool status) updateUserStatus;

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _wifiPassVisibility = true;
  TextEditingController productIdInputController = TextEditingController();
  TextEditingController wifiPasswordInputController = TextEditingController();
  TextEditingController devicePasswordInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                    color: Theme.of(context).secondaryHeaderColor,
                    width: 128,
                    height: 128),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
                child: Text("Welcome to CleverFeeder!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontFamily: 'Poppins',
                        fontSize: getadaptiveTextSize(context, 32),
                        fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
                child: Text(
                    "One Time Setup - Please fill out all the fields, and enable location from your phone",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        // color: const Color.fromARGB(255, 33, 31, 103),

                        color: Theme.of(context).primaryColor,
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
                      hintText: "Product ID", border: OutlineInputBorder()),
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
                      hintText: "Product Password",
                      errorMaxLines: 2,
                      // focusedBorder: OutlineInputBorder(
                      //   // width: 0.0 produces a thin "hairline" border
                      //   borderSide: BorderSide(
                      //       color: Theme.of(context).primaryColor, width: 2.0),
                      // ),
                      border: OutlineInputBorder()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the WiFi password for your home network';
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
                      hintText: "WiFi Password",
                      helperText:
                          "WiFi password of the network you're connected to",
                      // helperStyle: Theme.of(context).textTheme.bodyText1,
                      helperStyle:
                          TextStyle(color: Theme.of(context).disabledColor),
                      helperMaxLines: 2,
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _wifiPassVisibility = !_wifiPassVisibility;
                            });
                          },
                          icon: _wifiPassVisibility
                              ? Icon(
                                  Icons.visibility_off,
                                  color: Theme.of(context).primaryColor,
                                )
                              : Icon(
                                  Icons.visibility,
                                  color: Theme.of(context).primaryColor,
                                )),
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
                      if (widget.result == ConnectivityResult.none ||
                          widget.result == null) {
                        // NO INTERNET
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('No internet connection...')),
                        );
                      } else {
                        // First we set the important variables
                        UserInfo.productId = productIdInputController.text;
                        UserInfo.devicePassword =
                            devicePasswordInputController.text;
                        UserInfo.wifiPassword =
                            wifiPasswordInputController.text;

                        showGeneralDialog(
                          context: context,
                          barrierDismissible: false,
                          pageBuilder: (context, a1, a2) {
                            return Container();
                          },
                          transitionBuilder: (ctx, a1, a2, child) {
                            var curve = Curves.easeInOut.transform(a1.value);
                            return Transform.scale(
                              scale: curve,
                              child: const ConnectingDialog(),
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 500),
                        ).then((value) {
                          setState(() {});
                          if (value == -2) {
                            // MQTT CONNECTION FAIL
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Failed to connect to MQTT broker")));
                          } else if (value == 1) {
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
                          } else if (value == true) {
                            // Everything is successful, just go to homepage then
                            widget.updateUserStatus(false);
                          }
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    // backgroundColor: const Color.fromARGB(255, 33, 31, 103),
                    backgroundColor: Theme.of(context).secondaryHeaderColor,
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text("CONTINUE",
                      style: TextStyle(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          fontFamily: 'Poppins',
                          fontSize: getadaptiveTextSize(context, 16),
                          letterSpacing: 6.0,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ));
  }
}

// 0 - Loading
// 1 - Fail
// 2 - Success
Future<int> espSmartConfig() async {
  final info = NetworkInfo();
  var temp = await info.getWifiName();
  var wifiName = temp?.substring(1, temp.length - 1);
  var wifiBSSID = await info.getWifiBSSID();
  int didWifiConnect = 0; // Loading

  final provisioner = Provisioner.espTouchV2();
  provisioner.listen((response) {
    log("$response has been connected to WiFi!");
    didWifiConnect = 2; // Success
    provisioner.stop();
  });

  try {
    // Send in the password as well as the client identifier so that the MQTT broker is specified
    await provisioner.start(ProvisioningRequest.fromStrings(
      ssid: wifiName as String,
      bssid: wifiBSSID as String,
      password: UserInfo.wifiPassword,
    ));
  } catch (e) {
    didWifiConnect = 1;
    provisioner.stop();
    // log(e as String);
  }
  await Future.delayed(const Duration(seconds: 8));
  if (didWifiConnect == 0) {
    log("Stopping now, nothing happened in the past 10 seconds");
    didWifiConnect = 1;
    provisioner.stop();
  }
  log("Returning $didWifiConnect (fail = 1, success = 2) now!!!");
  return didWifiConnect;
}

// 3 - Loading
// 4 - Fail
// 5 - Success
Future<int> validateProductCredentials() async {
  late StreamSubscription subscription;
  int isProductValid = 3; // Loading
  // Listen for MQTT messages check condition first if already subscribed
  if (UserInfo.isSubscribedToAuthTopic == false) {
    MQTT.client
        .subscribe("auth/${UserInfo.productId}/status", MqttQos.exactlyOnce);
    UserInfo.isSubscribedToAuthTopic = true;
  }
  subscription =
      MQTT.client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
    final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
    final String message =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    if (c[0].topic == "auth/${UserInfo.productId}/status" &&
        message == "valid") {
      isProductValid = 5; // Success
    }
  });
  // TOPICS:
  // auth/CLIENT_ID - App sends in credentials, device watches for published credentials
  // auth/CLIENT_ID/status - Device publishes status (0 - fail, 1 - success), app watches for status
  String payload =
      '{"id":"${UserInfo.productId}", "pwd": "${UserInfo.devicePassword}"}';
  MQTT.publish("auth/${UserInfo.productId}", payload);
  // END PUBLISH DATA

  // Wait for about 10 seconds or so...
  await Future.delayed(const Duration(seconds: 5));
  if (isProductValid == 3) {
    isProductValid = 4; // Fail
  }

  // Unsub from topic depending on the state of boolean variable
  if (UserInfo.isSubscribedToAuthTopic == true) {
    MQTT.client.unsubscribe("auth/${UserInfo.productId}/status");
    UserInfo.isSubscribedToAuthTopic = false;
  }
  subscription.cancel();
  log("Returning $isProductValid (fail = 4, success = 5) now!!!");
  return isProductValid;
}

class ConnectingDialog extends StatefulWidget {
  const ConnectingDialog({super.key});

  @override
  State<ConnectingDialog> createState() => _ConnectingDialogState();
}

class _ConnectingDialogState extends State<ConnectingDialog> {
  // NOTE: Remember the status
  // MQTT
  // -3 - Loading
  // -2 - Fail
  // -1 - Success
  // WIFI
  // 0 - Loading
  // 1 - Fail
  // 2 - Success
  // PRODUCT
  // 3 - Loading
  // 4 - Fail
  // 5 - Success

  Future<void> mqttConfiguration() async {
    // Check if it's still not connected to the broker
    if (MQTT.isConnected == false) {
      await MQTT.connectToBroker("${UserInfo.productId}-${const Uuid().v1()}");
      setState(() {
        if (MQTT.isConnected == true) {
          UserInfo.MQTTAuthenticationStatus = -1; // Successful connection
        } else {
          UserInfo.MQTTAuthenticationStatus = -2; // Failed to connect
          Timer(const Duration(seconds: 3), () {
            Navigator.of(context).pop(
                -2); // Return '-2' which means failure to connect to MQTT broker
          });
        }
      });
    }
    return;
  }

  Future<void> deviceWifiConfiguration() async {
    if (UserInfo.WifiAuthenticationStatus != 2) {
      int status = await espSmartConfig();
      setState(() {
        UserInfo.WifiAuthenticationStatus = status;
      });
    }
    if (UserInfo.WifiAuthenticationStatus == 1) {
      // UserInfo.WifiAuthenticationStatus = 0; // Reset back to loading
      Timer(const Duration(seconds: 3), () {
        Navigator.of(context)
            .pop(1); // Return '1' which means failure to connect via wifi
        UserInfo.WifiAuthenticationStatus = 0; // Reset back to loading
      });
    }
    return;
  }

  Future<void> productConfiguration() async {
    if (UserInfo.ProductAuthenticationStatus != 5) {
      int status = await validateProductCredentials();
      setState(() {
        UserInfo.ProductAuthenticationStatus = status;
      });
    }
    if (UserInfo.ProductAuthenticationStatus == 4) {
      Timer(const Duration(seconds: 3), () {
        Navigator.of(context)
            .pop(4); // Return '4' which means failure to validate credentials
        UserInfo.ProductAuthenticationStatus = 3; // Reset back to loading
      });
    }
    return;
  }

  initNecessaryMethods() async {
    await deviceWifiConfiguration();
    // Execute code block below if wifi is connected but not MQTT
    if (UserInfo.WifiAuthenticationStatus == 2 &&
        UserInfo.MQTTAuthenticationStatus != -1) {
      await mqttConfiguration();
      // Wait for about 3 seconds to avoid race problems
      log("waiting for about 3 seconds to let the device connect first");
      await Future.delayed(const Duration(seconds: 3));
    }
    // Execute code block below if mqtt is connected but product is not validated
    if (UserInfo.MQTTAuthenticationStatus == -1 &&
        UserInfo.ProductAuthenticationStatus != 5) {
      await productConfiguration();
    }
    if (UserInfo.WifiAuthenticationStatus == 2 &&
        UserInfo.MQTTAuthenticationStatus == -1 &&
        UserInfo.ProductAuthenticationStatus == 5) {
      log("Success! on initialization, creating records on database now");

      // Create a schedule document for the user
      final response1 = await http.post(
        Uri.parse("${dotenv.env['CRUD_API']}/api/schedule"),
        body: convert.json.encode({
          'client': UserInfo.productId,
          'items': [],
        }),
        headers: {'Content-Type': 'application/json'},
      );
      log(response1.body);

      // Create a log document for the user
      final response2 = await http.post(
        Uri.parse("${dotenv.env['CRUD_API']}/api/logs"),
        body: convert.json.encode({
          'client': UserInfo.productId,
          'items': [],
        }),
        headers: {'Content-Type': 'application/json'},
      );
      log(response2.body);

      Timer(const Duration(seconds: 2), () {
        Navigator.of(context).pop(
            true); // Return '-2' which means failure to connect to MQTT broker
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initNecessaryMethods();
  }

  @override
  void dispose() {
    log("~~~~~~~ CLOSING THE DIALOG NOW ~~~~~~~~");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text("Provisioning Status",
            style: TextStyle(color: Theme.of(context).primaryColor)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 32,
                width: 32,
                child: (UserInfo.WifiAuthenticationStatus == 0) // Loading
                    ? CircularProgressIndicator(
                        backgroundColor: Theme.of(context).primaryColor,
                        color: Theme.of(context).secondaryHeaderColor,
                      )
                    : (UserInfo.WifiAuthenticationStatus == 1) // Fail
                        ? Icon(
                            Icons.warning_rounded,
                            color: Theme.of(context).secondaryHeaderColor,
                          )
                        : Icon(
                            Icons.check_rounded,
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
              ),
              Container(
                  padding: const EdgeInsets.only(left: 16, bottom: 16, top: 16),
                  child: Text(
                    (UserInfo.WifiAuthenticationStatus == 0)
                        ? "Sending WiFi credentials"
                        : (UserInfo.WifiAuthenticationStatus == 1)
                            ? "Failed to connect!"
                            : "Device connected",
                  )),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 32,
                width: 32,
                child: (UserInfo.MQTTAuthenticationStatus == -3) // Loading
                    ? CircularProgressIndicator(
                        // backgroundColor: Colors.green,
                        color: Theme.of(context).secondaryHeaderColor,
                        backgroundColor: Theme.of(context).primaryColor,
                      )
                    : (UserInfo.ProductAuthenticationStatus == 4) // Fail
                        ? Icon(
                            Icons.warning_rounded,
                            color: Theme.of(context).secondaryHeaderColor,
                          )
                        : Icon(
                            // Fail
                            Icons.check_rounded,
                            color: Theme.of(context).secondaryHeaderColor,
                            size: 32,
                          ),
              ),
              Container(
                  padding: const EdgeInsets.only(left: 16, bottom: 16, top: 16),
                  child:
                      Text((UserInfo.MQTTAuthenticationStatus == -3) // Loading
                          ? "Connecting to MQTT Broker"
                          : (UserInfo.MQTTAuthenticationStatus == -2) // Failed
                              ? "Failed to connect!"
                              : "Connected to MQTT Broker")),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 32,
                width: 32,
                child: (UserInfo.ProductAuthenticationStatus == 3) // Loading
                    ? CircularProgressIndicator(
                        color: Theme.of(context).secondaryHeaderColor,
                        backgroundColor: Theme.of(context).primaryColor,
                      )
                    : (UserInfo.ProductAuthenticationStatus == 4) // Fail
                        ? Icon(
                            Icons.warning_rounded,
                            color: Theme.of(context).secondaryHeaderColor,
                          )
                        : Icon(
                            Icons.check_rounded,
                            color: Theme.of(context).secondaryHeaderColor,
                            size: 32,
                          ),
              ),
              Container(
                  padding: const EdgeInsets.only(left: 16, bottom: 16, top: 16),
                  child: Text(
                    (UserInfo.ProductAuthenticationStatus == 3) // Loading
                        ? "Validating product id"
                        : (UserInfo.ProductAuthenticationStatus == 4)
                            ? "Failed to validate device!"
                            : "Device validated",
                  )),
            ],
          ),
        ]));
  }
}
