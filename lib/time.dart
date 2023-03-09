import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
        }

        if (minutes == 1) {
          timeRemaining += "1 minute and ";
        } else if (minutes > 1) {
          timeRemaining += "$minutes minutes and ";
        } else if (minutes == 0 && hours > 1) {
          timeRemaining += "59 minutes ";
        }

        if (seconds == 1) {
          timeRemaining += "1 second left";
        } else if (seconds > 1) {
          timeRemaining += "$seconds seconds left";
        } else if (seconds == 0 && minutes > 1) {
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

class DateTimeService {
  // ignore: prefer_final_fields
  static StreamController<DateTime> _streamController =
      StreamController<DateTime>.broadcast();

  static void init() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _streamController.add(DateTime.now());
    });
  }

  static Stream<DateTime> get stream => _streamController.stream;

  static DateTime get timeNow => DateTime.now();

  static DateTime getDateWithHourAndMinuteSet(int hour, int minute) {
    return DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, hour, minute);
  }

  static String getCurrentDateTimeFormatted() {
    final now = DateTime.now();
    final dayOfWeek = DateFormat.E().format(now);
    final dayOfMonth = DateFormat.d().format(now);
    final month = DateFormat.MMM().format(now);
    final hourMinute = DateFormat.jm().format(now);

    return '$dayOfWeek $dayOfMonth, $month, $hourMinute';
  }
}
