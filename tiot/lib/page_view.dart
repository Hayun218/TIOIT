import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'todo.dart';
import 'dashboard.dart';
import 'diary.dart';
import 'badge.dart';

class Pages extends StatefulWidget {
  const Pages({Key? key}) : super(key: key);

  @override
  _PagesState createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  @override
  Widget build(BuildContext context) {
    return PageView(
      children: [
        DashboardPage(),
        ToDoPage(),
        DiaryPage(),
        BadgedPage(),
      ],
    );
  }
}
