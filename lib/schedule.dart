import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'time.dart';
import 'adaptive.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Schedule",
          style: TextStyle(
              color: const Color.fromARGB(255, 33, 31, 103),
              fontFamily: 'Poppins',
              fontSize: getadaptiveTextSize(context, 24),
              fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color.fromARGB(255, 33, 31, 103)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
          itemCount: Schedule.listOfTimes.length,
          itemBuilder: ((context, index) {
            return ScheduleItem(time: Schedule.listOfTimes[index]);
          })),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.alarm_add_rounded),
        label: const Text("Add Schedule"),
        onPressed: () async {
          // Logic for setting schedule
          TimeOfDay? pickedTime = await showTimePicker(
            initialTime: TimeOfDay.now(),
            context: context,
          );
          // Let the user pick a certain time first...
          if (pickedTime != null) {
            setState(() {
              Schedule.listOfTimes.add(DateTime(
                  DateTimeService.timeNow.year,
                  DateTimeService.timeNow.month,
                  DateTimeService.timeNow.day,
                  pickedTime.hour,
                  pickedTime.minute));
            });

            // TODO: After user picks a time, tell on what day... like everyday? every mon?
          } else {
            // TODO: Decide what to do here...
            // ignore: avoid_print
            print("User cancelled");
            // Just exit
            // Scaffold.of(context).showSnackBar();
          }
        },
      ),
    );
  }
}

class ScheduleItem extends StatelessWidget {
  final DateTime time;
  const ScheduleItem({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      // margin: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 243, 243, 243),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(2, 2), // changes position of shadow
          ),
        ],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        // ignore: avoid_unnecessary_containers
        Container(
          // color: Colors.blue,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('h:mm').format(time),
                style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: getadaptiveTextSize(context, 48),
                    fontWeight: FontWeight.w500),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 6),
                child: Text(
                  DateFormat('a').format(time),
                  style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: getadaptiveTextSize(context, 24),
                      fontWeight: FontWeight.normal),
                ),
              )
            ],
          ),
        )
      ]),
    );
  }
}

class Schedule {
  int scheduleRotationIndex = 0;
  // ignore: unused_local_variable

  // Lists in dart have methods such as .add() and .remove()
  // For instance, we set scheduled time to 5:30 AM
  static List<DateTime> listOfTimes = [
    DateTime(DateTimeService.timeNow.year, DateTimeService.timeNow.month,
        DateTimeService.timeNow.day, 13, 30),
  ];
}
