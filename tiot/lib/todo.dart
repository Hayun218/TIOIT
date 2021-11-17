import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

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
          onPressed: () => Navigator.pushNamed(context, '/home'),
          icon: Icon(Icons.fact_check_outlined),
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/home'),
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

var today = DateTime.now();
String todayDate = DateFormat('yyyy년 MM월 d일').format(DateTime.now());

class ToDoPage extends StatefulWidget {
  const ToDoPage({Key? key}) : super(key: key);

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 150, 0, 0),
                child: Center(
                  child: Text(
                    todayDate + "\n Todo Page",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
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
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
