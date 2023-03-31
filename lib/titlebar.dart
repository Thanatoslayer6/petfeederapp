// ignore_for_file: unnecessary_const

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'adaptive.dart';
import 'time.dart';

class TitleBar extends StatelessWidget implements PreferredSizeWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          children: [
            // ignore: avoid_unnecessary_containers
            Container(
              margin: const EdgeInsets.only(top: 18),
              alignment: Alignment.centerLeft,
              child: Text(
                "CleverFeeder",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontFamily: 'Poppins',
                    fontSize: getadaptiveTextSize(context, 20),
                    fontWeight: FontWeight.bold),
              ),
            ),
            //ignore: avoid_unnecessary_containers
            Container(
              padding: const EdgeInsets.all(6),
              alignment: Alignment.centerLeft,
              child: const ClockWidget(),
            )
          ],
        ));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}

class ClockWidget extends StatelessWidget {
  const ClockWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // stream: Stream.periodic(const Duration(seconds: 1)),
      stream: DateTimeService.stream,
      builder: (context, snapshot) {
        return Text(
            // DateFormat('EEE, MMM d yyyy - h:mm:ss a').format(DateTime.now()),
            DateFormat('EEE, MMM d yyyy - h:mm:ss a')
                .format(DateTimeService.timeNow),
            textAlign: TextAlign.left,
            style: TextStyle(
                // color: const Color.fromARGB(255, 33, 31, 103),
                color: Theme.of(context).primaryColor,
                fontSize: getadaptiveTextSize(context, 14),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400));
      },
    );
  }
}
