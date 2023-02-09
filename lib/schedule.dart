import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weekday_selector/weekday_selector.dart';
import 'time.dart';
import 'adaptive.dart';
import 'packages/multi_select_item.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  // Set up schedule controller
  MultiSelectController scheduleController = MultiSelectController();
  @override
  void initState() {
    super.initState();
    scheduleController.disableEditingWhenNoneSelected = true;
    scheduleController.set(Schedule.listOfTimes.length);
  }

  @override
  Widget build(BuildContext context) {
    List<bool> values = List.filled(7, false);
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
        actions: scheduleController.isSelecting == true
            ? [
                IconButton(
                  icon: const Icon(Icons.select_all_rounded,
                      color: Color.fromARGB(255, 33, 31, 103)),
                  onPressed: () {
                    setState(() {
                      scheduleController.toggleAll();
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever_rounded,
                      color: Color.fromARGB(255, 33, 31, 103)),
                  onPressed: () {
                    deleteSelectedItems();
                  },
                )
              ]
            : [],
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: Schedule.listOfTimes.length,
        itemBuilder: ((context, index) =>
            scheduleItem(scheduleController, index)),
      ),
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
            addItem(pickedTime);
            // TODO: After user picks a time, tell on what day... like everyday? every mon?
            // Show dialog box
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return WeekdaySelector(
                    onChanged: (int day) {
                      setState(() {
                        // Set all values to false except the "day"th element
                        values = List.filled(7, false, growable: false)
                          ..[day % 7] = true;
                      });
                    },
                    values: values,
                  );
                });
          } else {
            // TODO: Decide what to do here...
            // ignore: avoid_print
            print("User cancelled");
          }
        },
      ),
    );
  }

  void addItem(TimeOfDay pickedTime) {
    // Add schedule
    Schedule.listOfTimes.add(ListItem(DateTime(
        DateTimeService.timeNow.year,
        DateTimeService.timeNow.month,
        DateTimeService.timeNow.day,
        pickedTime.hour,
        pickedTime.minute)));
    setState(() {
      // Update controller length
      scheduleController.set(Schedule.listOfTimes.length);
    });
  }

  void deleteSelectedItems() {
    var list = scheduleController.selectedIndexes;
    // Reoder from biggest number, so it wont error
    list.sort((b, a) => a.compareTo(b));
    // ignore: avoid_function_literals_in_foreach_calls
    list.forEach((element) {
      Schedule.listOfTimes.removeAt(element);
    });
    setState(() {
      scheduleController.set(Schedule.listOfTimes.length);
    });
  }

  Widget scheduleItem(var controller, var index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(3, 4), // changes position of shadow
          ),
        ],
      ),
      margin: const EdgeInsets.all(8),
      child: Material(
        borderRadius: BorderRadius.circular(32),
        color: controller.isSelected(index) == true
            ? const Color.fromARGB(255, 101, 145, 211)
            : const Color.fromARGB(255, 243, 243, 243),
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: () {},
          splashColor: Colors.indigo[50],
          child: MultiSelectItem(
            isSelecting: controller.isSelecting,
            onSelected: () {
              setState(() {
                controller.toggle(index);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: ListTile(
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ignore: avoid_unnecessary_containers
                      Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              DateFormat('h:mm')
                                  .format(Schedule.listOfTimes[index].data),
                              style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: getadaptiveTextSize(context, 48),
                                  fontWeight: FontWeight.w500),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 4, left: 6),
                              child: Text(
                                DateFormat('a')
                                    .format(Schedule.listOfTimes[index].data),
                                style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: getadaptiveTextSize(context, 24),
                                    fontWeight: FontWeight.normal),
                              ),
                            )
                          ],
                        ),
                      ),
                    ]),
                subtitle: Text("Sunday, Monday, Thursday"),
                trailing: Switch(
                    activeColor: const Color.fromARGB(255, 33, 31, 103),
                    value: Schedule.listOfTimes[index].isActive,
                    onChanged: (value) {
                      setState(() {
                        Schedule.listOfTimes[index].isActive = value;
                      });
                    }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Schedule {
  // Lists in dart have methods such as .add() and .remove()
  // For instance, we set scheduled time to 5:30 AM
  static List<ListItem<dynamic>> listOfTimes = [
    ListItem(DateTime(DateTimeService.timeNow.year,
        DateTimeService.timeNow.month, DateTimeService.timeNow.day, 13, 30))
  ];
}

class ListItem<T> {
  // bool isSelected = false; //Selection property to highlight or not
  bool isActive = false;
  T data; //Data of the user
  ListItem(this.data); //Constructor to assign the data
}
