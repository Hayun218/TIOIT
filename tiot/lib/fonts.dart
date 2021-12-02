import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FontPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                print("font1");
              },
            ),
            ListTile(
              title: const Text(
                "NanumPenScript",
                style: TextStyle(fontFamily: 'NanumPenScript'),
              ),
              onTap: () {
                print("font2");
              },
            ),
            ListTile(
              title: const Text(
                "NotoSansKR",
                style: TextStyle(fontFamily: 'NotoSansKR'),
              ),
              onTap: () {
                print("font3");
              },
            ),
            ListTile(
              title: const Text(
                "Roboto Mono sample",
                style: TextStyle(fontFamily: 'RobotoMono'),
              ),
              onTap: () {
                print("font4");
              },
            ),
            ListTile(
              title: const Text(
                "Raleway",
                style: TextStyle(fontFamily: 'Raleway'),
              ),
              onTap: () {
                print("font5");
              },
            ),
          ],
        ));
  }
}
