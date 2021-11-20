import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'setting.dart';

var today = DateTime.now();
String todayDate = DateFormat('yyyy년 MM월 d일').format(DateTime.now());

class BadgedPage extends StatefulWidget {
  final Function() signOut;
  const BadgedPage({Key? key, required this.signOut}) : super(key: key);

  @override
  State<BadgedPage> createState() => _BadgedPageState();
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
          Container(
            child: Center(
              child: Text(
                todayDate + "\n Badge Page",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 9 / 10,
                children: List.generate(11, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text("21년 ${index + 1}월"),
                        SizedBox(height: 10),
                        Image.asset(
                          "assets/checked_badge.png",
                          height: 80,
                          width: 80,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          )
        ],
      ),
    );
  }
}
