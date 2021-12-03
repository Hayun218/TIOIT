import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restart_app/restart_app.dart';

import 'font.dart';
import 'font_provider.dart';
import 'main.dart';

class FontPage extends StatelessWidget {
  String _selectedFont = "";

  void onThemeChange(String value, ThemeNotifier? themeNotifier) async {
    if (value == "NanumGothic") {
      themeNotifier = themeNotifier!.setTheme(nanumGothic);
    } else if (value == "NanumPenScript") {
      themeNotifier = themeNotifier!.setTheme(nanumPenScript);
    } else if (value == "NotoSansKR") {
      themeNotifier = themeNotifier!.setTheme(notoSansKR);
    } else if (value == "RobotoMono") {
      themeNotifier = themeNotifier!.setTheme(robotoMono);
    } else if (value == "Raleway") {
      themeNotifier = themeNotifier!.setTheme(raleway);
    }
    final pref = await SharedPreferences.getInstance();
    pref.setString("ThemeMode", value);
    print("저장하는 폰트: " + value);
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    themeNotifier.getTheme;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Fonts',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        bottomOpacity: 0,
        elevation: 0,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text(
              "NanumGothic",
              style: TextStyle(fontFamily: 'NanumGothic'),
            ),
            onTap: () {
              _selectedFont = 'NanumGothic';
              onThemeChange(_selectedFont, themeNotifier);
              print(_selectedFont);
              Navigator.pop(context);
//              Restart.restartApp();
            },
          ),
          ListTile(
            title: const Text(
              "NanumPenScript",
              style: TextStyle(fontFamily: 'NanumPenScript'),
            ),
            onTap: () {
              _selectedFont = 'NanumPenScript';
              onThemeChange(_selectedFont, themeNotifier);
              print(_selectedFont);
              Navigator.pop(context);
//              Restart.restartApp();
            },
          ),
          ListTile(
            title: const Text(
              "NotoSansKR",
              style: TextStyle(fontFamily: 'NotoSansKR'),
            ),
            onTap: () {
              _selectedFont = 'NotoSansKR';
              onThemeChange(_selectedFont, themeNotifier);
              print(_selectedFont);
              Navigator.pop(context);
//              Restart.restartApp();
            },
          ),
          ListTile(
            title: const Text(
              "Roboto Mono sample",
              style: TextStyle(fontFamily: 'RobotoMono'),
            ),
            onTap: () {
              _selectedFont = 'RobotoMono';
              onThemeChange(_selectedFont, themeNotifier);
              print(_selectedFont);
              Navigator.pop(context);
//              Restart.restartApp();
            },
          ),
          ListTile(
            title: const Text(
              "Raleway",
              style: TextStyle(fontFamily: 'Raleway'),
            ),
            onTap: () {
              _selectedFont = 'Raleway';
              onThemeChange(_selectedFont, themeNotifier);
              print(_selectedFont);
              Navigator.pop(context);
//              Restart.restartApp();
            },
          ),
        ],
      ),
    );
  }
}
