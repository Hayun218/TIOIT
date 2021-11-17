import 'package:flutter/material.dart';
import 'package:tiot/todo.dart';

import 'dashboard.dart';
import 'login.dart';
import 'todo.dart';
import 'first_screen.dart';

class TioT extends StatelessWidget {
  const TioT({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TioT',
      home: FirstScreen(),
      routes: {
        '/todo': (context) => ToDoPage(),
        '/dashboard': (context) => DashboardPage(),
      },
      //   onGenerateRoute: _getRoute,
    );
  }

  Route<dynamic>? _getRoute(RouteSettings settings) {
    if (settings.name != '/login') {
      return null;
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (BuildContext context) => LoginPage(),
      fullscreenDialog: true,
    );
  }
}
