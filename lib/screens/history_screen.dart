import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lipreading_app/screens/video_screen.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  CollectionReference _videoCollection =
      FirebaseFirestore.instance.collection('videos');
  var _videoList = List.empty(growable: true);
  List<Widget> itemsData = [];

  @override
  void initState() {
    super.initState();
    // getVideoList();
    getVideoWidget();
  }

  deleteRecord(Map video) async {
    Navigator.of(context).pop();
    await FirebaseFirestore.instance
        .collection('videos')
        .doc(video['id'])
        .delete();

    itemsData.remove(video);

    setState(() {});
  }

  getVideoWidget() async {
    List<dynamic> responseList = await getVideoList();
    List<Widget> listItems = [];
    responseList.forEach((video) {
      listItems.add(Stack(children: [
        Container(
            height: 150,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(100), blurRadius: 10.0),
                ]),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        DateFormat.yMMMd()
                            .add_jm()
                            .format(video['created_at'].toDate())
                            .toString(),
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        video['duration'],
                        style:
                            const TextStyle(fontSize: 17, color: Colors.grey),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        video['text'],
                        style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VideoPage(
                                  url: video['video_path'],
                                  text: video['text'])));
                    },
                    child: Image.network(
                      video['thumbnail'],
                      height: double.infinity,
                    ),
                  )
                ],
              ),
            )),
        Positioned(
            right: 5,
            top: 0,
            child: GestureDetector(
                onTap: () {},
                child: IconButton(
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.red,
                    size: 30,
                  ),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Do you want to delete this record ?"),
                      actions: <Widget>[
                        TextButton(
                          child: Text("YES"),
                          onPressed: () => deleteRecord(video),
                        ),
                        TextButton(
                          child: Text("NO"),
                          onPressed: () {
                            //Put your code here which you want to execute on No button click.
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                )))
      ]));
    });
    setState(() {
      itemsData = listItems;
    });
  }

  getVideoList() async {
    late String userID;

    if (context.mounted) {
      userID = Provider.of<UserFirebaseInfo>(context, listen: false).uid;
    }

    final query = await _videoCollection
        .where('user_id', isEqualTo: userID)
        // .orderBy('created_at')
        .get();

    for (var doc in query.docs) {
      var video = Map();
      video['video_path'] = doc.get('video_path');
      video['text'] = doc.get('text');
      video['duration'] = doc.get('duration');
      video['thumbnail'] = doc.get('thumbnail');
      video['created_at'] = doc.get('created_at');
      video['id'] = doc.id;
      _videoList.add(video);
    }

    return _videoList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Record History',
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
          itemCount: itemsData.length,
          physics: BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return itemsData[index];
          }),
    );
  }
}
