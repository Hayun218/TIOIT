import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'font.dart';
import 'font_provider.dart';
import 'login.dart';
import 'first_screen.dart';
import 'main.dart';

class TioT extends StatelessWidget {
  const TioT({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      theme: themeNotifier.getTheme,
      debugShowCheckedModeBanner: false,
      title: 'TioT',
      home: SafeArea(
        child: FirstScreen(),
      ),
    );
  }
}
