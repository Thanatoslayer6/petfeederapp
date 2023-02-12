// ignore_for_file: prefer_const_constructors
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'adaptive.dart';
import 'time.dart';
import 'schedule.dart';
import 'quotes.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int activeScheduleRotationIndex = 0;
  bool isQuoteAlreadyAnimated = false;

  @override
  void initState() {
    // Gets random quote if possible
    if (Quotes.hasQuote == false) {
      // Quotes.getRandom(setState);
      Quotes.getRandom();
      setState(() {});
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var activeSchedules = getScheduleInOrder();
    // final automaticModeFontColor = Color.fromARGB(255, 9, 104, 18);
    // final manualModeFontColor = Color.fromARGB(255, 129, 111, 5);
    return Column(
      children: [
        if (activeSchedules.isNotEmpty) ...[
          // AUTOMATIC MODE
          modeIdentifierWidget(context, true), // Automatic Mode ? Manual Mode
          headlineAutomaticWidget(context), // Feeding Time (TIME)
          subHeadlineWidget(
              context,
              activeSchedules[activeScheduleRotationIndex]
                  .data), // HH:MM a (TIME)
          countdownWidget(activeSchedules[activeScheduleRotationIndex].data),
          // BUTTONS BELOW,
          // feedButtonWidget(context), // DISABLE FEED ME FOR NOW....
          setScheduleButtonWidget(), // Set schedule
          uvLightButtonWidget(), // Enable/Disable uv light
          activityLogButtonWidget()
          // setModeButtonWidget()
        ] else if (activeSchedules.isEmpty) ...[
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
                      ...((isQuoteAlreadyAnimated == true)
                          ? animateQuote(true)
                          : animateQuote(false)),
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
      activeSchedules.sort((a, b) => calculateRemainingTime(a.data)
          .compareTo(calculateRemainingTime(b.data)));

      // Handle the weekday stuff []
      // DateTimeService.timeNow.weekday;
      activeSchedules = activeSchedules
          .where(
              (item) => item.weekDaysIndex[DateTimeService.timeNow.weekday % 7])
          .toList();

      return activeSchedules;
      // Print
    } else {
      print("No items active, so no schedule will be set");
    }
    return [];
  }

  Expanded setScheduleButtonWidget() {
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
                // Simply update page after exiting the page
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
            onPressed: () {},
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
            onPressed: () {},
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

  List<Widget> animateQuote(bool withAnimation) {
    if (Quotes.hasQuote == true && withAnimation == true) {
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
                "— ${Quotes.author}",
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
    } else if (Quotes.hasQuote == true && withAnimation == false) {
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
      child:
          // TimeCountdown(futureTime: scheduledTimes[scheduleRotationIndex]),
          // TimeCountdown(futureTime: Schedule.listOfTimes[0].data),
          TimeCountdown(futureTime: activeSchedule));
}

// UNDECIDED
Container feedButtonWidget(BuildContext context) {
  return Container(
    // color: Colors.amber,
    alignment: Alignment.center,
    // margin: const EdgeInsets.only(bottom: 16),
    child: ElevatedButton(
      onPressed: () {
        showDialog(context: context, builder: (context) => FeedMeDialog());
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 243, 243, 243),
        padding: const EdgeInsets.only(left: 32, right: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text("Feed Now",
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
  double _sliderValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Dispense food"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("Duration (in seconds):"),
          Slider(
            value: _sliderValue,
            min: 0.0,
            max: 10.0,
            divisions: 10,
            onChanged: (newValue) {
              setState(() {
                _sliderValue = newValue;
              });
            },
          ),
          Text("$_sliderValue"),
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
            Navigator.of(context).pop();
            // Add code here to send the duration value to the servo motor
          },
        ),
      ],
    );
  }
}
