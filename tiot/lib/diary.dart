import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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

TextEditingController _shortDiary = TextEditingController();

class _DiaryPageState extends State<DiaryPage> {
  CollectionReference products = FirebaseFirestore.instance.collection('diary');

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 200,
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
            Container(
              margin: EdgeInsets.all(30),
              child: TextField(
                controller: _shortDiary,
                maxLines: 3,
                minLines: 3,
              ),
            )
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
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LongDiary()))),
          ),
        ),
      ],
    );
  }
}
