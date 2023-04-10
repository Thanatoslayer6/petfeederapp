import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:petfeederapp/preferences.dart';
import 'package:petfeederapp/time.dart';

class UVLightHandler {
  Timer? _timer;

  Future<void> startTimer(int duration) async {
    _timer = Timer(Duration(minutes: duration), () {
      UserInfo.isUVLightActivated = false;
    });
  }

  Future<void> cancelTimer() async {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    UserInfo.isUVLightActivated = false;
  }

  // This method is called after activating a uv light
  Future<void> saveStateToFile(int duration) async {
    UserInfo.isUVLightActivated = true;
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/uv_status.json');
    await file.writeAsString(jsonEncode({
      'timeStarted': DateTimeService.timeNow.toString(),
      'duration': duration
    }));
    log("Done writing UV status to file");
  }

  Future<void> removeFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/uv_status.json');
    await file.delete();
    log("UV status file has been deleted");
  }

  Future<void> getStateFromFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/uv_status.json');
    if (await file.exists()) {
      final content = await file.readAsString();
      final data = jsonDecode(content);
      final startTime = DateTime.parse(data['timeStarted']);
      final duration = data['duration'];
      if (isDurationOver(startTime, duration)) {
        UserInfo.isUVLightActivated = false;
      } else {
        UserInfo.isUVLightActivated = true;
      }
      log("UV Light status file exists...");
    } else {
      log("No UV Light status file exists...");
      UserInfo.isUVLightActivated = false;
    }
  }

  bool isDurationOver(DateTime startTime, int durationInMinutes) {
    final now = DateTime.now();
    final endTime = startTime.add(Duration(minutes: durationInMinutes));
    return endTime.isBefore(now);
  }
}
