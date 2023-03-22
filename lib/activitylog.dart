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
      print("Got logs from the database, updating state now...");
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
        print("History database id is not saved, trying to save now...");
        UserInfo.preferences.setString(
            'generalHistoryDatabaseId', History.generalHistoryDatabaseId);
      }

      print(jsonParsedData);
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
      //print(History);
    } else {
      print("User doesn't have any logs within the database...");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Activity Log",
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
        itemCount: History.listOfLogs.length,
        itemBuilder: ((context, index) => logItem(index)),
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
        borderRadius: BorderRadius.circular(32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  child: History.listOfLogs[index].didFail == true
                      ? const Icon(
                          Icons.error_rounded,
                          size: 32,
                        )
                      : const Icon(
                          Icons.check_circle_rounded,
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
                              fontWeight: FontWeight.bold,
                              fontSize: getadaptiveTextSize(context, 18)),
                        ),
                      ),
                      Padding(
                        // TODO: second(s) or minute(s) logic
                        padding: const EdgeInsets.only(bottom: 16),
                        child: History.listOfLogs[index].type ==
                                "Feed Log" // Change this to "UV" or "Feed"
                            ? Text(
                                "${History.listOfLogs[index].duration} seconds")
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
