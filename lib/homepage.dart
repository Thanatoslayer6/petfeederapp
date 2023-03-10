// ignore_for_file: prefer_const_constructors
import 'dart:async';
import 'dart:convert' as convert;
import 'package:flutter_background_service/flutter_background_service.dart';
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
  // ignore: prefer_typing_uninitialized_variables
  static var activeSchedules;
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    super.initState();
    // Gets random quote if possible
    if (Quotes.hasQuote == false) {
      Quotes.getRandom().then((value) {
        print(value);
        setState(() {});
      });
    }
    // // Connect to the MQTT Broker
    if (MQTT.isConnected == false) {
      MQTT.connectToBroker("${UserInfo.productId}-${const Uuid().v1()}");
    }
    // Get saved contents of schedules
    Schedule.loadSchedule();
  }

  @override
  Widget build(BuildContext context) {
    Homepage.activeSchedules = getScheduleInOrder();
    // Send schedule to the ESP32
    if (Homepage.wentToSchedule == true) {
      print(
          "Setting up schedule if user changes something... else this statement is meaningless");
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
      print(payload);
      if (minifiedDateTime.isEmpty) {
        print("Sending default values to microcontroller");
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
            // color: Colors.red,
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.sp,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      // GREETING HEADER
                      Container(
                        // color: Colors.yellow,
                        // alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(top: 16, bottom: 8),
                        child: Text(greeting(),
                            style: TextStyle(
                                color: const Color.fromARGB(255, 33, 31, 103),
                                fontFamily: 'Poppins',
                                fontSize: getadaptiveTextSize(context, 48),
                                fontWeight: FontWeight.bold)),
                      ),
                      // isQuoteAlreadyAnimated == true ? animateQuote(false) : animateQuote(true),
                      // Some ternary condition superiority is shown xD
                      // ...((Quotes.isAlreadyAnimated == true)
                      //     ? animateQuote(false)
                      //     : animateQuote(true)),
                      ...animateQuote(),
                      // isQuoteAlreadyAnimated == true
                      //     ? animateQuote(false)
                      //     : animateQuote(true),
                      feedButtonWidget(context)
                    ],
                  ),
                ),
              ],
            ),
          ),
          // BUTTONS BELOW,
          setScheduleButtonWidget(), // Set schedule
          // feedButtonWidget(context), // DISABLE FEED ME FOR NOW....
          uvLightButtonWidget(), // Enable/Disable uv light
          // setModeButtonWidget()
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
      print("No items active, so no schedule will be set");
      // Send schedule to ESP32
      return [];
    }
  }

  Expanded setScheduleButtonWidget() {
    // Homepage.isScheduleSetToDevice = false;
    // Schedule.scheduleIsSet = false;
    return Expanded(
      child: Container(
        // color: Colors.amber,
        padding: EdgeInsets.all(getadaptiveTextSize(context, 8)),
        width: MediaQuery.of(context).size.width,
        child: MaterialButton(
            onPressed: () {
              // Create a new window for managing schedules
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SchedulePage())).then((_) {
                // // Simply update page after exiting the page
                setState(() {});
                Homepage.wentToSchedule = true;
              });
            },
            padding: EdgeInsets.fromLTRB(0, getadaptiveTextSize(context, 4), 0,
                getadaptiveTextSize(context, 4)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            color: const Color.fromARGB(255, 243, 243, 243),
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
                          color: const Color.fromARGB(255, 33, 31, 103),
                          fontFamily: 'Poppins',
                          fontSize: getadaptiveTextSize(context, 24),
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(Icons.keyboard_arrow_right_rounded)),
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
            onPressed: () {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => EnableUVLightDialog());
            },
            padding: EdgeInsets.fromLTRB(0, getadaptiveTextSize(context, 4), 0,
                getadaptiveTextSize(context, 4)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            color: const Color.fromARGB(255, 243, 243, 243),
            elevation: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Enable UV Light",
                      style: TextStyle(
                          color: const Color.fromARGB(255, 33, 31, 103),
                          fontFamily: 'Poppins',
                          fontSize: getadaptiveTextSize(context, 24),
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(Icons.keyboard_arrow_right_rounded)),
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
                  MaterialPageRoute(
                      builder: (context) => const ActivityLogPage())).then((_) {
                // // Simply update page after exiting the page
                setState(() {});
              });
            },
            padding: EdgeInsets.fromLTRB(0, getadaptiveTextSize(context, 4), 0,
                getadaptiveTextSize(context, 4)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            color: const Color.fromARGB(255, 243, 243, 243),
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
                          color: const Color.fromARGB(255, 33, 31, 103),
                          fontFamily: 'Poppins',
                          fontSize: getadaptiveTextSize(context, 24),
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(Icons.keyboard_arrow_right_rounded)),
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
          // color: Colors.green,
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
                    fontWeight: FontWeight.w300,
                    fontFamily: "Poppins",
                    fontSize: getadaptiveTextSize(context, 12)),
              )
            ],
            // isRepeatingAnimation: false,
            repeatForever: false,
            totalRepeatCount: 1,
            // displayFullTextOnTap: true,
          ),
        ),

        // AUTHOR
        Container(
          // color: Colors.orange,
          padding: EdgeInsets.all(8),
          alignment: Alignment.topCenter,
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                "??? ${Quotes.author}",
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                    fontSize: getadaptiveTextSize(context, 14)),
              )
            ],
            // isRepeatingAnimation: false,
            repeatForever: false,
            totalRepeatCount: 1,
            // displayFullTextOnTap: true,
          ),
        ),
      ];
    } else if (Quotes.hasQuote == true && Quotes.isAlreadyAnimated == true) {
      return [
        Container(
            // color: Colors.green,
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

        // AUTHOR
        Container(
            // color: Colors.orange,
            padding: EdgeInsets.all(8),
            alignment: Alignment.topCenter,
            child: Text(
              "??? ${Quotes.author}",
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
      // margin: const EdgeInsets.only(top: 16, bottom: 4, right: 16),
      width: MediaQuery.of(context).size.width,
      // color: Colors.orange,
      alignment: Alignment.topRight,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text("Feeding Time",
            style: TextStyle(
                color: const Color.fromARGB(255, 33, 31, 103),
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
                color: const Color.fromARGB(255, 33, 31, 103),
                fontFamily: 'Poppins',
                fontSize: getadaptiveTextSize(context, 48),
                fontWeight: FontWeight.w300)),
      ));
}

Container countdownWidget(DateTime activeSchedule) {
  return Container(
      // color: Colors.red,
      margin: const EdgeInsets.only(right: 16, bottom: 24),
      alignment: Alignment.topRight,
      // width: MediaQuery.of(context).size.width,
      child: TimeCountdown(futureTime: activeSchedule));
}

// UNDECIDED
Container feedButtonWidget(BuildContext context) {
  return Container(
    // color: Colors.amber,
    alignment: Alignment.center,
    // margin: const EdgeInsets.only(bottom: 16),
    child: ElevatedButton(
      onPressed: () {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => FeedMeDialog());
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 243, 243, 243),
        padding: const EdgeInsets.only(left: 32, right: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text("FEED NOW",
          style: TextStyle(
              color: const Color.fromARGB(255, 33, 31, 103),
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
  // TODO: BEAUTIFY
  late StreamSubscription subscription;
  double _sliderValue = 1.0;
  bool starting = true;
  bool failed = false;
  bool done = false;
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
        setState(() {
          failed = false;
          done = true;
          // Close the dialog
          // Wait for the dispense to finish then pop out the context saying "Success"
          Timer(Duration(seconds: _sliderValue.toInt()), () {
            Navigator.of(context).pop();
          });
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
    // String requestURL = "";
    // String jsonBody = "";
    // bool newUserWithNoLogs = false;
    // First check if the user already has a collection within the database
    /*
    final String checkDatabaseURL =
        "${dotenv.env['CRUD_API']!}/api/logs/client/${UserInfo.productId}";
    var responseDatabase = await http.get(Uri.parse(checkDatabaseURL));
    var jsonResponseDatabase =
        convert.jsonDecode(responseDatabase.body) as Map<String, dynamic>;

    print(jsonResponseDatabase['data'].toString());

    if (jsonResponseDatabase['data'].length > 0) {
      print("User has logs in the database... just setting it up");
      // User already has logs in the database
      requestURL =
          "${dotenv.env['CRUD_API']!}/api/logs/client/${UserInfo.productId}";
      // var response = await http.get(Uri.parse(requestURL));
      jsonBody = convert.json.encode({
        'type': "Feed Log",
        'didFail': false,
        'duration': _sliderValue.toInt(),
        'dateFinished': DateTimeService.getCurrentDateTimeFormatted(),
      });
    } else {
      newUserWithNoLogs = true;
      print(
          "User doesn't have logs in the database... will send a creation payload");
      // Create a log collection for the user
      requestURL = "${dotenv.env['CRUD_API']!}/api/logs/";
      // var response = await http.get(Uri.parse(requestURL));
      jsonBody = convert.json.encode({
        'client': UserInfo.productId,
        'items': [
          {
            'type': "Feed Log",
            'didFail': false,
            'duration': _sliderValue.toInt(),
            'dateFinished': DateTimeService.getCurrentDateTimeFormatted(),
          }
        ]
      });
    }
    */

    // User already has logs in the database
    String requestURL =
        "${dotenv.env['CRUD_API']!}/api/logs/client/${UserInfo.productId}";
    String jsonBody = convert.json.encode({
      'type': "Feed Log",
      'didFail': false,
      'duration': _sliderValue.toInt(),
      'dateFinished': DateTimeService.getCurrentDateTimeFormatted(),
    });
    print(requestURL);
    final response = await http.post(Uri.parse(requestURL),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonBody);

    if (response.statusCode == 200) {
      // if (newUserWithNoLogs == true) {
      //   var jsonResponse =
      //       convert.jsonDecode(response.body) as Map<String, dynamic>;

      //   History.generalHistoryDatabaseId = jsonResponse['data']['_id'];
      //   print(History.generalHistoryDatabaseId);

      //   UserInfo.preferences.setString(
      //       'generalHistoryDatabaseId', History.generalHistoryDatabaseId);
      //   print("Successfully added item log on database as a new user...");
      // } else {
      //   print("Successfully added item log on database");
      // }
      print("Successfully added item log on database");
      // History.didUserUpdate = true;
    } else {
      print("Failed to add item log on database");
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
    print(requestURL);
    final response = await http.post(Uri.parse(requestURL),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonBody);

    if (response.statusCode == 200) {
      print("Successfully added item log on database");
      // History.didUserUpdate = true;
    } else {
      print("Failed to add item log on database");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (starting == true && failed == false) {
      return AlertDialog(
        title: Text("Dispense food"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text("Duration (in seconds):"),
            Slider(
              value: _sliderValue,
              min: 1.0,
              max: 10.0,
              divisions: 9,
              onChanged: (newValue) {
                setState(() {
                  _sliderValue = newValue;
                });
              },
            ),
            Text(_sliderValue == 1.0
                ? "${_sliderValue.toInt()} second"
                : "${_sliderValue.toInt()} seconds"),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text("Feed"),
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
          content: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              CircularProgressIndicator(),
              Text("Waiting for response"),
            ],
          ),
        );
      } else if (done == true) {
        // Show success
        return AlertDialog(
          content: Text("Successfully dispensed food"),
        );
      }
    }

    // FAILS
    return AlertDialog(
      content: Text("Failed to dispense food"),
      actions: [
        TextButton(
          child: Text("Ok"),
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
  // TODO: BEAUTIFY
  late StreamSubscription subscription;
  double _sliderValue = 1.0;
  bool starting = true;
  bool failed = false;
  bool done = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    // Listen for MQTT messages
    // Subscribe to the needed topic
    MQTT.client.subscribe(
        "${UserInfo.productId}/uvlight_duration_response", MqttQos.exactlyOnce);
    subscription =
        MQTT.client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String message =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      if (c[0].topic == "${UserInfo.productId}/uvlight_duration_response" &&
          message == "true") {
        setState(() {
          failed = false;
          done = true;
          // Close the dialog
          // Wait for the dispense to finish then pop out the context saying "Success"
          Timer(Duration(seconds: _sliderValue.toInt()), () {
            Navigator.of(context).pop();
          });
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
        title: Text("Turn on UV Light"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text("Duration (in minutes):"),
            Slider(
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
            Text(_sliderValue == 1.0
                ? "${_sliderValue.toInt()} minute"
                : "${_sliderValue.toInt()} minutes"),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text("Enable"),
            onPressed: () {
              // Handle MQTT here
              MQTT.publish("${UserInfo.productId}/uvlight_duration",
                  (_sliderValue.toInt() * 60000).toString());
              setState(() {
                starting = false;
              });
              _timeoutTimer =
                  Timer(Duration(seconds: _sliderValue.toInt()), () {
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
          content: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              CircularProgressIndicator(),
              Text("Waiting for response"),
            ],
          ),
        );
      } else if (done == true) {
        // Show success
        return AlertDialog(
          content: Text("Successfully enabled UV light"),
        );
      }
    }

    // FAILS
    return AlertDialog(
      content: Text("Failed to enable UV light"),
      actions: [
        TextButton(
          child: Text("Ok"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
