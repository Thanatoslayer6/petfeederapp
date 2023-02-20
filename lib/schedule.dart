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
        onPressed: () {
          // Deselect all selected items if existing
          setState(() {
            scheduleController.deselectAll();
          });
          addTimeItem();
        },
      ),
    );
  }

  void addTimeItem() async {
    // Logic for setting schedule
    TimeOfDay? pickedTime = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );

    // Let the user pick a certain time first...
    if (pickedTime != null) {
      // Add schedule
      Schedule.listOfTimes.add(ListItem(DateTime(
          DateTimeService.timeNow.year,
          DateTimeService.timeNow.month,
          DateTimeService.timeNow.day,
          pickedTime.hour,
          pickedTime.minute)));
    } else {
      print("User cancelled");
    }
    setState(() {
      // Update controller length
      scheduleController.set(Schedule.listOfTimes.length);
    });
  }

  void editTimeItem(int indexOfItemToBeEdited) async {
    // Set initial time as the time of the item
    TimeOfDay? pickedTime = await showTimePicker(
      initialTime: TimeOfDay.fromDateTime(
          Schedule.listOfTimes[indexOfItemToBeEdited].data),
      context: context,
    );

    if (pickedTime != null) {
      // Edit current time
      setState(() {
        Schedule.listOfTimes[indexOfItemToBeEdited].data = DateTime(
            DateTimeService.timeNow.year,
            DateTimeService.timeNow.month,
            DateTimeService.timeNow.day,
            pickedTime.hour,
            pickedTime.minute);
      });
    } else {
      print("User cancelled editing time");
    }
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

  List<IconButton> actionButtonLogic() {
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
    } else {
      return [];
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
                  // color: Colors.amber,
                  padding: const EdgeInsets.all(8),
                  // START OF CONTAINER CHILDREN (LISTTILE)
                  child: ListTile(
                    title:
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            // CHILDREN OF LISTTILE
                            children: [
                          // ignore: avoid_unnecessary_containers
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    editTimeItem(index);
                                    print("Editing time now");
                                  },
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        DateFormat('h:mm').format(
                                            Schedule.listOfTimes[index].data),
                                        style: TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: getadaptiveTextSize(
                                                context, 48),
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
                                        fontWeight: FontWeight.w300),
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
                                  icon: Schedule.listOfTimes[index]
                                              .isEditingNow ==
                                          true
                                      ? const Icon(
                                          Icons.keyboard_arrow_up_rounded)
                                      : const Icon(
                                          Icons.keyboard_arrow_down_rounded))
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
                ...WeekDayDropDown(index),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  List<Widget> WeekDayDropDown(int index) {
    // var sliderValue = 3.0;
    // Schedule
    return Schedule.listOfTimes[index].isEditingNow == true
        ? [
            const Divider(
              height: 0,
              thickness: 1,
              color: Color.fromARGB(70, 111, 111, 111),
              indent: 32,
              endIndent: 32,
            ),
            Container(
              margin:
                  const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 8),
              // color: Colors.red,
              child: WeekdaySelector(
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
                // selectedShape: ,
              ),
            ),
            Column(
              children: [
                Container(
                  // color: Colors.blue,
                  margin: const EdgeInsets.only(left: 18, top: 16),
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "Dispense food for ${Schedule.listOfTimes[index].dispenserDuration} seconds",
                    style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w300,
                        fontSize: getadaptiveTextSize(context, 14)),
                  ),
                ),
                Container(
                  // color: Colors.amber,
                  margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                  child: Slider(
                      min: 1.0,
                      max: 10.0,
                      divisions: 9,
                      value: Schedule.listOfTimes[index].dispenserDuration,
                      onChanged: (newValue) {
                        setState(() {
                          Schedule.listOfTimes[index].dispenserDuration =
                              newValue;
                        });
                      }),
                ),
              ],
            ),
          ]
        : [];
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
  double dispenserDuration = 2.0;
  // String repeatsEvery = "Everyday";
  T data; //Data of the user
  ListItem(this.data); //Constructor to assign the data
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
    temp = days.join(', ');
  }
  return temp;
}
