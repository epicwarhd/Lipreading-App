import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:lipreading_app/screens/camera_screen.dart';
import 'package:lipreading_app/screens/video_screen.dart';
import 'package:provider/provider.dart';

import '../models/chat_message_model.dart';
import '../providers/user_provider.dart';

class ChatDetailScreen extends StatefulWidget {
  final String otherId;
  final String otherUsername;
  const ChatDetailScreen(
      {super.key, required this.otherId, required this.otherUsername});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  // List<ChatMessage> messages = [
  //   ChatMessage(msg: "Hello, Will", type: "receiver"),
  //   ChatMessage(msg: "How have you been?", type: "receiver"),
  //   ChatMessage(msg: "Hey Kriss, I am doing fine dude. wbu?", type: "sender"),
  //   ChatMessage(msg: "ehhhh, doing OK.", type: "receiver"),
  //   ChatMessage(msg: "Is there any thing wrong?", type: "sender"),
  // ];

  List<ChatMessage> sendMsg = [];
  List<ChatMessage> receiveMsg = [];
  List<ChatMessage> msg = [];
  bool _showEmoji = false;
  TextEditingController _inputMsg = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final userID = Provider.of<UserFirebaseInfo>(context, listen: false).uid;

    return WillPopScope(
      onWillPop: () {
        if (_showEmoji) {
          setState(() => _showEmoji = !_showEmoji);
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          flexibleSpace: SafeArea(
            child: Container(
              padding: EdgeInsets.only(right: 16),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                        "https://firebasestorage.googleapis.com/v0/b/lipreadig.appspot.com/o/images%2Favatar.jpg?alt=media&token=f5e562e0-93d2-4917-9365-dbc0841ea405"),
                    maxRadius: 20,
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          widget.otherUsername,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Text(
                          "Online",
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.settings,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('messages')
                      .where('sender', isEqualTo: userID)
                      .where('receiver', isEqualTo: widget.otherId)
                      .snapshots(),
                  builder: (context, snapshot1) {
                    return StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('messages')
                            .where('sender', isEqualTo: widget.otherId)
                            .where('receiver', isEqualTo: userID)
                            .snapshots(),
                        builder: (context, snapshot2) {
                          switch (snapshot1.connectionState) {
                            case ConnectionState.waiting:
                            case ConnectionState.none:
                              return const Center(
                                  child: CircularProgressIndicator());
                            case ConnectionState.active:
                            case ConnectionState.done:
                              if (snapshot1.hasData & snapshot2.hasData) {
                                final data1 = snapshot1.data?.docs;
                                final data2 = snapshot2.data?.docs;

                                sendMsg = data1
                                        ?.map((e) =>
                                            ChatMessage.fromJson(e.data()))
                                        .toList() ??
                                    [];

                                receiveMsg = data2
                                        ?.map((e) =>
                                            ChatMessage.fromJson(e.data()))
                                        .toList() ??
                                    [];

                                msg = sendMsg + receiveMsg;
                              }

                              if (msg.isNotEmpty) {
                                msg.sort(((a, b) => a.sent.compareTo(b.sent)));
                                return ListView.builder(
                                  controller: _scrollController,
                                  itemCount: msg.length,
                                  shrinkWrap: true,
                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                  physics: AlwaysScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Container(
                                      padding: EdgeInsets.only(
                                          left: 14,
                                          right: 14,
                                          top: 10,
                                          bottom: 10),
                                      child: Align(
                                        alignment: (msg[index].toId == userID
                                            ? Alignment.topLeft
                                            : Alignment.topRight),
                                        child: Column(
                                          crossAxisAlignment:
                                              msg[index].toId == userID
                                                  ? CrossAxisAlignment.start
                                                  : CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color:
                                                    (msg[index].toId == userID
                                                        ? Colors.grey.shade200
                                                        : Colors.blue[200]),
                                              ),
                                              padding: EdgeInsets.all(16),
                                              child: msg[index].type == 'text'
                                                  ? Text(
                                                      msg[index].msg,
                                                      style: TextStyle(
                                                          fontSize: 15),
                                                    )
                                                  : GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => VideoPage(
                                                                    url: msg[
                                                                            index]
                                                                        .videoPath,
                                                                    text: msg[
                                                                            index]
                                                                        .msg,
                                                                    chat: msg[index].msg ==
                                                                            ''
                                                                        ? false
                                                                        : true)));
                                                      },
                                                      child: msg[index].msg ==
                                                              ''
                                                          ? Image.network(
                                                              msg[index]
                                                                  .thumbnail!,
                                                              // height: double
                                                              //     .infinity,
                                                            )
                                                          // Text(
                                                          //     'This is a video, click to play')
                                                          : Column(
                                                              children: [
                                                                // Text(
                                                                //     'This is a lipreading video, click to play'),
                                                                Image.network(
                                                                  msg[index]
                                                                      .thumbnail!,
                                                                ),
                                                                Text(msg[index]
                                                                    .msg)
                                                              ],
                                                            )),
                                            ),
                                            Container(
                                                child: Text(
                                                    msg[index].sent.toString()))
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return Container(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: const Center(
                                    child: Text(
                                      'Say Hi! 👋',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                );
                              }
                          }
                        });
                  }),
            ),
            if (_showEmoji)
              SizedBox(
                  height: 5,
                  child: EmojiPicker(
                    textEditingController: _inputMsg,
                    config: Config(
                      bgColor: const Color.fromARGB(255, 234, 248, 255),
                      columns: 8,
                      emojiSizeMax: 32,
                    ),
                  )),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                height: 60,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    IconButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          setState(() => _showEmoji = !_showEmoji);
                        },
                        icon: const Icon(Icons.emoji_emotions,
                            color: Colors.blueAccent, size: 25)),
                    Expanded(
                      child: TextField(
                        controller: _inputMsg,
                        decoration: InputDecoration(
                            hintText: "Write message...",
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none),
                      ),
                    ),
                    // SizedBox(
                    //   width: 15,
                    // ),
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CameraScreen(
                                        chat: false,
                                        receiver: widget.otherId,
                                      )));
                        },
                        icon: const Icon(Icons.videocam,
                            color: Colors.blueAccent, size: 26)),
                    IconButton(
                        onPressed: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CameraScreen(
                                        chat: true,
                                        receiver: widget.otherId,
                                      )));
                        },
                        icon: const Icon(Icons.video_call,
                            color: Colors.blueAccent, size: 26)),
                    FloatingActionButton(
                      onPressed: () {
                        FirebaseFirestore.instance.collection('messages').add({
                          'sender': userID,
                          'receiver': widget.otherId,
                          'message': _inputMsg.text,
                          'read': 'no',
                          'type': 'text',
                          'sent': Timestamp.fromDate(DateTime.now())
                        });
                        _inputMsg.text = '';
                      },
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                      backgroundColor: Colors.blue,
                      elevation: 0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
