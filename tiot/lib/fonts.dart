import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restart_app/restart_app.dart';

import 'font.dart';
import 'font_provider.dart';
import 'main.dart';

class FontPage extends StatefulWidget {
  @override
  State<FontPage> createState() => _FontPageState();
}

class _FontPageState extends State<FontPage> {
  final _inputController = TextEditingController();

  String _selectedFont = "";
  String inputText = "";

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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: ListView(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _inputController,
                    decoration: const InputDecoration(
                      labelText: 'Text',
                      hintText: '원하는 문구를 입력하세요',
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(width: 1, color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(width: 1, color: Colors.black),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ButtonBar(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              inputText = "";
                              _inputController.clear();
                              FocusScope.of(context).requestFocus(FocusNode());
                            });
                          },
                          child: Text("초기화"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              inputText = _inputController.text;
                              FocusScope.of(context).requestFocus(FocusNode());
                            });
                          },
                          child: Text("적용"),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            ListTile(
              title: Text(
                inputText == "" ? "NnumGothic" : inputText,
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
              title: Text(
                inputText == "" ? "NanumPenScript" : inputText,
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
              title: Text(
                inputText == "" ? "NotoSansKR" : inputText,
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
              title: Text(
                inputText == "" ? "RobotoMono" : inputText,
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
              title: Text(
                inputText == "" ? "Raleway" : inputText,
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
      ),
    );
  }
}
