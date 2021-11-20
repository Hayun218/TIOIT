import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tiot/page_view_state.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'page_view_state.dart';

final controller = PageController(
  initialPage: 0,
);
int pageChanged = 0;

BottomAppBar appBar(BuildContext context) {
  return BottomAppBar(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
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
    return Consumer<BottomAppBarProvider>(
      builder: (context, appState, _) => HighlightPage(
        pageState: appState.pageState,
        pageFlow: appState.pageFlow,
        signOut: appState.signOut,
      ),
    );
  }
}
