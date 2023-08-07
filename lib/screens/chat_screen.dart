import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import '../models/chat_user_model.dart';

import 'chat_detail_screen.dart';
import 'conversation_list_screen.dart';

class ChatScreen extends StatefulWidget {
  final String? userID;
  const ChatScreen({super.key, this.userID});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatUsers> chatUsers = [];

  late Stream<QuerySnapshot<Map<String, dynamic>>> _searchQuery;

  bool findNewUser = false;

  @override
  void initState() {
    super.initState();
    // getVideoList();
    getListUsers();
  }

  getListUsers() {
    _searchQuery = FirebaseFirestore.instance
        .collection('users')
        .where('friends', arrayContains: widget.userID)
        .snapshots();
  }

  searchUsers(String search) {
    Stream<QuerySnapshot<Map<String, dynamic>>> searchQuery = FirebaseFirestore
        .instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: search)
        .where('username', isLessThan: search + 'z')
        .where('friends', arrayContains: widget.userID)
        .orderBy('username')
        .snapshots();

    setState(() {
      _searchQuery = searchQuery;

      if (search == "") {
        getListUsers();
      }
    });
  }

  // findNewUsers() {
  //   setState
  // }

  @override
  Widget build(BuildContext context) {
    // print(widget.userID);
    // final userID = Provider.of<UserFirebaseInfo>(context).uid;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Message Chat',
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      "Conversations",
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("ahihi");
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 8, right: 8, top: 2, bottom: 2),
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.pink[50],
                        ),
                        child: const Row(
                          children: <Widget>[
                            Icon(
                              Icons.add,
                              color: Colors.pink,
                              size: 20,
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                              "Find users",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: TextField(
                onChanged: (value) => searchUsers(value),
                decoration: InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.all(8),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey.shade100)),
                ),
              ),
            ),
            StreamBuilder(
                stream: _searchQuery,
                // FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(child: CircularProgressIndicator());
                    case ConnectionState.active:
                    case ConnectionState.done:
                      if (snapshot.hasData) {
                        final data = snapshot.data?.docs;

                        chatUsers = data
                                ?.map((e) => ChatUsers.fromJson(e.data()))
                                .toList() ??
                            [];
                        // print(widget.userID);
                        // for (var i in data!) {
                        //   // print(FirebaseAuth.instance.getUser(i.id));
                        //   print(i.data());
                        //   //   chatUsers.add(ChatUsers(
                        //   //       name: i.data()['username'],
                        //   //       imageURL: i.data()['avatar'],
                        //   //       messageText: 'test',
                        //   //       time: "test"));
                        // }
                      }

                      if (chatUsers.isNotEmpty) {
                        return ListView.builder(
                          itemCount: chatUsers.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.only(top: 16),
                          physics: AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return ChatDetailScreen(
                                      otherUsername:
                                          chatUsers[index].name ?? '',
                                      otherId: chatUsers[index].id ?? '');
                                }));
                              },
                              child: ConversationListScreen(
                                name: chatUsers[index].name ?? '',
                                messageText: chatUsers[index].messageText ?? '',
                                imageUrl: chatUsers[index].imageURL ?? '',
                                time: chatUsers[index].time ?? '',
                                isMessageRead:
                                    (index == 0 || index == 3) ? true : false,
                              ),
                            );
                          },
                        );
                      } else {
                        return Container(
                          padding: const EdgeInsets.only(top: 200),
                          child: const Center(
                            child: Text(
                              'You dont have any connections',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        );
                      }
                  }
                }),
          ],
        ),
      ),
    );
  }
}
