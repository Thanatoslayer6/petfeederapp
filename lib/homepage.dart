// ignore_for_file: prefer_const_constructors
import 'dart:async';
import 'dart:developer';
import 'package:path_provider/path_provider.dart';
import 'package:petfeederapp/uvlight.dart';

import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';

import 'dart:convert' as convert;
/* import 'package:flutter_background_service/flutter_background_service.dart'; */
import 'package:network_info_plus/network_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:petfeederapp/mqtt.dart';
import 'package:uuid/uuid.dart';
import 'activitylog.dart';
import 'adaptive.dart';
import 'time.dart';
import 'schedule.dart';
import 'quotes.dart';
import 'preferences.dart';

class Homepage extends StatefulWidget {
  static bool wentToSchedule = false;
  static bool isLocalServerRunning = false;
  // ignore: prefer_typing_uninitialized_variables
  static var activeSchedules;
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Timer? setStateEveryMinute;

  @override
  void initState() {
    super.initState();
    // Gets random quote if possible
    if (Quotes.hasQuote == false) {
      Quotes.getRandom().then((value) {
        log(value);
        setState(() {});
      });
    }

    // Start local web server (I know... but this is the only way...  )
    if (!Homepage.isLocalServerRunning) {
      startServer();
    }

    // // // Connect to the Private MQTT Broker
    if (MQTT.isConnected == false) {
      MQTT.connectToBroker("${UserInfo.productId}-${const Uuid().v1()}");
    }

    // Get saved contents of schedules
    Schedule.loadSchedule();
    UVLightHandler().getStateFromFile();
    setStateEveryMinute = Timer.periodic(const Duration(seconds: 10), (timer) {
      log("Called 'setState()'");
      setState(() {});
    });
  }

  @override
  void dispose() {
    if (setStateEveryMinute != null) {
      setStateEveryMinute!.cancel();
      setStateEveryMinute = null;
    }
    super.dispose();
  }

  startServer() async {
    // Get the directory (temporary)
    final Directory cacheDirectory = await getTemporaryDirectory();
    final cacheHandler = createStaticHandler(
      cacheDirectory.path,
      useHeaderBytesForContentType: true,
      listDirectories: true,
    );
    final server = await shelf_io.serve(
      cacheHandler,
      InternetAddress.anyIPv4,
      8080,
    );
    log('Server running on ${await NetworkInfo().getWifiIP()}:${server.port}');
    Homepage.isLocalServerRunning = true;
  }

  @override
  Widget build(BuildContext context) {
    Homepage.activeSchedules = getScheduleInOrder();
    // Send schedule to the ESP32
    if (Homepage.wentToSchedule == true) {
      log("Setting up schedule if user changes something... else this statement is meaningless");
      List minifiedDateTime = [];
      // Get only the datetime objects from their hour and minute, then send to esp32
      for (int i = 0; i < Homepage.activeSchedules.length; i++) {
        minifiedDateTime.add({
          'h': Homepage.activeSchedules[i].hour,
          'm': Homepage.activeSchedules[i].minute,
          'd': (Homepage.activeSchedules[i].dispenserDuration * 1000)
              .toInt() // Seconds in milliseconds
        });
      }

      String payload = convert.json.encode(minifiedDateTime);
      log(payload);
      if (minifiedDateTime.isEmpty) {
        log("Sending default values to microcontroller");
        MQTT.publish(
            "${UserInfo.productId}/feed_schedule",
            convert.json.encode([
              {'h': -1, 'm': -1, 'd': -1}
            ]));
      } else {
        MQTT.publish("${UserInfo.productId}/feed_schedule", payload);
      }
      // If payload is '[]' this means that user is in manual mode...
      // else he/she is on automation
      // MQTT.publish("${UserInfo.productId}/feed_schedule", payload);
      Homepage.wentToSchedule = false;
    }

    return Column(
      children: [
        if (Homepage.activeSchedules.isNotEmpty) ...[
          // AUTOMATIC MODE
          modeIdentifierWidget(context, true), // Automatic Mode ? Manual Mode
          headlineAutomaticWidget(context), // Feeding Time (TIME)
          subHeadlineWidget(
              context,
              DateTimeService.getDateWithHourAndMinuteSet(
                  Homepage.activeSchedules[0].hour,
                  Homepage.activeSchedules[0].minute)), // HH:MM a (TIME)
          countdownWidget(DateTimeService.getDateWithHourAndMinuteSet(
              Homepage.activeSchedules[0].hour,
              Homepage.activeSchedules[0].minute)),
          // BUTTONS BELOW,
          // feedButtonWidget(context), // DISABLE FEED ME FOR NOW....
          setScheduleButtonWidget(), // Set schedule
          uvLightButtonWidget(), // Enable/Disable uv light
          activityLogButtonWidget()
          // setModeButtonWidget()
        ] else if (Homepage.activeSchedules.isEmpty) ...[
          // MANUAL MODE
          modeIdentifierWidget(context, false),
          // ignore: avoid_unnecessary_containers
          Container(
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.sp,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      // GREETING HEADER
                      Container(
                        margin: EdgeInsets.only(top: 16, bottom: 8),
                        child: Text(greeting(),
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontFamily: 'Poppins',
                                fontSize: getadaptiveTextSize(context, 48),
                                fontWeight: FontWeight.bold)),
                      ),
                      ...animateQuote(),
                      feedButtonWidget(context)
                    ],
                  ),
                ),
              ],
            ),
          ),
          // BUTTONS BELOW,
          setScheduleButtonWidget(), // Set schedule
          uvLightButtonWidget(), // Enable/Disable uv light
          activityLogButtonWidget(),
        ]
      ],
    );
  }

  // Returns schedule in order, handles weekdays as well
  List<dynamic> getScheduleInOrder() {
    List<ListItem> activeSchedules =
        Schedule.listOfTimes.where((item) => item.isActive).toList();
    if (activeSchedules.isNotEmpty) {
      // Sort the list according to the nearest time from now in ascending order
      // activeSchedules.sort((a, b) => calculateRemainingTime(a.data)
      //     .compareTo(calculateRemainingTime(b.data)));

      activeSchedules.sort((a, b) {
        return calculateRemainingTime(
                DateTimeService.getDateWithHourAndMinuteSet(a.hour, a.minute))
            .compareTo(calculateRemainingTime(
                DateTimeService.getDateWithHourAndMinuteSet(b.hour, b.minute)));
      });

      // Handle the weekday stuff []
      // DateTimeService.timeNow.weekday;
      activeSchedules = activeSchedules
          .where(
              (item) => item.weekDaysIndex[DateTimeService.timeNow.weekday % 7])
          .toList();

      // UserInfo.preferences.setStringList(key, value)
      return activeSchedules;
      // Print
    } else {
      log("No items active, so no schedule will be set");
      // Send schedule to ESP32
      return [];
    }
  }

  Expanded setScheduleButtonWidget() {
    // Homepage.isScheduleSetToDevice = false;
    // Schedule.scheduleIsSet = false;
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(getadaptiveTextSize(context, 8)),
        width: MediaQuery.of(context).size.width,
        child: MaterialButton(
            onPressed: () {
              // Create a new window for managing schedules
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 250),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const SchedulePage(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.0,
                            end: 1.0,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOut,
                            ),
                          ),
                          child: child,
                        );
                      })).then((_) {
                // // Simply update page after exiting the page
                setState(() {});
                Homepage.wentToSchedule = true;
              });
            },
            padding: EdgeInsets.fromLTRB(0, getadaptiveTextSize(context, 4), 0,
                getadaptiveTextSize(context, 4)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            color: Theme.of(context).unselectedWidgetColor,
            elevation: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Set Schedule",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontFamily: 'Poppins',
                          fontSize: getadaptiveTextSize(context, 24),
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: Theme.of(context).primaryColor,
                    )),
              ],
            )),
      ),
    );
  }

  Expanded uvLightButtonWidget() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(getadaptiveTextSize(context, 8)),
        width: MediaQuery.of(context).size.width,
        child: MaterialButton(
            onPressed: UserInfo.isUVLightActivated
                ? () async {
                    log("Deactivating UV Light!");
                    MQTT.publish(
                        "${UserInfo.productId}/uvlight_duration", "stop");
                    UserInfo.isUVLightActivated = false;
                    await UVLightHandler().removeFile();
                    setState(() {});
                  }
                : () {
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
                          child: const EnableUVLightDialog(),
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 500),
                    ).then((_) => setState(() {}));
                  },
            padding: EdgeInsets.fromLTRB(0, getadaptiveTextSize(context, 4), 0,
                getadaptiveTextSize(context, 4)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            color: UserInfo.isUVLightActivated
                ? Theme.of(context).primaryColor
                : Theme.of(context).unselectedWidgetColor,
            elevation: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      UserInfo.isUVLightActivated
                          ? "Deactivate UV Light"
                          : "Activate UV Light",
                      style: TextStyle(
                          color: UserInfo.isUVLightActivated
                              ? Theme.of(context).unselectedWidgetColor
                              : Theme.of(context).primaryColor,
                          fontFamily: 'Poppins',
                          fontSize: getadaptiveTextSize(context, 24),
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: UserInfo.isUVLightActivated
                          ? Theme.of(context).unselectedWidgetColor
                          : Theme.of(context).primaryColor,
                    )),
              ],
            )),
      ),
    );
  }

  Expanded activityLogButtonWidget() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(getadaptiveTextSize(context, 8)),
        width: MediaQuery.of(context).size.width,
        child: MaterialButton(
            onPressed: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 250),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const ActivityLogPage(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.0,
                            end: 1.0,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOut,
                            ),
                          ),
                          child: child,
                        );
                      }));

              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => const ActivityLogPage())).then((_) {
              //   // // Simply update page after exiting the page
              //   setState(() {});
              // });
            },
            padding: EdgeInsets.fromLTRB(0, getadaptiveTextSize(context, 4), 0,
                getadaptiveTextSize(context, 4)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            color: Theme.of(context).unselectedWidgetColor,
            elevation: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "View Activity Log",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontFamily: 'Poppins',
                          fontSize: getadaptiveTextSize(context, 24),
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: Theme.of(context).primaryColor,
                    )),
              ],
            )),
      ),
    );
  }

  List<Widget> animateQuote() {
    if (Quotes.hasQuote == true && Quotes.isAlreadyAnimated == false) {
      // Reverse boolean value
      Quotes.isAlreadyAnimated = true;
      return [
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(
              left: getadaptiveTextSize(context, 16),
              right: getadaptiveTextSize(context, 16)),
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                Quotes.message,
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                    // color: Theme.of(context).primaryColorLight,
                    fontWeight: FontWeight.w300,
                    fontFamily: "Poppins",
                    fontSize: getadaptiveTextSize(context, 12)),
              )
            ],
            repeatForever: false,
            totalRepeatCount: 1,
            displayFullTextOnTap: true,
          ),
        ),

        // AUTHOR
        Container(
          padding: EdgeInsets.all(8),
          alignment: Alignment.topCenter,
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                "— ${Quotes.author}",
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                    // color: Theme.of(context).primaryColorLight,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                    fontSize: getadaptiveTextSize(context, 14)),
              )
            ],
            repeatForever: false,
            totalRepeatCount: 1,
            displayFullTextOnTap: true,
          ),
        ),
      ];
    } else if (Quotes.hasQuote == true && Quotes.isAlreadyAnimated == true) {
      return [
        Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(
                left: getadaptiveTextSize(context, 16),
                right: getadaptiveTextSize(context, 16)),
            child: Text(
              Quotes.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontFamily: "Poppins",
                  fontSize: getadaptiveTextSize(context, 12)),
            )),
        Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.topCenter,
            child: Text(
              "— ${Quotes.author}",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w300,
                  fontStyle: FontStyle.italic,
                  fontSize: getadaptiveTextSize(context, 14)),
            )),
      ];
    }
    return [];
  }
}

Container modeIdentifierWidget(BuildContext context, bool isAutomaticMode) {
  final automaticModeFontColor = Color.fromARGB(255, 9, 104, 18);
  final manualModeFontColor = Color.fromARGB(255, 129, 111, 5);
  return Container(
      margin: const EdgeInsets.only(top: 64, bottom: 4, right: 16),
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.bottomRight,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(isAutomaticMode == true ? "Automatic Mode" : "Manual Mode",
            style: TextStyle(
                color: isAutomaticMode == true
                    ? automaticModeFontColor
                    : manualModeFontColor,
                fontFamily: 'Poppins',
                fontSize: getadaptiveTextSize(context, 14))),
      ));
}

Container headlineAutomaticWidget(BuildContext context) {
  return Container(
      margin: const EdgeInsets.only(right: 16),
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.topRight,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text("Feeding Time",
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontFamily: 'Poppins',
                fontSize: getadaptiveTextSize(context, 50),
                fontWeight: FontWeight.bold)),
      ));
}

Container subHeadlineWidget(BuildContext context, DateTime activeSchedule) {
  return Container(
      margin: const EdgeInsets.only(right: 16, top: 8, bottom: 4),
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.topRight,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(
            DateFormat('h:mm a')
                // .format(scheduledTimes[scheduleRotationIndex]),
                .format(activeSchedule),
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontFamily: 'Poppins',
                fontSize: getadaptiveTextSize(context, 48),
                fontWeight: FontWeight.w300)),
      ));
}

Container countdownWidget(DateTime activeSchedule) {
  return Container(
      margin: const EdgeInsets.only(right: 16, bottom: 24),
      alignment: Alignment.topRight,
      // width: MediaQuery.of(context).size.width,
      child: TimeCountdown(futureTime: activeSchedule));
}

// UNDECIDED
Container feedButtonWidget(BuildContext context) {
  return Container(
    alignment: Alignment.center,
    // margin: const EdgeInsets.only(bottom: 16),
    child: ElevatedButton(
      onPressed: () {
        // showDialog(
        //     context: context,
        //     barrierDismissible: false,
        //     builder: (context) => FeedMeDialog());
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
              child: const FeedMeDialog(),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).unselectedWidgetColor,
        padding: const EdgeInsets.only(left: 32, right: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text("FEED NOW",
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontFamily: 'Poppins',
              fontSize: getadaptiveTextSize(context, 16),
              fontWeight: FontWeight.bold)),
    ),
  );
}

String greeting() {
  // var hour = DateTime.now().hour;
  if (DateTimeService.timeNow.hour < 12) {
    return 'Good Morning,';
  }
  if (DateTimeService.timeNow.hour < 17) {
    return 'Good Afternoon,';
  }
  return 'Good Evening,';
}

class FeedMeDialog extends StatefulWidget {
  const FeedMeDialog({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FeedMeDialogState createState() => _FeedMeDialogState();
}

class _FeedMeDialogState extends State<FeedMeDialog> {
  late StreamSubscription subscription;
  double _sliderValue = 1.0;
  bool starting = true;
  bool failed = false;
  bool done = false;
  String? status = "Waiting for response...";
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    // Listen for MQTT messages
    // Subscribe to the needed topic
    MQTT.client.subscribe(
        "${UserInfo.productId}/feed_duration_response", MqttQos.exactlyOnce);
    subscription =
        MQTT.client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String message =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      if (c[0].topic == "${UserInfo.productId}/feed_duration_response" &&
          message == "true") {
        setState(() => status = "Dispensing food now");
        // Close the dialog
        // Wait for the dispense to finish then pop out the context saying "Success"
        Timer(Duration(seconds: _sliderValue.toInt() - 3), () {
          setState(() {
            failed = false;
            done = true;
          });
        });
        Timer(Duration(seconds: _sliderValue.toInt()), () {
          Navigator.of(context).pop();
        });
      }
    });
  }

  @override
  void dispose() {
    if (_timeoutTimer != null && _timeoutTimer!.isActive) {
      _timeoutTimer!.cancel();
    }
    // Unsubscribe from MQTT messages
    MQTT.client.unsubscribe("${UserInfo.productId}/feed_duration_response");
    subscription.cancel();

    // Send in success log to database
    if (done == true && failed == false) {
      sendInSuccessLogToDatabase();
    } else {
      sendInFailLogToDatabase();
    }

    super.dispose();
  }

  sendInSuccessLogToDatabase() async {
    // User already has logs in the database
    String requestURL =
        "${dotenv.env['CRUD_API']!}/api/logs/client/${UserInfo.productId}";
    String jsonBody = convert.json.encode({
      'type': "Feed Log",
      'didFail': false,
      'duration': _sliderValue.toInt(),
      'dateFinished': DateTimeService.getCurrentDateTimeFormatted(),
    });
    log(requestURL);
    final response = await http.post(Uri.parse(requestURL),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonBody);

    if (response.statusCode == 200) {
      log("Successfully added item log on database");
    } else {
      log("Failed to add item log on database");
    }
  }

  sendInFailLogToDatabase() async {
    String requestURL =
        "${dotenv.env['CRUD_API']!}/api/logs/client/${UserInfo.productId}";
    String jsonBody = convert.json.encode({
      'type': "Feed Log",
      'didFail': true,
      'duration': _sliderValue.toInt(),
      'dateFinished': DateTimeService.getCurrentDateTimeFormatted(),
    });
    log(requestURL);
    final response = await http.post(Uri.parse(requestURL),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonBody);

    if (response.statusCode == 200) {
      log("Successfully added item log on database");
    } else {
      log("Failed to add item log on database");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (starting == true && failed == false) {
      return AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "Dispense food",
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "Duration (in seconds):",
            ),
            Slider(
              thumbColor: Theme.of(context).secondaryHeaderColor,
              activeColor: Theme.of(context).secondaryHeaderColor,
              inactiveColor: Theme.of(context).unselectedWidgetColor,
              value: _sliderValue,
              min: 1.0,
              max: 5.0,
              divisions: 4,
              onChanged: (newValue) {
                setState(() {
                  _sliderValue = newValue;
                });
              },
            ),
            Text(
              _sliderValue == 1.0
                  ? "${_sliderValue.toInt()} second"
                  : "${_sliderValue.toInt()} seconds",
              // style: TextStyle(color: Theme.of(context).primaryColorLight),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text("Cancel",
                style: TextStyle(color: Theme.of(context).primaryColor)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(
              "Feed",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            onPressed: () {
              // Handle MQTT here
              MQTT.publish("${UserInfo.productId}/feed_duration",
                  (_sliderValue.toInt() * 1000).toString());
              setState(() {
                starting = false;
              });
              _timeoutTimer = Timer(Duration(seconds: 15), () {
                setState(() {
                  failed = true;
                });
              });
            },
          ),
        ],
      );
    } else if (starting == false && failed == false) {
      if (done == false) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          content: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CircularProgressIndicator(),
              Text(
                status as String,
                // style: TextStyle(color: Theme.of(context).primaryColorLight),
              ),
            ],
          ),
        );
      } else if (done == true) {
        // Show success
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          content: Text(
            "Successfully dispensed food",
            // style: TextStyle(color: Theme.of(context).primaryColorLight)
          ),
        );
      }
    }

    // FAILS
    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      content: Text(
        "Failed to dispense food",
        // style: TextStyle(color: Theme.of(context).primaryColorLight)
      ),
      actions: [
        TextButton(
          child: Text("Close",
              style: TextStyle(color: Theme.of(context).primaryColor)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class EnableUVLightDialog extends StatefulWidget {
  const EnableUVLightDialog({super.key});

  @override
  State<EnableUVLightDialog> createState() => _EnableUVLightDialogState();
}

class _EnableUVLightDialogState extends State<EnableUVLightDialog> {
  late StreamSubscription subscription;
  double _sliderValue = 15.0;
  bool starting = true;
  bool failed = false;
  bool done = false;
  String? status = "Waiting for response...";
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();

    // Listen for MQTT messages
    // Subscribe to the needed topic
    MQTT.client.subscribe(
        "${UserInfo.productId}/uvlight_duration_response", MqttQos.exactlyOnce);
    subscription = MQTT.client.updates!
        .listen((List<MqttReceivedMessage<MqttMessage>> c) async {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String message =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      if (c[0].topic == "${UserInfo.productId}/uvlight_duration_response" &&
          message == "true") {
        setState(() {
          status = "UV Light is turned on";
        });
        await UVLightHandler().startTimer(_sliderValue.toInt());
        await UVLightHandler().saveStateToFile(_sliderValue.toInt());
        // Wait for the dispense to finish then pop out the context saying "Success"
        Timer(Duration(seconds: 5), () {
          setState(() {
            failed = false;
            done = true;
          });
        });
        Timer(Duration(seconds: 7), () {
          Navigator.of(context).pop();
        });
      }
    });
  }

  @override
  void dispose() {
    if (_timeoutTimer != null && _timeoutTimer!.isActive) {
      _timeoutTimer!.cancel();
    }
    // Unsubscribe from MQTT messages
    MQTT.client.unsubscribe("${UserInfo.productId}/uvlight_duration_response");
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (starting == true && failed == false) {
      return AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "Turn on UV Light",
          // style: TextStyle(color: Theme.of(context).primaryColorLight)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "Duration (in minutes):",
              // style: TextStyle(color: Theme.of(context).primaryColorLight)
            ),
            // ),
            Slider(
              thumbColor: Theme.of(context).secondaryHeaderColor,
              activeColor: Theme.of(context).secondaryHeaderColor,
              inactiveColor: Theme.of(context).unselectedWidgetColor,
              value: _sliderValue,
              min: 1.0,
              max: 60,
              divisions: 59,
              onChanged: (newValue) {
                setState(() {
                  _sliderValue = newValue;
                });
              },
            ),
            Text(
              _sliderValue == 1.0
                  ? "${_sliderValue.toInt()} minute"
                  : "${_sliderValue.toInt()} minutes",
              // style: TextStyle(color: Theme.of(context).primaryColorLight
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text("Cancel",
                style: TextStyle(color: Theme.of(context).primaryColor)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text("Enable",
                style: TextStyle(color: Theme.of(context).primaryColor)),
            // ),
            onPressed: () {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      title: Text(
                        "Warning",
                        // style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      // contentTextStyle: TextStyle(color: Theme.of(context).primaryColor),
                      content: RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                          text:
                              "Extended exposure to UVC-Light can be harmful to your pet's skin and eyes. We recommend using this feature for",
                          style: TextStyle(
                            color: Theme.of(context).secondaryHeaderColor,
                            // color: Colors.black,
                            fontSize: 16.0,
                          ),
                          children: [
                            TextSpan(
                                text: " no longer than 30 minutes at a time",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                )),
                            TextSpan(
                                text:
                                    ", avoid direct exposure to the light while it is on.",
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor)),
                            TextSpan(
                              text:
                                  " UVC-Light can cause skin and eye damage if used improperly. ",
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color:
                                      Theme.of(context).secondaryHeaderColor),
                            ),
                            TextSpan(
                              text: "\n\nPlease use with caution!",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: getadaptiveTextSize(context, 20)),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Cancel",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor)),
                        ),
                        TextButton(
                          onPressed: () {
                            // Handle MQTT here
                            int durationInMs = _sliderValue.toInt() * 60000;
                            MQTT.publish(
                                "${UserInfo.productId}/uvlight_duration",
                                durationInMs.toString());

                            Navigator.of(context).pop();
                            setState(() {
                              starting = false;
                            });
                            _timeoutTimer = Timer(Duration(seconds: 15), () {
                              setState(() {
                                failed = true;
                              });
                            });
                          },
                          child: Text("Continue",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor)),
                        ),
                      ],
                    );
                  });
            },
          ),
        ],
      );
    } else if (starting == false && failed == false) {
      if (done == false) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          content: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CircularProgressIndicator(),
              Text(status as String),
            ],
          ),
        );
      } else if (done == true) {
        // Show success
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          content: Text("Successfully activated UV light"),
        );
      }
    }

    // FAILS
    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      content: Text("Failed to enable UV light"),
      actions: [
        TextButton(
          child: Text("Close"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
