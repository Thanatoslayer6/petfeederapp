import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
              child: const Text(
                "CleverFeeder",
                style: TextStyle(
                    color: Color.fromARGB(255, 33, 31, 103),
                    fontFamily: 'Poppins',
                    fontSize: 20,
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);
}

class ClockWidget extends StatelessWidget {
  const ClockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        return Text(
            DateFormat('EEE, MMM d yyyy - h:mm:ss a').format(DateTime.now()),
            textAlign: TextAlign.left,
            style: const TextStyle(
                color: Color.fromARGB(255, 33, 31, 103),
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400));
      },
    );
  }
}
