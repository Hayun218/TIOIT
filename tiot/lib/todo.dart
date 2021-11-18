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
          onPressed: () => Navigator.pushNamed(context, '/badge'),
          icon: Icon(Icons.account_circle_outlined),
        ),
      ],
    ),
  );
}

User user = FirebaseAuth.instance.currentUser!;
CollectionReference toDo = FirebaseFirestore.instance
    .collection('user')
    .doc(user.uid)
    .collection('toDo');

Future<void> deleteToDo(data) {
  return toDo.doc(data.id).delete().then(
    (value) {
      print('Data Deleted');
    },
  );
}

void showContentDialog(context, data) {
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text("To Do")),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Time: " + data['time']),
              Row(
                children: [
                  Text("Priority: "),
                  if (data['priority'] == 1)
                    Icon(Icons.circle, color: Colors.red),
                ],
              ),
              Text("Content: " + data['content']),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: new Text("삭제"),
              onPressed: () {
                deleteToDo(data);
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: new Text("수정"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      });
}

TextEditingController _time = TextEditingController();
void addContentDialog(context) {
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text("To Do")),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          content: Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    const Text("Time: "),
                    TextField(
                      controller: _time,
                    )
                  ],
                ),
                Row(
                  children: [
                    Text("Priority: "),
                  ],
                ),
                Text("Content: "),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: new Text("취소"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: new Text("저장"),
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
              child: Text(
                todayDate,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            Center(
              child: Container(
                width: 280,
                margin: EdgeInsets.all(40),
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: Column(
                  children: [
                    StreamBuilder(
                        stream: toDoList,
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          if (!snapshot.hasData)
                            return Text('Please fill your list');

                          return ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot data = snapshot.data.docs[index];

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.check_box_outline_blank),
                                    onPressed: () => null,
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        showContentDialog(context, data),
                                    child: Text(
                                      data['content'],
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }),
                    IconButton(
                        onPressed: () => addContentDialog(context),
                        icon: Icon(Icons.add))
                  ],
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
