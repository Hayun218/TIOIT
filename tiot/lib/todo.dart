import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

BottomAppBar appBar(BuildContext context) {
  return BottomAppBar(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // TODO: modify
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/dashboard'),
          icon: Icon(Icons.home_outlined),
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/todo'),
          icon: Icon(Icons.fact_check),
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/diary'),
          icon: Icon(Icons.note_alt_outlined),
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/home'),
          icon: Icon(Icons.calendar_today_outlined),
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/home'),
          icon: Icon(Icons.account_circle_outlined),
        ),
      ],
    ),
  );
}

TextEditingController todo = TextEditingController();

void addContentDialog(context) {
  showDialog(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          //Dialog Main Title
          title: Column(
            children: <Widget>[
              new Text("Dialog Title"),
            ],
          ),
          //
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Dialog Content",
              ),
            ],
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text("확인"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      });
}

var today = DateTime.now();
String todayDate = DateFormat('yyyy년 MM월 d일').format(DateTime.now());
final User user = FirebaseAuth.instance.currentUser!;

class ToDoPage extends StatefulWidget {
  const ToDoPage({Key? key}) : super(key: key);

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  Stream toDoList = FirebaseFirestore.instance
      .collection('user')
      .doc(user.uid)
      .collection('toDo')
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: appBar(context),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 10),
              child: IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: () {},
                iconSize: 40,
              ),
            ),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Container(
              margin: EdgeInsets.fromLTRB(0, 150, 0, 0),
              child: Center(
                child: Text(
                  todayDate,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
            ),
            Center(
              child: Container(
                width: 280,
                margin: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: StreamBuilder(
                    stream: toDoList,
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (!snapshot.hasData) return Text('loading');
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.check_box_outline_blank),
                                onPressed: () {},
                              ),
                              TextButton(
                                onPressed: () => addContentDialog(context),
                                child: Text(
                                  'Figma 작성하기',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.check_box_outline_blank),
                                onPressed: () {},
                              ),
                              Text(
                                'Figma 작성하기',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
