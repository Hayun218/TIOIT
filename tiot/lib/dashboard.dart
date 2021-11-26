import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

var today = DateTime.now();
String todayDate = DateFormat('yyyy년 MM월 d일').format(DateTime.now());

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

Icon selectIcon(data) {
  if (data['status'] == "Complete") return Icon(Icons.check_box);
  if (data['status'] == "In Progress") return Icon(Icons.star_half);
  if (data['status'] == "Postponed") return Icon(Icons.forward);
  if (data['status'] == "Cancel")
    return Icon(Icons.cancel_presentation_outlined);

  return Icon(Icons.check_box_outline_blank);
}

class _DashboardPageState extends State<DashboardPage> {
  Stream toDoList = FirebaseFirestore.instance
      .collection('user')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('toDo')
      .where("date", isEqualTo: todayDate)
      .orderBy("priority")
      .orderBy("time")
      .limit(3)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "Hello, " + currentUser!.displayName.toString(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(currentUser.photoURL.toString()),
              ),
            ],
          ),
        ),
        Text("오늘의 문구"),
        SizedBox(height: 20),
        Center(
          child: Text(
            todayDate,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        Divider(),
        SizedBox(
          height: 300,
          child: Center(
            child: Text("pie chart"),
          ),
        ),
        Divider(),
        Center(
          child: Container(
            width: 280,
            child: StreamBuilder(
              stream: toDoList,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData) return Text('Please fill your list');

                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot data = snapshot.data.docs[index];

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: selectIcon(data),
                              onPressed: () => null,
                            ),
                            Expanded(
                              child: Text(
                                data['content'],
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 10, thickness: 1),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
