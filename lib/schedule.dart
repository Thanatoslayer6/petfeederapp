import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
          itemBuilder: ((context, index) {
            return MultiSelectItem(
              isSelecting: scheduleController.isSelecting,
              onSelected: () {
                setState(() {
                  scheduleController.toggle(index);
                });
              },
              child: Material(
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  // onLongPress: (() {}),
                  // onHighlightChanged: ((value) {}),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: scheduleController.isSelected(index) == true
                          ? const Color.fromARGB(255, 101, 145, 211)
                          : const Color.fromARGB(255, 243, 243, 243),
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.transparent,
                          // spreadRadius: 2,
                          // blurRadius: 7,
                          offset: Offset(2, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // ignore: avoid_unnecessary_containers
                          Container(
                            // color: Colors.blue,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  DateFormat('h:mm')
                                      .format(Schedule.listOfTimes[index].data),
                                  style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize:
                                          getadaptiveTextSize(context, 48),
                                      fontWeight: FontWeight.w500),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 4, left: 6),
                                  child: Text(
                                    DateFormat('a').format(
                                        Schedule.listOfTimes[index].data),
                                    style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize:
                                            getadaptiveTextSize(context, 24),
                                        fontWeight: FontWeight.normal),
                                  ),
                                )
                              ],
                            ),
                          ),

                          Switch(
                              activeColor:
                                  const Color.fromARGB(255, 33, 31, 103),
                              value: Schedule.listOfTimes[index].isActive,
                              onChanged: (value) {
                                setState(() {
                                  Schedule.listOfTimes[index].isActive = value;
                                });
                              })
                        ]),
                  ),
                ),
              ),
            );
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
            addItem(pickedTime);
            // TODO: After user picks a time, tell on what day... like everyday? every mon?
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
}
/*
// ignore: must_be_immutable
class ScheduleItem extends StatefulWidget {
  // int itemIndex;
  ListItem<dynamic> time;
  // MultiSelectController controller;
  // final VoidCallback onDelete;
  ScheduleItem({
    super.key,
    // required this.itemIndex,
    required this.time,
    // required this.onDelete,
    // required this.controller
  });
  @override
  State<ScheduleItem> createState() => _ScheduleItemState();
}

class _ScheduleItemState extends State<ScheduleItem> {
  // bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    /*
    return InkWell(
      child: MultiSelectItem(
        isSelecting: widget.controller.isSelecting,
        onSelected: () {
          setState(() {
            widget.controller.toggle(widget.itemIndex);
          });
        },
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: widget.time.isSelected == true
                ? const Color.fromARGB(255, 101, 145, 211)
                : const Color.fromARGB(255, 243, 243, 243),
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
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            // ignore: avoid_unnecessary_containers
            Container(
              // color: Colors.blue,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('h:mm').format(widget.time.data),
                    style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: getadaptiveTextSize(context, 48),
                        fontWeight: FontWeight.w500),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 6),
                    child: Text(
                      DateFormat('a').format(widget.time.data),
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: getadaptiveTextSize(context, 24),
                          fontWeight: FontWeight.normal),
                    ),
                  )
                ],
              ),
            ),
            widget.time.isSelected == true
                ? IconButton(
                    icon: const Icon(Icons.delete_forever_rounded),
                    onPressed: widget.onDelete,
                  )
                : Switch(
                    activeColor: const Color.fromARGB(255, 33, 31, 103),
                    value: widget.time.isActive,
                    onChanged: (value) {
                      setState(() {
                        widget.time.isActive = value;
                      });
                    })
          ]),
        ),
      ),
    );
    */
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.time.isSelected == true
            ? const Color.fromARGB(255, 101, 145, 211)
            : const Color.fromARGB(255, 243, 243, 243),
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
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        // ignore: avoid_unnecessary_containers
        Container(
          // color: Colors.blue,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('h:mm').format(widget.time.data),
                style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: getadaptiveTextSize(context, 48),
                    fontWeight: FontWeight.w500),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 6),
                child: Text(
                  DateFormat('a').format(widget.time.data),
                  style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: getadaptiveTextSize(context, 24),
                      fontWeight: FontWeight.normal),
                ),
              )
            ],
          ),
        ),

        Switch(
            activeColor: const Color.fromARGB(255, 33, 31, 103),
            value: widget.time.isActive,
            onChanged: (value) {
              setState(() {
                widget.time.isActive = value;
              });
            })
        /*
          widget.time.isSelected == true
              ? IconButton(
                  icon: const Icon(Icons.delete_forever_rounded),
                  onPressed: widget.onDelete,
                )
              : Switch(
                  activeColor: const Color.fromARGB(255, 33, 31, 103),
                  value: widget.time.isActive,
                  onChanged: (value) {
                    setState(() {
                      widget.time.isActive = value;
                    });
                  })
                  */
      ]),
    );
  }
}
*/

class Schedule {
  // int scheduleRotationIndex = 0;
  // ignore: unused_local_variable

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
