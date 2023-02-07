import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:intl/intl.dart';
//import 'dart:math';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    const automaticModeFontColor = Color.fromARGB(255, 9, 104, 18);
    const manualModeFontColor = Color.fromARGB(255, 129, 111, 5);
    bool isAutomaticMode = true;
    int scheduleRotationIndex = 0;
    // ignore: unused_local_variable
    var scheduledTimes = [
      // For instance, we set scheduled time to 5:30 AM
      DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 5, 30),
    ];
    // Lists in dart have methods such as .add() and .remove()

    return Column(
      children: [
        Container(
            // padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.only(top: 32, bottom: 8, right: 16),
            width: MediaQuery.of(context).size.width,
            // color: Colors.green,
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                  isAutomaticMode == true ? "Automatic Mode" : "Manual Mode",
                  style: TextStyle(
                      color: isAutomaticMode == true
                          ? automaticModeFontColor
                          : manualModeFontColor,
                      fontFamily: 'Poppins',
                      fontSize: getadaptiveTextSize(context, 18))),
            )),
        // ignore: avoid_unnecessary_containers
        Container(
            margin: const EdgeInsets.only(bottom: 8, right: 16),
            width: MediaQuery.of(context).size.width,
            // color: Colors.red,
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text("Feeding Time",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 33, 31, 103),
                      fontFamily: 'Poppins',
                      fontSize: getadaptiveTextSize(context, 60),
                      fontWeight: FontWeight.bold)),
            )),
        // ignore: avoid_unnecessary_containers
        Container(
            margin: const EdgeInsets.only(bottom: 8, right: 16),
            width: MediaQuery.of(context).size.width,
            // color: Colors.red,
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                  DateFormat('h:mm a')
                      .format(scheduledTimes[scheduleRotationIndex]),
                  style: TextStyle(
                      color: const Color.fromARGB(255, 33, 31, 103),
                      fontFamily: 'Poppins',
                      fontSize: getadaptiveTextSize(context, 48),
                      fontWeight: FontWeight.w300)),
            )),
        // ignore: avoid_unnecessary_containers
        Container(
            margin: const EdgeInsets.only(bottom: 8, right: 16),
            width: MediaQuery.of(context).size.width,
            // color: Colors.red,
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.contain,
              child: TimeCountdown(
                  futureTime: scheduledTimes[scheduleRotationIndex]),
              //   child: Text(,
              //       style: TextStyle(
              //           color: const Color.fromARGB(255, 33, 31, 103),
              //           fontFamily: 'Poppins',
              //           fontSize: getadaptiveTextSize(context, 18),
              //           fontWeight: FontWeight.w300)),
            ))
      ],
    );
  }

  double getadaptiveTextSize(BuildContext context, dynamic value) {
    // 720 is medium screen height
    // return (value / 720) * size.height;
    return (value / 720) * MediaQuery.of(context).size.height;
  }
}

// ignore: must_be_immutable
class TimeCountdown extends StatelessWidget {
  DateTime futureTime;

  TimeCountdown({super.key, required this.futureTime});

  @override
  Widget build(BuildContext context) {
    Duration schedule = calculateRemainingTime(futureTime);
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        return Text(
            "${schedule.inHours} hours and ${schedule.inMinutes.remainder(60)} minutes left",
            // "${schedule.inHours} hours, ${schedule.inMinutes.remainder(60)} minutes and ${(schedule.inSeconds.remainder(60))} seconds left",

            // Pass in the schedule (Hour/s, Minute/s)
            // getRemainingTimeAsString(schedule.inHours, schedule.inMinutes),
            // DateFormat('EEE, MMM d yyyy - h:mm:ss a').format(DateTime.now()),
            //textAlign: TextAlign.left,
            style: const TextStyle(
                color: Color.fromARGB(255, 33, 31, 103),
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300));
      },
    );
  }
}

Duration calculateRemainingTime(DateTime futureTime) {
  return futureTime.difference(DateTime.now());
}

// String getRemainingTimeAsString(int hour, int minute) {
//   String result = "";
//   // Hours
//   if (hour == 0) {
//     result += "";
//   } else if (hour == 1) {
//     result += "1 hour";
//   } else {
//     result += "$hour hours";
//   }
//   // Minutes
//   if (minute == 0) {
//     result += "";
//   } else if (minute == 1) {
//     hour >= 1 ? (result += ", $minute minute") : ("$minute");
//     //result += ", $minute minute";
//   } else {
//     hour >= 1 ? (result += ", $minute minute") : ("$minute");
//     // result += ", $minute minutes";
//   }
//   // TODO: Seconds
//   return result;
// }
/*
class CalculateRemainingTime {
  CalculateRemainingTime(this.futureTime);
  DateTime futureTime;
  //Duration t = futureTime.difference(DateTime.now());
  var t = getDuration();

  String getHoursLeftString() {
    int hours = getDuration().inHours;
    if (hours == 0) {
      return "";
    } else if (hours == 1) {
      return "1 hour";
    } else {
      return "$hours hours";
    }
  }

  Duration getDuration() {
    return futureTime.difference(DateTime.now());
  }

  String getMinutesLeftString() {
    int minutes = getDuration()
  }

  String getTimeRemaining() {
    return "$getHoursLeftString(), $getMinutesLeftString() and left";
  }
}
*/

// class ScaleSize {
//   static double textScaleFactor(BuildContext context,
//       {double maxTextScaleFactor = 2}) {
//     final width = MediaQuery.of(context).size.width;
//     double val = (width / 1400) * maxTextScaleFactor;
//     return max(1, min(val, maxTextScaleFactor));
//   }
// }
// class AdaptiveTextSize {
//   const AdaptiveTextSize();
//   getadaptiveTextSize(BuildContext context, dynamic value) {
//     // 720 is medium screen height
//     return (value / 720) * MediaQuery.of(context).size.height;
//   }
// }
