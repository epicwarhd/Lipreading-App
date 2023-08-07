import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String avatar;
  late String username;
  bool changeUsername = false;
  late TextEditingController _controllerText;
  late String userID;

  @override
  void initState() {
    super.initState();
    // getVideoList();
    getUserInfo();
  }

  getUserInfo() async {
    if (context.mounted) {
      userID = Provider.of<UserFirebaseInfo>(context, listen: false).uid;
    }

    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: userID)
        .get();

    setState(() {
      avatar = query.docs[0].get('avatar');
      username = query.docs[0].get('username');
      _controllerText =
          TextEditingController(text: query.docs[0].get('username'));
    });
  }

  getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      // maxWidth: 1800,
      // maxHeight: 1800,
    );
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      TaskSnapshot taskSnapshot = await FirebaseStorage.instance
          .ref('videos/$userID')
          .putFile(imageFile);
      String urlDownload = await taskSnapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .update({'avatar': urlDownload}).then((value) => getUserInfo());
    }
  }

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 75,
                    backgroundColor: Colors.grey.shade200,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage(avatar),
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 0,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.white),
                      child: IconButton(
                        icon: const Icon(
                          LineAwesomeIcons.alternate_pencil,
                          color: Colors.black,
                          size: 20,
                        ),
                        onPressed: getFromGallery,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Username: ",
                      style: Theme.of(context).textTheme.headlineSmall),
                  changeUsername
                      ? Expanded(
                          child: TextField(
                          controller: _controllerText,
                        ))
                      : Expanded(
                          child: Text(username,
                              style: Theme.of(context).textTheme.headlineSmall),
                        ),
                  const SizedBox(
                    width: 5,
                  ),
                  IconButton(
                    icon: changeUsername
                        ? const Icon(
                            LineAwesomeIcons.check,
                            color: Colors.black,
                            size: 20,
                          )
                        : const Icon(LineAwesomeIcons.alternate_pencil,
                            color: Colors.black, size: 20),
                    onPressed: () {
                      if (changeUsername) {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(userID)
                            .update({'username': _controllerText.text}).then(
                                (value) => getUserInfo());
                      }

                      setState(() {
                        changeUsername = !changeUsername;
                      });
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
