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
  bool isAutomaticMode = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        modeIdentifierWidget(
            context, isAutomaticMode), // Automatic Mode ? Manual Mode
        headlineWidget(context), // Feeding Time (TIME)
        subHeadlineWidget(context), // HH:MM a (TIME)
        countdownWidget(),
        // BUTTONS BELOW,
        // feedButtonWidget(context), // DISABLE FEED ME FOR NOW....
        setScheduleButtonWidget(), // Set schedule
        uvLightButtonWidget(), // Enable/Disable uv light
        setModeButtonWidget()
      ],
    );
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

Container headlineWidget(BuildContext context) {
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

Container subHeadlineWidget(BuildContext context) {
  return Container(
      margin: const EdgeInsets.only(right: 16, top: 8, bottom: 4),
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.topRight,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(
            DateFormat('h:mm a')
                // .format(scheduledTimes[scheduleRotationIndex]),
                .format(Schedule.listOfTimes[0].data),
            style: TextStyle(
                color: const Color.fromARGB(255, 33, 31, 103),
                fontFamily: 'Poppins',
                fontSize: getadaptiveTextSize(context, 48),
                fontWeight: FontWeight.w300)),
      ));
}

Container countdownWidget() {
  return Container(
    // color: Colors.red,
    margin: const EdgeInsets.only(right: 16, bottom: 24),
    alignment: Alignment.topRight,
    // width: MediaQuery.of(context).size.width,
    child:
        // TimeCountdown(futureTime: scheduledTimes[scheduleRotationIndex]),
        TimeCountdown(futureTime: Schedule.listOfTimes[0].data),
  );
}

// UNDECIDED
Expanded feedButtonWidget(BuildContext context) {
  return Expanded(
    child:
        // ignore: avoid_unnecessary_containers
        Container(
      // color: Colors.amber,
      alignment: Alignment.topRight,
      margin: const EdgeInsets.only(right: 16),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 243, 243, 243),
          padding: const EdgeInsets.only(left: 32, right: 32),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text("Feed Now",
            style: TextStyle(
                color: const Color.fromARGB(255, 33, 31, 103),
                fontFamily: 'Poppins',
                fontSize: getadaptiveTextSize(context, 14),
                fontWeight: FontWeight.bold)),
      ),
    ),
  );
}
