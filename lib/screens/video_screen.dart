import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lipreading_app/screens/home_screen.dart';

import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../providers/user_provider.dart';
import 'package:http/http.dart' as http;

import 'camera_screen.dart';

class VideoPage extends StatefulWidget {
  final String? filePath;
  final String? url;
  final String? text;
  final bool? chat;
  final String? receiver;

  const VideoPage(
      {Key? key, this.filePath, this.url, this.text, this.chat, this.receiver})
      : super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  late File _videoFile;
  late TextEditingController _controllerText;
  late String decodeSpeech;
  late Duration duration;
  FlutterTts ftts = FlutterTts();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.text != null) {
      _controllerText = TextEditingController(text: widget.text!);
    } else {
      _controllerText = TextEditingController(text: 'Waiting...');
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  String generateRandomString(int len) {
    var r = Random.secure();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
  }

  Future _initVideoPlayer() async {
    if (widget.filePath != null) {
      _videoPlayerController =
          VideoPlayerController.file(File(widget.filePath!));
    } else if (widget.url != null) {
      _videoPlayerController = VideoPlayerController.network(widget.url!);
    }

    await _videoPlayerController.initialize();

    duration = _videoPlayerController.value.duration;

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoInitialize: true,
    );
  }

  Future getText() async {
    var request = http.MultipartRequest(
        "POST",
        Uri.parse(
            'https://sharply-premium-dane.ngrok-free.app/predictions/LipReading'));
    request.files
        .add(await http.MultipartFile.fromPath('data', widget.filePath!));
    await request.send().then((response) {
      http.Response.fromStream(response).then((onValue) {
        try {
          print('The speech text is: ${onValue.body}');

          _controllerText = TextEditingController(text: onValue.body);
        } catch (e) {
          print('Error: $e ');
        }
      });
    });
  }

  _uploadVideoFirebase() async {
    setState(() {
      loading = true;
    });

    if (widget.filePath != null) {
      _videoFile = File(widget.filePath!);
    }

    String path = generateRandomString(10);
    late String userID;
    String text = _controllerText.text;

    TaskSnapshot taskSnapshot =
        await FirebaseStorage.instance.ref('videos/$path').putFile(_videoFile);
    final String urlDownload = await taskSnapshot.ref.getDownloadURL();
    if (context.mounted) {
      userID = Provider.of<UserFirebaseInfo>(context, listen: false).uid;
    }

    final videoThumbnail = await VideoThumbnail.thumbnailFile(
      video: urlDownload,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );

    TaskSnapshot thumbnailTaskSnapshot = await FirebaseStorage.instance
        .ref('images/$path')
        .putFile(File(videoThumbnail!));
    final String thumbnaillUrl =
        await thumbnailTaskSnapshot.ref.getDownloadURL();

    String durationFormat = "${duration}";

    if (widget.chat == null) {
      await FirebaseFirestore.instance.collection('videos').add({
        'video_path': urlDownload,
        'user_id': userID,
        'text': _controllerText.text,
        'thumbnail': thumbnaillUrl,
        'duration': durationFormat,
        'created_at': Timestamp.fromDate(DateTime.now())
      });
      Navigator.of(context).pop();
    } else if (widget.chat == true) {
      await FirebaseFirestore.instance.collection('messages').add({
        'video_path': urlDownload,
        'sender': userID,
        'message': text,
        'receiver': widget.receiver,
        'read': 'no',
        'type': 'video',
        'thumbnail': thumbnaillUrl,
        'duration': durationFormat,
        'sent': Timestamp.fromDate(DateTime.now())
      });
      Navigator.of(context)
        ..pop()
        ..pop();
    } else if (widget.chat == false) {
      await FirebaseFirestore.instance.collection('messages').add({
        'video_path': urlDownload,
        'sender': userID,
        'message': '',
        'receiver': widget.receiver,
        'read': 'no',
        'type': 'video',
        'thumbnail': thumbnaillUrl,
        'duration': durationFormat,
        'sent': Timestamp.fromDate(DateTime.now())
      });
      Navigator.of(context)
        ..pop()
        ..pop();
    }

    print('Download link: $urlDownload');
  }

  void readText() async {
    await ftts.setLanguage("en-US");
    await ftts.setSpeechRate(0.5);
    await ftts.setPitch(1);
    await ftts.speak(_controllerText.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.filePath != null
            ? const Text('Saved ?')
            : const Text('Preview'),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          Visibility(
            visible: widget.filePath != null ? true : false,
            child: loading
                ? CircularProgressIndicator()
                : IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: _uploadVideoFirebase),
          )
        ],
      ),
      body: FutureBuilder(
        future: _initVideoPlayer(),
        builder: (context, state) {
          if (state.connectionState == ConnectionState.done) {
            return Chewie(
              controller: _chewieController,
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Visibility(
        visible: widget.chat == false ? false : true,
        child: Container(
          padding: const EdgeInsets.only(bottom: 70),
          child: FutureBuilder(
              future: getText(),
              builder: (context, state) {
                if (state.connectionState == ConnectionState.done) {
                  return FloatingActionButton(
                    onPressed: () => showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                              title: Row(
                                children: [
                                  Text('Decoded Speech'),
                                  IconButton(
                                    icon: Icon(Icons.volume_up),
                                    onPressed: readText,
                                  )
                                ],
                              ),
                              content: TextField(
                                controller: _controllerText,
                                decoration: const InputDecoration(
                                    border: InputBorder.none),
                              ),
                            )),
                    child: const Icon(Icons.text_snippet),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              }
              // child:
              ),
        ),
      ),
    );
  }
}
