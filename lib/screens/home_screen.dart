import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:lipreading_app/screens/camera_screen.dart';
import 'package:lipreading_app/screens/history_screen.dart';
import 'package:lipreading_app/screens/profile_screen.dart';
import 'package:lipreading_app/screens/signin_screen.dart';
import 'package:lipreading_app/screens/chat_screen.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final uid;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  initState() {
    super.initState();

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      uid = user.uid;

      addNewUser(user);
    }

    Provider.of<UserFirebaseInfo>(context, listen: false).setUser(uid);
  }

  addNewUser(user) async {
    var checkUser = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!checkUser.exists) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'avatar': user.photoURL,
        'username': user.email,
        'id': user.uid,
        'friends': []
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Home Page',
          ),
          centerTitle: true,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              iconSize: 35,
              onPressed: () {
                _googleSignIn.disconnect().then((value) {
                  print("Signed Out");
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignInScreen()));
                });
              },
            )
          ],
        ),
        body: Center(
            child: Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome back !",
                        style: Theme.of(context).textTheme.displaySmall
                        // .copyWith(fontWeight: FontWeight.w900),
                        ),
                    SizedBox(
                      height: 30,
                    ),
                    Expanded(
                      child: ListView(
                        children: <Widget>[
                          SizedBox(height: 15.0),
                          Container(
                              padding: EdgeInsets.only(right: 15.0),
                              width: MediaQuery.of(context).size.width - 30.0,
                              height: MediaQuery.of(context).size.height - 50.0,
                              child: GridView.count(
                                crossAxisCount: 2,
                                primary: false,
                                crossAxisSpacing: 10.0,
                                mainAxisSpacing: 15.0,
                                childAspectRatio: 0.8,
                                children: <Widget>[
                                  _buildCard(
                                      'Message Chat',
                                      'assets/images/chat.png',
                                      "chat",
                                      context),
                                  _buildCard(
                                      'Profile',
                                      'assets/images/profile.jpg',
                                      "profile",
                                      context),
                                  _buildCard(
                                      'Record',
                                      'assets/images/camera.png',
                                      "camera",
                                      context),
                                  _buildCard(
                                      'Record History',
                                      'assets/images/history.png',
                                      "history",
                                      context)
                                ],
                              )),
                          SizedBox(height: 15.0)
                        ],
                      ),
                    ),
                  ],
                ))));
  }

  Widget _buildCard(String name, String imgPath, String navigator, context) {
    return Padding(
        padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0, right: 5.0),
        child: InkWell(
            onTap: () {
              switch (navigator) {
                case "camera":
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => CameraScreen()));
                  break;
                case "chat":
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChatScreen(userID: uid)));
                  break;
                case "history":
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => HistoryScreen()));
                  break;
                case "profile":
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ProfileScreen()));
                  break;
                default:
              }
            },
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 3.0,
                          blurRadius: 5.0)
                    ],
                    color: Colors.white),
                child: Column(children: [
                  Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.favorite, color: Color(0xFFEF7532))
                          ])),
                  Hero(
                      tag: imgPath,
                      child: Container(
                          height: 75.0,
                          width: 75.0,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(imgPath),
                                  fit: BoxFit.contain)))),
                  SizedBox(height: 15.0),
                  Text(name,
                      style: TextStyle(
                          color: Color(0xFF575E67),
                          fontFamily: 'Varela',
                          fontSize: 14.0)),
                ]))));
  }
}
