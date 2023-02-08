import 'package:flutter/material.dart';
// import 'dart:async';
import 'main.dart';
import 'adaptive.dart';

// ignore: must_be_immutable
class TimeCountdown extends StatelessWidget {
  DateTime futureTime;

  TimeCountdown({super.key, required this.futureTime});

  @override
  Widget build(BuildContext context) {
    Duration schedule;
    String timeRemaining;
    int hours, minutes, seconds;
    return StreamBuilder(
      // stream: Stream.periodic(const Duration(seconds: 1)),
      stream: DateTimeService.stream,
      builder: (context, snapshot) {
        // Format the following schedule
        schedule = calculateRemainingTime(futureTime);
        hours = schedule.inHours;
        minutes = schedule.inMinutes.remainder(60);
        seconds = schedule.inSeconds.remainder(60);
        timeRemaining = "";

        if (hours == 1) {
          timeRemaining += "1 hour, ";
        } else if (hours > 1) {
          timeRemaining += "$hours hours, ";
        } else {
          // In this case hours will be '0'
          timeRemaining += "59 hours left";
        }

        if (minutes == 1) {
          timeRemaining += "1 minute and ";
        } else if (minutes > 1) {
          timeRemaining += "$minutes minutes and ";
        } else {
          // In this case minutes will be '0'
          timeRemaining += "59 minutes left";
        }

        if (seconds == 1) {
          timeRemaining += "1 second left";
        } else if (seconds > 1) {
          timeRemaining += "$seconds seconds left";
        } else {
          // In this case seconds will be '0'
          timeRemaining += "59 seconds left";
        }

        return Text(timeRemaining,
            style: TextStyle(
                color: const Color.fromARGB(255, 33, 31, 103),
                fontSize: getadaptiveTextSize(context, 14),
                // fontSize: 8,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300));
      },
    );
  }
}

Duration calculateRemainingTime(DateTime futureTime) {
  // Duration remainingTime = futureTime.difference(DateTime.now());
  Duration remainingTime = futureTime.difference(DateTimeService.timeNow);
  if (remainingTime.isNegative) {
    return const Duration(days: 1) + remainingTime;
  } else {
    return remainingTime;
  }
}
