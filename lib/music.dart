import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
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
  late Uint8List? artwork;
  AudioItem(
      this.originalPath,
      this.fileURL,
      this.songName,
      this.cleanedSongName,
      this.artist,
      this.artwork); //Constructor to assign the data
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
        log("No .mp3 files found...");
      } else {
        // Assign the files into a global variable
        for (var file in mp3Files) {
          // Uses string manipulation to get filename
          String songName = file.path.split('/').last;
          String cleanedSongName = songName.replaceFirst(RegExp(r'.mp3'), '');
          String fileURL =
              "http://$serverIp:8080/file_picker/${songName.replaceAll(RegExp(r'\s'), '%20')}";
          String artist = await getArtistTag(file.path);
          Uint8List? artwork = await getArtwork(file.path);
          log("The stuff is: $songName - $artist => $fileURL");
          audioFiles.add(AudioItem(
              file.path, fileURL, songName, cleanedSongName, artist, artwork));
        }
      }
    }
    setState(() {});
  }

  Future<String> getArtistTag(String audioFilePath) async {
    final tagger = Audiotagger();
    Tag? tag = await tagger.readTags(path: audioFilePath);

    String artist = tag?.artist ?? "Unknown Artist";
    log("Artist is: $artist");
    return artist;
  }

  Future<Uint8List?> getArtwork(String audioFilePath) async {
    final tagger = Audiotagger();
    final Uint8List? artwork = await tagger.readArtwork(path: audioFilePath);
    return artwork;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Play Music",
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontFamily: 'Poppins',
              fontSize: getadaptiveTextSize(context, 24),
              fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: Theme.of(context).primaryColor),
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
        // backgroundColor: const Color.fromARGB(200, 33, 31, 103),

        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
              allowedExtensions: ['mp3'],
              type: FileType.custom,
              withData: true);
          if (result != null) {
            log("The file location is at: ${result.files.first.path}");
            // Get the file name (replace all spaces with '_')
            String songName = (result.files.single.path)!.split('/').last;
            String cleanedSongName = songName.replaceFirst(RegExp(r'.mp3'), '');
            String fileURL =
                "http://$serverIp:8080/file_picker/${songName.replaceAll(RegExp(r'\s'), '%20')}";
            String artist =
                await getArtistTag(result.files.single.path as String);
            Uint8List? artwork =
                await getArtwork(result.files.single.path as String);
            audioFiles.add(AudioItem(result.files.single.path as String,
                fileURL, songName, cleanedSongName, artist, artwork));
          } else {
            // User canceled the picker
            log("User cancelled selecting a file...");
          }
          setState(() {});
        },
        label: Text(
          "Add Music/Audio",
          style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),
        ),
        icon: Icon(
          Icons.my_library_music_rounded,
          color: Theme.of(context).scaffoldBackgroundColor,
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
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(32),
        child: ListTile(
          horizontalTitleGap: 4,
          leading: audio.artwork != null
              ? CircleAvatar(
                  backgroundImage: MemoryImage(audio.artwork as Uint8List),
                  radius: getadaptiveTextSize(context, 18),
                )
              : Icon(
                  Icons.music_note_rounded,
                  color: Theme.of(context).unselectedWidgetColor,
                  size: 32,
                ),
          title: Text(
            audio.cleanedSongName,
            style: TextStyle(
                color: Theme.of(context).scaffoldBackgroundColor,
                fontWeight: FontWeight.bold,
                fontSize: getadaptiveTextSize(context, 16)),
          ),
          subtitle: Text(
            audio.artist,
            style: TextStyle(
                color: Theme.of(context).unselectedWidgetColor,
                fontSize: getadaptiveTextSize(context, 12)),
          ),
          dense: true,
          // trailing: ,
          trailing: MaterialButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            // color: const Color.fromARGB(255, 243, 243, 243),
            color: Theme.of(context).unselectedWidgetColor,
            onPressed: () async {
              if (MQTTPublic.isConnected) {
                log("Song is found on this url: ${audio.fileURL}");
                MQTTPublic.publish(
                    "${UserInfo.productId}/${UserInfo.devicePassword}/audio",
                    audio.fileURL);
              }
              Navigator.of(context).pop(true);
            },
            child: const Text("Play"),
          ),
        ),
      ),
    );
  }
}
