import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'font_provider.dart';
import 'first_screen.dart';

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
