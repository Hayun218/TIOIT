import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'todo.dart';
import 'dashboard.dart';
import 'diary.dart';
import 'badge.dart';

final controller = PageController(
  initialPage: 0,
);
int pageChanged = 0;

BottomAppBar appBar(BuildContext context) {
  return BottomAppBar(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // TODO: modify
        IconButton(
          onPressed: () => controller.jumpToPage(0),
          icon: Icon(pageChanged == 0 ? Icons.home : Icons.home_outlined),
        ),
        IconButton(
          onPressed: () => controller.jumpToPage(1),
          icon: Icon(
              pageChanged == 1 ? Icons.fact_check : Icons.fact_check_outlined),
        ),
        IconButton(
          onPressed: () => controller.jumpToPage(2),
          icon:
              Icon(pageChanged == 2 ? Icons.note_alt : Icons.note_alt_outlined),
        ),
        IconButton(
          onPressed: () => controller.jumpToPage(3),
          icon: Icon(pageChanged == 3
              ? Icons.calendar_today
              : Icons.calendar_today_outlined),
        ),
        IconButton(
          onPressed: () => controller.jumpToPage(4),
          icon: Icon(pageChanged == 4
              ? Icons.account_circle
              : Icons.account_circle_outlined),
        ),
      ],
    ),
  );
}

class Pages extends StatefulWidget {
  const Pages({Key? key}) : super(key: key);

  @override
  _PagesState createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: appBar(context),
      body: PageView(
        controller: controller,
        onPageChanged: (index) {
          setState(() {
            pageChanged = index;
          });
        },
        children: [
          DashboardPage(),
          DiaryPage(),
          ToDoPage(),
          DiaryPage(),
          BadgedPage(),
        ],
      ),
    );
  }
}
