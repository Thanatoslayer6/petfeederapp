import 'dart:convert';
import 'dart:io';
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'adaptive.dart';
import 'mqtt.dart';
import 'preferences.dart';

class AudioItem {
  late String originalPath;
  late String fileURL; // Contains the url with the proper filename
  late String songName;
  late String cleanedSongName;
  late String artist;
  AudioItem(this.originalPath, this.fileURL, this.songName,
      this.cleanedSongName, this.artist); //Constructor to assign the data
}

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  List<AudioItem> audioFiles = [];
  late Directory cacheDirectory;
  late String? serverIp;
  @override
  void initState() {
    super.initState();
    getContents();
  }

  getContents() async {
    // First get the local ip
    serverIp = await NetworkInfo().getWifiIP(); // Get local ip
    // Get the application documents directory
    cacheDirectory = await getTemporaryDirectory();
    // Get a list of all the files in the directory

    Directory filePickerDir = Directory("${cacheDirectory.path}/file_picker");
    // List<FileSystemEntity> files =
    //     cacheDirectory.listSync(recursive: true, followLinks: false);
    if (await filePickerDir.exists()) {
      // Get a list of all files in the file_picker directory
      final files = await filePickerDir.list(recursive: true).toList();

      // Filter the files list to only include MP3 files
      final mp3Files =
          files.where((file) => file.path.endsWith('.mp3')).toList();

      if (mp3Files.isEmpty) {
        print("No .mp3 files found...");
      } else {
        // Assign the files into a global variable
        for (var file in mp3Files) {
          // Uses string manipulation to get filename
          String songName = file.path.split('/').last;
          String cleanedSongName = songName.replaceFirst(RegExp(r'.mp3'), '');
          String fileURL = "http://$serverIp:8080/file_picker/$songName";
          String artist = await getArtistTag(file.path);
          print("The stuff is: $songName - $artist => $fileURL");
          audioFiles.add(
              AudioItem(file.path, fileURL, songName, cleanedSongName, artist));
        }
      }
    }
    setState(() {});
  }

  Future<String> getArtistTag(String audioFilePath) async {
    final tagger = Audiotagger();
    Tag? tag = await tagger.readTags(path: audioFilePath);

    String artist = tag?.artist ?? "Unknown Artist";
    print("Artist is: $artist");
    return artist;

    // // // Read the file bytes
    // String artist = "Unknown Artist";

    // // Read the file bytes
    // List<int> fileBytes = File(audioFilePath).readAsBytesSync();

    // // Get the ID3 tag
    // List<int> id3Tag = fileBytes.sublist(0, 3);

    // // Check if the file has an ID3 tag
    // if (id3Tag[0] == 73 && id3Tag[1] == 68 && id3Tag[2] == 51) {
    //   // Get the artist tag
    //   artist = utf8.decode(fileBytes.sublist(33, 62)).trim();
    //   print("Artist: $artist");
    // } else {
    //   print("No ID3v2 tag found.");
    // }

    // return artist;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Play Music",
          style: TextStyle(
              color: const Color.fromARGB(255, 33, 31, 103),
              fontFamily: 'Poppins',
              fontSize: getadaptiveTextSize(context, 24),
              fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color.fromARGB(255, 33, 31, 103)),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: audioFiles.length + 1, // add one extra item for the spacer
        itemBuilder: (BuildContext context, int index) {
          if (index == audioFiles.length) {
            // if the index is the same as the data length,
            // return a container with some fixed height as the spacer
            return Container(
              height: 64.0, // adjust this value to set the height of the spacer
            );
          } else {
            return audioItem(context, audioFiles[index]);
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(200, 33, 31, 103),
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
              allowedExtensions: ['mp3'],
              type: FileType.custom,
              withData: true);
          if (result != null) {
            print("The file location is at: ${result.files.first.path}");
            // Get the file name
            String songName = (result.files.single.path)!.split('/').last;
            String cleanedSongName = songName.replaceFirst(RegExp(r'.mp3'), '');
            String fileURL = "http://$serverIp:8080/file_picker/$songName";
            String artist =
                await getArtistTag(result.files.single.path as String);
            audioFiles.add(AudioItem(result.files.single.path as String,
                fileURL, songName, cleanedSongName, artist));
          } else {
            // User canceled the picker
            print("User cancelled selecting a file...");
          }
          setState(() {});
        },
        label: const Text("Add Music/Audio"),
        icon: const Icon(
          Icons.my_library_music_rounded,
          size: 32,
        ),
      ),
    );
  }

  Widget audioItem(BuildContext context, AudioItem audio) {
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
              children: [
                Container(
                    child: const Icon(
                  Icons.music_note_rounded,
                  size: 32,
                )),
                Container(
                  margin: const EdgeInsets.only(right: 32, left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: Text(
                          audio.cleanedSongName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: getadaptiveTextSize(context, 18)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(audio.artist),
                      )
                    ],
                  ),
                ),
              ],
            ),
            MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              color: const Color.fromARGB(255, 243, 243, 243),
              onPressed: () async {
                if (MQTTPublic.isConnected) {
                  print("Song is found on this url: ${audio.fileURL}");
                  MQTTPublic.publish(
                      "${UserInfo.productId}/${UserInfo.devicePassword}/audio",
                      audio.fileURL);
                }
                Navigator.of(context).pop(true);
              },
              child: const Text("Play"),
            ),
          ],
        ),
      ),
    );
  }
}
