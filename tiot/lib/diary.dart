import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
// ignore: import_of_legacy_library_into_null_safe
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tiot/long_diary.dart';

var today = DateTime.now();
String todayDate = DateFormat('yyyy년 MM월 d일').format(DateTime.now());
String displayDate = DateFormat('MM월 d일').format(DateTime.now());
late File _image;
bool _defaultImg = true;

class DiaryPage extends StatefulWidget {
  const DiaryPage({Key? key}) : super(key: key);

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

Future<String> fileToStorage() async {
  FirebaseStorage firebaseStorageRef = FirebaseStorage.instance;
  var _url;

  String fileName = basename(_image.path);

  Reference refBS = firebaseStorageRef.ref().child('diary').child(fileName);

  var uploadTask = await refBS.putFile(_image);

  _url = await uploadTask.ref.getDownloadURL();

  return _url;
}

_getFromGallery() async {
  PickedFile? pickedFile = await ImagePicker().getImage(
    source: ImageSource.gallery,
    maxWidth: 300,
    maxHeight: 400,
  );
  if (pickedFile != null) {
    _image = File(pickedFile.path);
    _defaultImg = false;
  }
}

User user = FirebaseAuth.instance.currentUser!;

CollectionReference user_diary = FirebaseFirestore.instance
    .collection('user')
    .doc(user.uid)
    .collection('diary');

Stream diary = FirebaseFirestore.instance
    .collection('user')
    .doc(user.uid)
    .collection('diary')
    .doc(todayDate)
    .snapshots();

TextEditingController _thanks1 = TextEditingController();
TextEditingController _thanks2 = TextEditingController();
TextEditingController _thanks3 = TextEditingController();

Future saveThanks(TextEditingController one, TextEditingController two,
    TextEditingController three) {
  List<String> thanks = [];
  thanks.add(one.text);
  thanks.add(two.text);
  thanks.add(three.text);

  return user_diary.doc(todayDate).set(
    {"thanks": thanks},
    SetOptions(merge: true),
  ).then((value) => print("saved"));
}

class _DiaryPageState extends State<DiaryPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 130,
              child: Center(
                child: Text(
                  displayDate + " 감사일기",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
            ),
            Container(
              width: 250,
              height: 280,
              child: _defaultImg
                  ? Image.network(
                      'http://handong.edu/site/handong/res/img/logo.png',
                      fit: BoxFit.contain,
                    )
                  : Image.file(File(_image.path)),
            ),
            Container(
              alignment: Alignment.topRight,
              child: IconButton(
                  onPressed: () {
                    // lost connection error.. why?
                    _getFromGallery();
                  },
                  icon: Icon(Icons.camera)),
            ),
            StreamBuilder(
                stream: longDiary,
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData) {
                    return LoadingFlipping.circle();
                  }
                  List<String> data =
                      List<String>.from(snapshot.data['thanks']);

                  if (data.isNotEmpty && data[0].isNotEmpty) {
                    _thanks1 =
                        TextEditingController(text: snapshot.data['thanks'][0]);
                  }
                  if (data.isNotEmpty && data[1].isNotEmpty) {
                    _thanks2 =
                        TextEditingController(text: snapshot.data['thanks'][1]);
                  }
                  if (data.isNotEmpty && data[2].isNotEmpty) {
                    _thanks3 =
                        TextEditingController(text: snapshot.data['thanks'][2]);
                  }

                  return Container(
                    margin: EdgeInsets.fromLTRB(40, 0, 40, 0),
                    child: Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            labelText: '1st Thanks',
                          ),
                          keyboardType: TextInputType.multiline,
                          controller: _thanks1,
                          maxLines: 1,
                          minLines: 1,
                        ),
                        TextField(
                          decoration: InputDecoration(
                            labelText: '2nd Thanks',
                          ),
                          keyboardType: TextInputType.multiline,
                          controller: _thanks2,
                          maxLines: 1,
                          minLines: 1,
                        ),
                        TextField(
                          decoration: InputDecoration(
                            labelText: '3rd Thanks',
                          ),
                          keyboardType: TextInputType.multiline,
                          controller: _thanks3,
                          maxLines: 1,
                          minLines: 1,
                        ),
                        TextButton(
                            onPressed: () {
                              saveThanks(_thanks1, _thanks2, _thanks3);
                              _thanks1.clear();
                              _thanks2.clear();
                              _thanks3.clear();
                            },
                            child: Text("저장")),
                      ],
                    ),
                  );
                }),
          ],
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: IconButton(
                icon: Icon(
                  Icons.library_books_rounded,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LongDiary()));
                }),
          ),
        ),
      ],
    );
  }
}
