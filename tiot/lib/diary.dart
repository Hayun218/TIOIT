import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
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

class DiaryPage extends StatefulWidget {
  const DiaryPage({Key? key}) : super(key: key);

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

Future saveThanks(TextEditingController one, TextEditingController two,
    TextEditingController three, String uid) {
  List<String> thanks = [];
  thanks.add(one.text);
  thanks.add(two.text);
  thanks.add(three.text);
  print(uid);

  return FirebaseFirestore.instance
      .collection('user')
      .doc(uid)
      .collection('diary')
      .doc(todayDate)
      .set(
    {"thanks": thanks},
    SetOptions(merge: true),
  ).then((value) => print("saved"));
}

bool _defaultImg = true;

class _DiaryPageState extends State<DiaryPage> {
  late File _image;

  Future<String> fileToStorage() async {
    FirebaseStorage firebaseStorageRef = FirebaseStorage.instance;
    String _url;

    String fileName = basename(_image.path);

    Reference refBS = firebaseStorageRef.ref().child('diary').child(fileName);

    var uploadTask = await refBS.putFile(_image);

    _url = await uploadTask.ref.getDownloadURL();

    return _url;
  }

  final _picker = ImagePicker();

  getFromGallery() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _image = File(image.path);
      _defaultImg = false;
    }
  }

  Stream diary = FirebaseFirestore.instance
      .collection('user')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('diary')
      .doc(todayDate)
      .snapshots();
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
                    // toDo: lost connection error..
                    getFromGallery();
                  },
                  icon: Icon(Icons.camera)),
            ),
            StreamBuilder(
                stream: diary,
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

                  TextEditingController _thanks1 = TextEditingController();
                  TextEditingController _thanks2 = TextEditingController();
                  TextEditingController _thanks3 = TextEditingController();

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
                              saveThanks(_thanks1, _thanks2, _thanks3,
                                  FirebaseAuth.instance.currentUser!.uid);
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
