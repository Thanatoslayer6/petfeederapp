// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'adaptive.dart';
import 'time.dart';
import 'schedule.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // bool isAutomaticMode = true;
  int activeScheduleRotationIndex = 0;
  // List<DateTime> activeSchedules = [];
  @override
  Widget build(BuildContext context) {
    // final automaticModeFontColor = Color.fromARGB(255, 9, 104, 18);
    // final manualModeFontColor = Color.fromARGB(255, 129, 111, 5);
    var activeSchedules = getScheduleInOrder();
    return Column(
      children: [
        // Automatic mode
        if (activeSchedules.isNotEmpty) ...[
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
          // setModeButtonWidget()
        ] else if (activeSchedules.isEmpty) ...[
          modeIdentifierWidget(context, false),
          // Container(
          //   // margin: EdgeInsets.only(top: 48, bottom: 16),
          //   color: Colors.amber,
          //   child: Icon(
          //     Icons.pets_rounded,
          //     size: 128,
          //   ),
          // ),
          // ignore: avoid_unnecessary_containers
          Container(
            // color: Colors.red,
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.sp,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    // color: Colors.green,
                    // margin: EdgeInsets.only(left: 24),
                    child: Icon(Icons.pets_rounded, size: 96),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Container(
                        // color: Colors.yellow,
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(top: 8, bottom: 16),
                        child: Text(greeting(),
                            style: TextStyle(
                                color: const Color.fromARGB(255, 33, 31, 103),
                                fontFamily: 'Poppins',
                                fontSize: getadaptiveTextSize(context, 36),
                                fontWeight: FontWeight.bold)),
                      ),
                      // feedButtonWidget(context)
                    ],
                  ),
                ),
              ],
            ),
          ),
          /*
          Container(
            // color: Colors.amber,
            margin: EdgeInsets.only(top: 16, bottom: 16, left: 32),
            width: MediaQuery.of(context).size.width,
            child: Text(
              "NOTE: Set a schedule for automation",
              style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: getadaptiveTextSize(context, 18),
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w300),
            ),
          ),
          */
          // BUTTONS BELOW,
          setScheduleButtonWidget(), // Set schedule
          // feedButtonWidget(context), // DISABLE FEED ME FOR NOW....
          uvLightButtonWidget(), // Enable/Disable uv light
          // setModeButtonWidget()
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

      // print("Here's your schedule");
      // activeSchedules.forEach((element) {
      //   print(element.data);
      // });
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

/*
  Expanded setModeButtonWidget() {
    return Expanded(
        child: Container(
      padding: EdgeInsets.all(getadaptiveTextSize(context, 8)),
      width: MediaQuery.of(context).size.width,
      child: MaterialButton(
          onPressed: () {
            setState(() {
              isAutomaticMode == true
                  ? isAutomaticMode = false
                  : isAutomaticMode = true;
            });
          },
          // padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          padding: EdgeInsets.fromLTRB(0, getadaptiveTextSize(context, 4), 0,
              getadaptiveTextSize(context, 4)),
          // color: Colors.grey,
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
                    isAutomaticMode == true ? "Manual Mode" : "Automatic Mode",
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
    ));
  }
  */
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
/*
Container headlineManualWidget(BuildContext context) {
  return Container(
      margin: const EdgeInsets.only(right: 16),
      // margin: const EdgeInsets.only(top: 16, bottom: 4, right: 16),
      width: MediaQuery.of(context).size.width,
      color: Colors.orange,
      alignment: Alignment.topRight,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text("Welcome!",
            style: TextStyle(
                color: const Color.fromARGB(255, 33, 31, 103),
                fontFamily: 'Poppins',
                fontSize: getadaptiveTextSize(context, 50),
                fontWeight: FontWeight.bold)),
      ));
}
*/

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
    alignment: Alignment.centerLeft,
    // margin: const EdgeInsets.only(top: 16),
    child: ElevatedButton(
      onPressed: () {},
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
