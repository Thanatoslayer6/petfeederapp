import 'package:flutter/material.dart';
import 'dart:math';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    var currentMode = "Automatic Mode";
    var scheduledTime = "6:00 PM";
    // final HeightSize = MediaQuery.of(context).size.height;
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
              child: Text(currentMode,
                  style: TextStyle(
                      color: const Color.fromARGB(255, 9, 104, 18),
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
              child: Text(scheduledTime,
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
              child: Text("45 minutes and 34 seconds left",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 33, 31, 103),
                      fontFamily: 'Poppins',
                      fontSize: getadaptiveTextSize(context, 18),
                      fontWeight: FontWeight.w200)),
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
