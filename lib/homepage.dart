import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petfeederapp/main.dart';
import 'adaptive.dart';
import 'time.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final automaticModeFontColor = const Color.fromARGB(255, 9, 104, 18);
  final manualModeFontColor = const Color.fromARGB(255, 129, 111, 5);
  bool isAutomaticMode = true;
  int scheduleRotationIndex = 0;
  // ignore: unused_local_variable

  // Lists in dart have methods such as .add() and .remove()
  // For instance, we set scheduled time to 5:30 AM
  var scheduledTimes = [
    DateTime(DateTimeService.timeNow.year, DateTimeService.timeNow.month,
        DateTimeService.timeNow.day, 13, 30),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
              margin: const EdgeInsets.only(top: 16, bottom: 8, right: 16),
              width: MediaQuery.of(context).size.width,
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
                        fontSize: getadaptiveTextSize(context, 14))),
              )),
        ),
        Expanded(
          child:
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
                            fontSize: getadaptiveTextSize(context, 50),
                            fontWeight: FontWeight.bold)),
                  )),
        ),
        Expanded(
          child:
              // ignore: avoid_unnecessary_containers
              Container(
                  margin: const EdgeInsets.only(bottom: 8, right: 16),
                  width: MediaQuery.of(context).size.width,
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
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          alignment: Alignment.topRight,
          width: MediaQuery.of(context).size.width,
          child:
              TimeCountdown(futureTime: scheduledTimes[scheduleRotationIndex]),
        ),
        Expanded(
          child:
              // ignore: avoid_unnecessary_containers
              Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 243, 243, 243),
                padding: const EdgeInsets.only(left: 32, right: 32),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: Text("Feed Now",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 33, 31, 103),
                      fontFamily: 'Poppins',
                      fontSize: getadaptiveTextSize(context, 14),
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(getadaptiveTextSize(context, 8)),
            width: MediaQuery.of(context).size.width,
            child: MaterialButton(
                onPressed: () async {
                  // Logic for setting schedule
                  TimeOfDay? pickedTime = await showTimePicker(
                    initialTime: TimeOfDay.now(),
                    context: context,
                  );
                  // Increment to next schedule: TESTING
                  // scheduleRotationIndex++;
                  setState(() {
                    scheduleRotationIndex++;
                    if (pickedTime != null) {
                      scheduledTimes.add(DateTime(
                          DateTimeService.timeNow.year,
                          DateTimeService.timeNow.month,
                          DateTimeService.timeNow.day,
                          pickedTime.hour,
                          pickedTime.minute));
                    }
                  });
                  // Outputs 24hour time
                  // print(pickedTime);
                  // print(scheduleRotationIndex);
                  // print(scheduledTimes);
                },
                padding: EdgeInsets.fromLTRB(0, getadaptiveTextSize(context, 4),
                    0, getadaptiveTextSize(context, 4)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
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
                        child: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.menu_rounded))),
                  ],
                )),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(getadaptiveTextSize(context, 8)),
            width: MediaQuery.of(context).size.width,
            child: MaterialButton(
                onPressed: () {},
                padding: EdgeInsets.fromLTRB(0, getadaptiveTextSize(context, 4),
                    0, getadaptiveTextSize(context, 4)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
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
                        child: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.menu_rounded))),
                  ],
                )),
          ),
        ),
        Expanded(
            child: Container(
          padding: EdgeInsets.all(getadaptiveTextSize(context, 8)),
          width: MediaQuery.of(context).size.width,
          child: MaterialButton(
              onPressed: () {},
              // padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              padding: EdgeInsets.fromLTRB(0, getadaptiveTextSize(context, 4),
                  0, getadaptiveTextSize(context, 4)),
              // color: Colors.grey,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
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
                        isAutomaticMode == true
                            ? "Manual Mode"
                            : "Automatic Mode",
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
                      child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.menu_rounded))),
                ],
              )),
        )),
      ],
    );
  }
}




// class Homepage extends StatelessWidget {
//   const Homepage({super.key});

  
// }
