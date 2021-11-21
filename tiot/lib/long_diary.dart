import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_animations/loading_animations.dart';

var today = DateTime.now();
String todayDate = DateFormat('yyyy년 MM월 d일').format(DateTime.now());
User user = FirebaseAuth.instance.currentUser!;

CollectionReference user_diary = FirebaseFirestore.instance
    .collection('user')
    .doc(user.uid)
    .collection('diary');

Stream longDiary = FirebaseFirestore.instance
    .collection('user')
    .doc(user.uid)
    .collection('diary')
    .doc(todayDate)
    .snapshots();

Future<void> saveLongDiary(TextEditingController ctrl) {
  return user_diary.doc(todayDate).set(
    {"long_diary": ctrl.text},
    SetOptions(merge: true),
  ).then((value) => print("Save Long Diary"));
}

Future<void> deleteLongDiary() {
  return user_diary.doc(todayDate).set({
    "long_diary": "",
  }).then((value) => print("Deleted Long Diary"));
}

Future<void> makeLongDiary() {
  return user_diary.doc(todayDate).set({}, SetOptions(merge: true)).then(
      (value) => print("Create Long Diary Docs for" + todayDate));
}

TextEditingController _diaryCtrl = TextEditingController();

class LongDiary extends StatefulWidget {
  @override
  _LongDiaryState createState() => _LongDiaryState();
}

class _LongDiaryState extends State<LongDiary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: longDiary,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            makeLongDiary();
            return LoadingFlipping.circle();
          }

          _diaryCtrl = TextEditingController(text: snapshot.data['long_diary']);

          return ListView(
            children: [
              SizedBox(height: 40),
              Center(
                child: Text(
                  todayDate,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
              SizedBox(height: 10),
              Container(
                margin: EdgeInsets.all(30),
                child: TextField(
                  controller: _diaryCtrl,
                  minLines: 28,
                  keyboardType: TextInputType.multiline,
                  maxLines: 28,
                  decoration: InputDecoration(
                    hintText: 'Long Diary',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                ),
              ),
              ButtonBar(
                children: [
                  TextButton(
                    onPressed: () {
                      _diaryCtrl.clear();
                      Navigator.pop(context);
                    },
                    child: Text("취소"),
                  ),
                  TextButton(
                    onPressed: () {
                      deleteLongDiary();
                      _diaryCtrl.clear();
                      Navigator.pop(context);
                    },
                    child: Text("삭제"),
                  ),
                  TextButton(
                    onPressed: () {
                      saveLongDiary(_diaryCtrl);
                      _diaryCtrl.clear();
                      Navigator.pop(context);
                    },
                    child: Text("저장"),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
