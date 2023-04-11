import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'adaptive.dart';
import 'preferences.dart';

class ActivityLogPage extends StatefulWidget {
  const ActivityLogPage({super.key});

  @override
  State<ActivityLogPage> createState() => _ActivityLogPageState();
}

class _ActivityLogPageState extends State<ActivityLogPage> {
  @override
  void initState() {
    super.initState();
    // if (History.listOfLogs.isEmpty) {
    History.listOfLogs = []; // Reset necessary variables just in case
    // History.didUserUpdate = false;
    getLogsFromDatabase().then((_) {
      log("Getting logs from the database, updating the state now...");
      setState(() {});
    });
    // }
  }

  getLogsFromDatabase() async {
    final String requestURL =
        "${dotenv.env['CRUD_API']!}/api/logs/client/${UserInfo.productId}";
    var response = await http.get(Uri.parse(requestURL));
    var jsonResponse =
        convert.jsonDecode(response.body) as Map<String, dynamic>;

    if (jsonResponse['data'].length > 0) {
      var jsonParsedData = jsonResponse['data'][0];
      History.generalHistoryDatabaseId = jsonParsedData['_id'];
      // Check if sharedPreferences doesn't have the database id... just save it
      if (UserInfo.generalHistoryDatabaseId == null) {
        log("History database id is not saved, trying to save now...");
        UserInfo.generalHistoryDatabaseId = jsonParsedData['_id'];
        UserInfo.preferences.setString(
            'generalHistoryDatabaseId', History.generalHistoryDatabaseId);
      }
      // ignore: avoid_print
      print(jsonParsedData);
      // log(jsonParsedData);
      if (jsonParsedData.containsKey('items')) {
        // There is stored data...
        for (int i = 0; i < jsonParsedData['items'].length; i++) {
          History.listOfLogs.add(Log(
              jsonParsedData['items'][i]['_id'],
              jsonParsedData['items'][i]['type'],
              jsonParsedData['items'][i]['didFail'],
              jsonParsedData['items'][i]['dateFinished'],
              jsonParsedData['items'][i]['duration']));
        }
      }
      //log(History);
    } else {
      log("User doesn't have any logs within the database...");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Activity Log",
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontFamily: 'Poppins',
              fontSize: getadaptiveTextSize(context, 24),
              fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          History.listOfLogs.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.delete_sweep_rounded,
                      color: Theme.of(context).primaryColor),
                  onPressed: () {
                    showGeneralDialog(
                      context: context,
                      barrierDismissible: false,
                      pageBuilder: (context, a1, a2) {
                        return Container();
                      },
                      transitionBuilder: (ctx, a1, a2, child) {
                        var curve = Curves.easeInOut.transform(a1.value);
                        return Transform.scale(
                          scale: curve,
                          child: AlertDialog(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            title: const Text("Clear all activity logs?"),
                            actions: [
                              TextButton(
                                child: Text("Cancel",
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text("Yes",
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor)),
                                onPressed: () async {
                                  if (UserInfo.generalHistoryDatabaseId ==
                                      null) {
                                    log("There is no database id stored... will not allow user to clear logs");
                                  }
                                  String requestURL =
                                      "${dotenv.env['CRUD_API']!}/api/logs/${UserInfo.generalHistoryDatabaseId}";
                                  String jsonBody = json.encode({
                                    'client': UserInfo.productId,
                                    'items': [],
                                  });
                                  log(requestURL);

                                  final response =
                                      await http.put(Uri.parse(requestURL),
                                          headers: {
                                            'Content-Type': 'application/json',
                                          },
                                          body: jsonBody);

                                  if (response.statusCode == 200) {
                                    log("Successfully deleted all logs");

                                    setState(() {
                                      History.listOfLogs.clear();
                                    });
                                  } else {
                                    log("Failed to delete all logs");
                                    setState(() {});
                                  }
                                  // ignore: use_build_context_synchronously
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 500),
                    ).then((_) => setState(() {}));
                  },
                )
              : Container()
        ],
      ),
      body: History.listOfLogs.isNotEmpty
          ? ListView.builder(
              itemCount: History.listOfLogs.length,
              itemBuilder: (context, index) {
                int reversedIndex = History.listOfLogs.length - 1 - index;
                return logItem(reversedIndex);
              },
            )
          : Align(
              child: Text(
                "No activity logs found...",
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: getadaptiveTextSize(context, 18),
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).primaryColor),
              ),
            ),
    );
  }

  Widget logItem(int index) {
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
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              children: [
                Container(
                  child: History.listOfLogs[index].didFail == true
                      ? Icon(
                          Icons.error_rounded,
                          color: Theme.of(context).primaryColor,
                          size: 32,
                        )
                      : Icon(
                          Icons.check_circle_rounded,
                          color: Theme.of(context).primaryColor,
                          size: 32,
                        ),
                ),
                Container(
                  // color: Colors.orange,
                  margin: const EdgeInsets.only(right: 32, left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: Text(
                          History.listOfLogs[index].type,
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: getadaptiveTextSize(context, 18)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: History.listOfLogs[index].type ==
                                "Feed Log" // Change this to "UV" or "Feed"
                            ? Text(
                                "${History.listOfLogs[index].duration} seconds",
                              )
                            : Text(
                                "${History.listOfLogs[index].duration} minutes"),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 4),
                  child: History.listOfLogs[index].didFail == true
                      ? const Text("Failed",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 194, 51, 41)))
                      : const Text(
                          "Success",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 70, 185, 74)),
                        ),
                ),
                Text(
                  History.listOfLogs[index].dateFinished,
                  style: const TextStyle(
                      fontStyle: FontStyle.italic, fontWeight: FontWeight.w300),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class History {
  static String generalHistoryDatabaseId = "";
  // Lists in dart have methods such as .add() and .remove()
  static List<Log> listOfLogs = [
    // ListItem(DateTime(DateTimeService.timeNow.year,
    //     DateTimeService.timeNow.month, DateTimeService.timeNow.day, 13, 30))
  ];
}

class Log {
  late String databaseId; // The database id
  late String type; // Feed or UV-Light
  late bool didFail;
  late String dateFinished;
  late int duration;

  // T data; //Data of the user
  Log(this.databaseId, this.type, this.didFail, this.dateFinished,
      this.duration); //Constructor to assign the data
}
