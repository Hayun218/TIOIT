import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

DateTime selectedDate = DateTime.now();
String todayDate = DateFormat('yyyy년 MM월 d일').format(selectedDate);
String displayDate = DateFormat('MM월 d일').format(selectedDate);

class SetDate {
  void setDate(DateTime selectedDay) {
    displayDate = DateFormat('MM월 d일').format(selectedDay);
  }
}

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

// Collection 에 Diary Docs  추가하기
Future addDiary(String uid) async {
  List<String> list = [];

  var check = await FirebaseFirestore.instance
      .collection('user')
      .doc(uid)
      .collection('diary')
      .doc(todayDate)
      .get();

  if (!check.exists) {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('diary')
        .doc(todayDate)
        .set({"long_diary": "", "thanks": list, "photoUrl": ""});
  } else {
    return null;
  }
}

bool _defaultImg = true;

class _DiaryPageState extends State<DiaryPage> {
  File? _image;
  firebase_storage.FirebaseStorage firebaseStorage =
      firebase_storage.FirebaseStorage.instance;

  Future saveThanks(TextEditingController one, TextEditingController two,
      TextEditingController three, String uid) async {
    List<String> thanks = [];
    thanks.add(one.text);
    thanks.add(two.text);
    thanks.add(three.text);
    print(uid);
    try {
      _image ??=
          await urlToFile('https://handong.edu/site/handong/res/img/logo.png');
      // storage 업로드 파일 경로
      final firebaseStorageRef = firebaseStorage
          .ref()
          .child('post')
          .child('/${DateTime.now().millisecondsSinceEpoch.toString()}.png');
      // 파일 업로드
      final uploadTask = firebaseStorageRef.putFile(
          _image!, firebase_storage.SettableMetadata(contentType: 'image/png'));
      // 완료 대기
      await uploadTask.whenComplete(() => null);
      // 업로드 완료 후 url
      final downloadUrl = await firebaseStorageRef.getDownloadURL();
      return FirebaseFirestore.instance
          .collection('user')
          .doc(uid)
          .collection('diary')
          .doc(todayDate)
          .set(
        {"thanks": thanks, "photoUrl": downloadUrl},
        SetOptions(merge: true),
      ).then((value) => print("saved"));
    } catch (e) {
      print(e);
    }
  }

  Future<File> urlToFile(String imageUrl) async {
    var rng = Random();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = File(tempPath + (rng.nextInt(100)).toString() + '.png');
    http.Response response = await http.get(Uri.parse(imageUrl));
    await file.writeAsBytes(response.bodyBytes);
    _image = file;
    return file;
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageTemporary = File(image.path);
      setState(() => _image = imageTemporary);
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print("Failed to pick image: $e");
    }
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
              margin: EdgeInsets.fromLTRB(200, 30, 0, 0),
              child: IconButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate, // Refer step 1
                      firstDate: DateTime(2021, 11, 20),
                      lastDate: DateTime.now(),
                    );

                    diary = FirebaseFirestore.instance
                        .collection('user')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('diary')
                        .doc(todayDate)
                        .snapshots();

                    if (picked != null && picked != selectedDate) {
                      setState(() {
                        selectedDate = picked;
                        todayDate =
                            DateFormat('yyyy년 MM월 d일').format(selectedDate);
                        addDiary(FirebaseAuth.instance.currentUser!.uid);

                        displayDate = DateFormat('MM월 d일').format(selectedDate);
                      });
                    }
                  },
                  icon: Icon(Icons.calendar_today)),
            ),
            Container(
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
              width: 200,
              height: 200,
              child: _image == null
                  ? Image.network(
                      'http://handong.edu/site/handong/res/img/logo.png',
                      fit: BoxFit.contain,
                    )
                  : Image.file(_image!),
            ),
            Container(
              alignment: Alignment.topRight,
              child: IconButton(
                  onPressed: () {
                    // toDo: lost connection error..
                    pickImage();
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
                    addDiary(FirebaseAuth.instance.currentUser!.uid);

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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              LongDiary(selectedDate: todayDate)));
                }),
          ),
        ),
      ],
    );
  }
}
