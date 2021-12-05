import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'setting.dart';

var today = DateTime.now();
String todayDate = DateFormat('yyyy년 MM월 d일').format(DateTime.now());

class BadgedPage extends StatefulWidget {
  final Function() signOut;
  const BadgedPage({Key? key, required this.signOut}) : super(key: key);

  @override
  State<BadgedPage> createState() => _BadgedPageState();
}

bool isChecked = false;

initStream(String month) {
  return FirebaseFirestore.instance
      .collection('user')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('statistic')
      .where('date', isEqualTo: month)
      .snapshots();
}

class _BadgedPageState extends State<BadgedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Center(
          child: Text(
            "Badge",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        bottomOpacity: 0,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(signOut: widget.signOut),
                ),
              );
            },
            color: Colors.black,
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 9 / 10,
              children: List.generate(12, (index) {
                String thisM = DateFormat('yy년').format(DateTime.now());
                String month = "$thisM ${index + 1}월";
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(month),
                      const SizedBox(height: 10),
                      StreamBuilder(
                        stream: initStream("20" + month),
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          if (!snapshot.hasData) {
                            return LoadingFlipping.circle();
                          }
                          double totalP = 0;
                          int docN = snapshot.data.docs.length;

                          if (docN == 0) {
                            isChecked = false;
                          } else {
                            for (int i = 0; i < docN - 1; i++) {
                              totalP += snapshot.data.docs[i]!['percentage'];
                            }
                            if ((totalP / docN) >= 30) {
                              isChecked = true;
                            } else {
                              isChecked = false;
                            }
                            print((totalP / docN));
                          }
                          return Image.asset(
                            isChecked
                                ? "assets/checked_badge.png"
                                : "assets/unchecked_badge.png",
                            height: 80,
                            width: 80,
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}
