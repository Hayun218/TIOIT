import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:restart_app/restart_app.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'languages_screen.dart';
import 'fonts.dart';

class SettingsScreen extends StatefulWidget {
  final Function() signOut;

  const SettingsScreen({Key? key, required this.signOut}) : super(key: key);
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  bool lockInBackground = true;
  bool notificationsEnabled = true;

  void flutterDialog() {
    showDialog(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          //Dialog Main Title
          title: Column(
            children: <Widget>[
              new Text("앱을 재시작합니다."),
            ],
          ),
          //
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "재시작하려면 확인버튼을 누르세요",
              ),
            ],
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text("확인"),
              onPressed: () {
                Restart.restartApp();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        bottomOpacity: 0,
        elevation: 0,
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, " + currentUser!.displayName.toString(),
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Let's set you all up and ready",
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(currentUser.photoURL.toString()),
              ),
            ],
          ),
          SizedBox(height: 10),
          buildSettingsList(),
        ],
      ),
    );
  }

  Widget buildSettingsList() {
    return Expanded(
      child: SettingsList(
        backgroundColor: Colors.white,
        sections: [
          SettingsSection(
            title: 'Common',
            tiles: [
              SettingsTile(
                title: 'Language',
                subtitle: 'Korean',
                leading: Icon(Icons.language),
                onPressed: (context) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => LanguagesScreen(),
                  ));
                },
              ),
//            CustomTile(
//              child: Container(
//                color: Color(0xFFEFEFF4),
//                padding: EdgeInsetsDirectional.only(
//                  start: 14,
//                  top: 12,
//                  bottom: 30,
//                  end: 14,
//                ),
//                child: Text(
//                  'You can setup the language you want',
//                  style: TextStyle(
//                    color: Colors.grey.shade700,
//                    fontWeight: FontWeight.w400,
//                    fontSize: 13.5,
//                    letterSpacing: -0.5,
//                  ),
//                ),
//              ),
//            ),
              SettingsTile(
                title: 'Font',
                subtitle: 'Production',
                leading: Icon(Icons.cloud_queue),
                onPressed: (context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FontPage()),
                  );
                },
              ),
            ],
          ),
          SettingsSection(
            title: 'Account',
            tiles: [
              SettingsTile(
                title: '계정 정보 변경',
                leading: Icon(Icons.account_circle),
                onPressed: (context) {},
              ),
              SettingsTile(
                title: 'Sign out',
                leading: Icon(Icons.exit_to_app),
                onPressed: (context) {
                  auth.signOut();
                  Navigator.pop(context);
                  widget.signOut();
                },
              ),
            ],
          ),
          SettingsSection(
            title: 'Security',
            tiles: [
              SettingsTile.switchTile(
                title: 'Lock app in background',
                leading: Icon(Icons.phonelink_lock),
                switchValue: lockInBackground,
                onToggle: (bool value) {
                  setState(() {
                    lockInBackground = value;
                    notificationsEnabled = value;
                  });
                },
              ),
              SettingsTile.switchTile(
                title: 'Use fingerprint',
                subtitle: 'Allow application to access stored fingerprint IDs.',
                leading: Icon(Icons.fingerprint),
                onToggle: (bool value) {},
                switchValue: false,
              ),
              SettingsTile.switchTile(
                title: 'Change password',
                leading: Icon(Icons.lock),
                switchValue: true,
                onToggle: (bool value) {},
              ),
              SettingsTile.switchTile(
                title: 'Enable Notifications',
                enabled: notificationsEnabled,
                leading: Icon(Icons.notifications_active),
                switchValue: true,
                onToggle: (value) {},
              ),
              SettingsTile(
                title: 'Restart App',
                leading: Icon(Icons.restart_alt),
                onPressed: (context) => flutterDialog(),
              ),
              SettingsTile(
                title: 'Version',
                leading: Icon(Icons.check),
                onPressed: (context) {
                  final snackBar = SnackBar(
                    content: Text('Version: 1.0.0'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
              ),
            ],
          ),
//          CustomSection(
//            child: Column(
//              children: [
//                Text(
//                  'Version: 0.12.2',
//                  style: TextStyle(color: Color(0xFF777777)),
//                ),
//              ],
//            ),
//          ),
        ],
      ),
    );
  }
}
