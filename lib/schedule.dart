import 'package:flutter/foundation.dart';
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
        actions: actionButtonLogic(),
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
          // Deselect all selected items if existing
          setState(() {
            scheduleController.deselectAll();
          });
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

  List<IconButton>? actionButtonLogic() {
    if (scheduleController.isSelecting == true) {
      return [
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
      ];
    }
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
                // print("Hello World");
                // Disable editing when user tries to select an item
                Schedule.listOfTimes[index].isEditingNow = false;
                controller.toggle(index);
              });
            },
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  // START OF CONTAINER CHILDREN (LISTTILE)
                  child: ListTile(
                    title:
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            // CHILDREN OF LISTTILE
                            children: [
                          // ignore: avoid_unnecessary_containers
                          Container(
                            // color: Colors.red,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      DateFormat('h:mm').format(
                                          Schedule.listOfTimes[index].data),
                                      style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize:
                                              getadaptiveTextSize(context, 48),
                                          fontWeight: FontWeight.w700),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: Text(
                                        DateFormat('a').format(
                                            Schedule.listOfTimes[index].data),
                                        style: TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: getadaptiveTextSize(
                                                context, 24),
                                            fontWeight: FontWeight.normal),
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    showWeekDays(Schedule
                                        .listOfTimes[index].weekDaysIndex),
                                    style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize:
                                            getadaptiveTextSize(context, 16),
                                        fontWeight: FontWeight.w100),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Switch(
                                  activeColor:
                                      const Color.fromARGB(255, 33, 31, 103),
                                  value: Schedule.listOfTimes[index].isActive,
                                  onChanged: (value) {
                                    setState(() {
                                      Schedule.listOfTimes[index].isActive =
                                          value;
                                    });
                                  }),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      Schedule.listOfTimes[index]
                                                  .isEditingNow ==
                                              false
                                          ? Schedule.listOfTimes[index]
                                              .isEditingNow = true
                                          : Schedule.listOfTimes[index]
                                              .isEditingNow = false;
                                    });
                                  },
                                  icon: const Icon(Icons.arrow_drop_down))
                            ],
                          ),
                        ]
                            // END OF CHILDREN OF LISTTLE
                            ),
                  ),

                  // END LIST TILEEEEEEEEEEEEEe
                ),
                // END FIRST CONTAINER
                // ADD THE STUFF HERE
                WeekDayDropDown(index),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget WeekDayDropDown(int index) {
    // Schedule
    return Schedule.listOfTimes[index].isEditingNow == true
        ? WeekdaySelector(
            // We display the last tapped value in the example app
            onChanged: (int day) {
              // print(printIntAsDay(day));
              setState(() {
                Schedule.listOfTimes[index].weekDaysIndex[day % 7] =
                    !Schedule.listOfTimes[index].weekDaysIndex[day % 7];
              });
            },
            values: Schedule.listOfTimes[index].weekDaysIndex,
            shortWeekdays: const [
              'Sun',
              'Mon',
              'Tue',
              'Wed',
              'Thu',
              'Fri',
              'Sat',
            ],
          )
        : Container();
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
  List<bool> weekDaysIndex = List.filled(7, true);
  bool isEditingNow = false;
  // String repeatsEvery = "Everyday";
  T data; //Data of the user
  ListItem(this.data); //Constructor to assign the data
}

printIntAsDay(int day) {
  print('Received integer: $day. Corresponds to day: ${intDayToEnglish(day)}');
}

String intDayToEnglish(int day) {
  if (day % 7 == DateTime.monday % 7) return 'Monday';
  if (day % 7 == DateTime.tuesday % 7) return 'Tueday';
  if (day % 7 == DateTime.wednesday % 7) return 'Wednesday';
  if (day % 7 == DateTime.thursday % 7) return 'Thursday';
  if (day % 7 == DateTime.friday % 7) return 'Friday';
  if (day % 7 == DateTime.saturday % 7) return 'Saturday';
  if (day % 7 == DateTime.sunday % 7) return 'Sunday';
  throw '🐞 This should never have happened: $day';
}

String showWeekDays(List<bool> list) {
  String temp = "";
  List<String> daysOfTheWeek = [
    "Sun", // 7
    "Mon", // 1
    "Tue", // 2
    "Wed", // 3
    "Thu", // 4
    "Fri", // 5
    "Sat", // 6
  ];
  List<String> days = [];
  if (listEquals(list, [true, true, true, true, true, true, true]) == true) {
    return "Everyday";
  } else if (listEquals(list, [false, true, true, true, true, true, false])) {
    return "Weekdays";
  } else if (listEquals(
      list, [true, false, false, false, false, false, true])) {
    return "Weekends";
  } else {
    for (int i = 1; i < list.length; i++) {
      if (list[i] == true) {
        days.add(daysOfTheWeek[i]);
      }
    }
    if (list[0] == true) {
      days.add("Sun");
    }
    // print(days);
    // print(days.join(', '));
    temp = days.join(', ');
  }
  return temp;
}
