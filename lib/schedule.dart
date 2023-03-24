import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:weekday_selector/weekday_selector.dart';
import 'preferences.dart';
import 'time.dart';
import 'adaptive.dart';
import 'packages/multi_select_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  // Set up schedule controller
  MultiSelectController scheduleController = MultiSelectController();
  // bool newUserWithNoSchedules = false;

  @override
  void dispose() {
    super.dispose();
    if (Schedule.didModifySchedule == true) {
      updateSchedulesToDatabase().then((_) async {
        await Schedule.saveSchedule();
      });
      print("Disposing schedule stack and saving the contents to file now");
      Schedule.didModifySchedule = false;
    }
  }

  @override
  void initState() {
    super.initState();
    // First we connect to the database, to check if there are entries
    if (Schedule.listOfTimes.isEmpty) {
      // Reset the variables
      Schedule.listOfTimes = []; // Just reassuring
      getScheduleFromDatabase().then((_) {
        scheduleController.disableEditingWhenNoneSelected = true;
        scheduleController.set(Schedule.listOfTimes.length);
        setState(() {});
      });
    }
  }

  updateSchedulesToDatabase() async {
    // Also update the database information
    List properList = [];
    String requestURL =
        "${dotenv.env['CRUD_API']!}/api/schedule/${UserInfo.generalScheduleDatabaseId}";
    for (var schedule in Schedule.listOfTimes) {
      properList.add({
        'hour': schedule.hour,
        'minute': schedule.minute,
        'enabled': schedule.isActive,
        'weekDay': schedule.weekDaysIndex,
        'feedDuration': schedule.dispenserDuration
      });
    }
    var jsonBody =
        json.encode({'client': UserInfo.productId, 'items': properList});

    var response = await http.put(Uri.parse(requestURL),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonBody);
    if (response.statusCode == 200) {
      print("Successfully updated item: ${UserInfo.generalScheduleDatabaseId}");
    } else {
      print("Failed to update item: ${UserInfo.generalScheduleDatabaseId}");
    }
  }

  getScheduleFromDatabase() async {
    // Get entire schedule
    final String requestURL =
        "${dotenv.env['CRUD_API']!}/api/schedule/client/${UserInfo.productId}";
    var response = await http.get(Uri.parse(requestURL));

    if (response.statusCode == 200) {
      // If client exists in the database, set up the variables
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      print(jsonResponse);

      if (jsonResponse['data'].length > 0) {
        var jsonParsedData = jsonResponse['data'][0];
        if (UserInfo.generalScheduleDatabaseId == null) {
          UserInfo.generalScheduleDatabaseId = jsonParsedData['_id'];
          print("Schedule database id is not saved, trying to save now...");
          UserInfo.preferences.setString('generalScheduleDatabaseId',
              UserInfo.generalScheduleDatabaseId as String);
        }
        print(jsonParsedData);
        if (jsonParsedData.containsKey('items')) {
          // There is stored data...
          for (int i = 0; i < jsonParsedData['items'].length; i++) {
            Schedule.listOfTimes.add(ListItem(
                jsonParsedData['items'][i]['hour'],
                jsonParsedData['items'][i]['hour']));
            // Set up dispenser duration
            Schedule.listOfTimes[i].dispenserDuration =
                (jsonParsedData['items'][i]['feedDuration']).toDouble();
            Schedule.listOfTimes[i].weekDaysIndex =
                List<bool>.from(jsonParsedData['items'][i]['weekDay']);
          }
        }
        // print(Schedule.listOfTimes.toList());
        // print(Schedule.listOfTimes.length);
      } else {
        // New user
        print(
            "User doesn't have stored items in database... will add on next add");
        // newUserWithNoSchedules = true;
      }
    } else {
      return "Request failed with status: ${response.statusCode}";
    }
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
        // itemCount: Schedule.listOfTimes.length,
        // itemBuilder: ((context, index) => scheduleItem(scheduleController, index)),
        itemCount: Schedule.listOfTimes.length +
            1, // add one extra item for the spacer
        itemBuilder: (BuildContext context, int index) {
          if (index == Schedule.listOfTimes.length) {
            // if the index is the same as the data length,
            // return a container with some fixed height as the spacer
            return Container(
              height: 64.0, // adjust this value to set the height of the spacer
            );
          } else {
            // otherwise, return the regular item widget
            // return ListTile(
            //   title: Text(data[index]),
            // );
            return scheduleItem(scheduleController, index);
          }
        },
      ),
      // Only limit the schedules to 10
      floatingActionButton: Schedule.listOfTimes.length != 10
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.alarm_add_rounded),
              label: const Text("Add Schedule"),
              onPressed: () {
                // Deselect all selected items if existing
                setState(() {
                  scheduleController.deselectAll();
                });
                addTimeItem();
              },
            )
          : Container(),
    );
  }

  void addTimeItem() async {
    // String requestURL = "";
    // String jsonBody = "";
    // Logic for setting schedule
    TimeOfDay? pickedTime = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );

    // Let the user pick a certain time first...
    if (pickedTime != null) {
      Schedule.didModifySchedule = true;
      // Add schedule to front-end
      // Schedule.listOfTimes.add(ListItem(DateTime(
      //     DateTimeService.timeNow.year,
      //     DateTimeService.timeNow.month,
      //     DateTimeService.timeNow.day,
      //     pickedTime.hour,
      //     pickedTime.minute)));
      Schedule.listOfTimes.add(ListItem(pickedTime.hour, pickedTime.minute));
      // Add schedule to back-end (database)
      /*
      if (newUserWithNoSchedules == true) {
        requestURL = "${dotenv.env['CRUD_API']!}/api/schedule/";
        jsonBody = json.encode({
          'client': UserInfo.productId,
          'items': [
            {
              'hour': pickedTime.hour,
              'minute': pickedTime.minute,
              'enabled': false,
              'weekDay': List.filled(7, true),
              'feedDuration': 2
            }
          ]
        });
      } else {
        requestURL =
            "${dotenv.env['CRUD_API']!}/api/schedule/client/${UserInfo.productId}";
        jsonBody = json.encode({
          'hour': pickedTime.hour,
          'minute': pickedTime.minute,
          'enabled': false,
          'weekDay': List.filled(7, true),
          'feedDuration': 2
        });
      }
      */

      String requestURL =
          "${dotenv.env['CRUD_API']!}/api/schedule/client/${UserInfo.productId}";
      String jsonBody = json.encode({
        'hour': pickedTime.hour,
        'minute': pickedTime.minute,
        'enabled': false,
        'weekDay': List.filled(7, true),
        'feedDuration': 2
      });
      print(requestURL);

      final response = await http.post(Uri.parse(requestURL),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonBody);

      if (response.statusCode == 200) {
        /*
        if (newUserWithNoSchedules == true) {
          var jsonResponse =
              convert.jsonDecode(response.body) as Map<String, dynamic>;
          // print(jsonResponse.toString());
          // var jsonParsedData = jsonResponse['data'][0];
          UserInfo.generalScheduleDatabaseId = jsonResponse['data']['_id'];
          print(UserInfo.generalScheduleDatabaseId);

          UserInfo.preferences.setString('generalScheduleDatabaseId',
              UserInfo.generalScheduleDatabaseId as String);
          print(
              "Successfully added item schedule on database as a new user...");
          // Reset variable since user has new schedule now...
          newUserWithNoSchedules = false;
        } else {
          print("Successfully added item schedule on existing database");
        }
        */
        print("Successfully added item schedule on existing database");
      } else {
        print("Failed to add item schedule on database");
      }
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
      // initialTime: TimeOfDay.fromDateTime(Schedule.listOfTimes[indexOfItemToBeEdited].data),
      initialTime: TimeOfDay.fromDateTime(
          DateTimeService.getDateWithHourAndMinuteSet(
              Schedule.listOfTimes[indexOfItemToBeEdited].hour,
              Schedule.listOfTimes[indexOfItemToBeEdited].minute)),
      context: context,
    );

    if (pickedTime != null) {
      // Edit current time
      setState(() {
        // Schedule.listOfTimes[indexOfItemToBeEdited].data = DateTime(
        //     DateTimeService.timeNow.year,
        //     DateTimeService.timeNow.month,
        //     DateTimeService.timeNow.day,
        //     pickedTime.hour,
        //     pickedTime.minute);
        Schedule.didModifySchedule = true;
        Schedule.listOfTimes[indexOfItemToBeEdited].hour = pickedTime.hour;
        Schedule.listOfTimes[indexOfItemToBeEdited].minute = pickedTime.minute;
      });
    } else {
      print("User cancelled editing time");
    }
  }

  void deleteSelectedItems() {
    Schedule.didModifySchedule = true;
    var list = scheduleController.selectedIndexes;
    // Reoder from biggest number, so it wont error
    list.sort((b, a) => a.compareTo(b));
    // ignore: avoid_function_literals_in_foreach_calls
    list.forEach((element) async {
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
                                        // DateFormat('h:mm').format(
                                        //     Schedule.listOfTimes[index].data)
                                        DateFormat('h:mm').format(
                                            DateTimeService
                                                .getDateWithHourAndMinuteSet(
                                                    Schedule.listOfTimes[index]
                                                        .hour,
                                                    Schedule.listOfTimes[index]
                                                        .minute)),
                                        style: TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: getadaptiveTextSize(
                                                context, 48),
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: Text(
                                          // DateFormat('a').format(
                                          //     Schedule.listOfTimes[index].data),

                                          DateFormat('a').format(DateTimeService
                                              .getDateWithHourAndMinuteSet(
                                                  Schedule
                                                      .listOfTimes[index].hour,
                                                  Schedule.listOfTimes[index]
                                                      .minute)),
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
                                      Schedule.didModifySchedule = true;
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
                    Schedule.didModifySchedule = true;
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
                          Schedule.didModifySchedule = true;
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
  static bool didModifySchedule = false;
  // static String generalScheduleDatabaseId = "";
  // Lists in dart have methods such as .add() and .remove()
  static List<ListItem> listOfTimes = [];

  static Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    print("$path/schedule.json");
    return File('$path/schedule.json');
  }

  static Future<void> saveSchedule() async {
    final file = await _getFile();
    final jsonList = Schedule.listOfTimes.map((e) => e.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await file.writeAsString(jsonString);
  }

  static Future<void> loadSchedule() async {
    try {
      final file = await _getFile();
      final jsonString = await file.readAsString();
      final jsonList = json.decode(jsonString) as List<dynamic>;
      print(jsonList.toString());
      Schedule.listOfTimes.clear();
      for (int i = 0; i < jsonList.length; i++) {
        /* final hour = jsonList[i]['hour'] as int; */
        /* final minute = jsonList[i]['minute'] as int; */
        Schedule.listOfTimes.add(
            ListItem(jsonList[i]['hour'] as int, jsonList[i]['minute'] as int));
        Schedule.listOfTimes[i].isActive = jsonList[i]['isActive'] as bool;
        Schedule.listOfTimes[i].weekDaysIndex =
            List<bool>.from(jsonList[i]['weekDaysIndex']);
        Schedule.listOfTimes[i].dispenserDuration =
            jsonList[i]['dispenserDuration'] as double;
      }

      /* Schedule.listOfTimes = jsonList */
      /*     .map((jsonListItem) => ListItem( */
      /*           jsonListItem['hour'], */
      /*           jsonListItem['minute'], */
      /*         ) */
      /*           ..isActive = jsonListItem['isActive'] */
      /*           ..weekDaysIndex = List<bool>.from(jsonListItem['weekDaysIndex']) */
      /*           ..isEditingNow = jsonListItem['isEditingNow'] */
      /*           ..dispenserDuration = jsonListItem['dispenserDuration'] */
      /*           ..databaseId = jsonListItem['databaseId']) */
      /*     .toList(); */
    } catch (e) {
      print('Failed to load schedule: $e');
    }
  }
}

class ListItem {
  // bool isSelected = false; //Selection property to highlight or not
  bool isActive = false;
  List<bool> weekDaysIndex = List.filled(7, true);
  bool isEditingNow = false;
  double dispenserDuration = 2.0;
  int hour = 0;
  int minute = 0;
  // DateTime data; //Data of the user

  ListItem(this.hour, this.minute); //Constructor to assign the data

  Map<String, dynamic> toJson() {
    return {
      'isActive': isActive,
      'weekDaysIndex': weekDaysIndex,
      'isEditingNow': isEditingNow,
      'dispenserDuration': dispenserDuration,
      'hour': hour,
      'minute': minute
    };
  }
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
