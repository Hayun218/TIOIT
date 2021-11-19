import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'languages_screen.dart';

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
        title: Text(
          'Settings UI',
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
                subtitle: 'English',
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
                title: 'Environment',
                subtitle: 'Production',
                leading: Icon(Icons.cloud_queue),
              ),
            ],
          ),
          SettingsSection(
            title: 'Account',
            tiles: [
              SettingsTile(title: 'Phone number', leading: Icon(Icons.phone)),
              SettingsTile(title: 'Email', leading: Icon(Icons.email)),
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
            ],
          ),
          SettingsSection(
            title: 'Misc',
            tiles: [
              SettingsTile(
                  title: 'Terms of Service', leading: Icon(Icons.description)),
              SettingsTile(
                  title: 'Open source licenses',
                  leading: Icon(Icons.collections_bookmark)),
            ],
          ),
          CustomSection(
            child: Column(
              children: [
                Text(
                  'Version: 2.4.0 (287)',
                  style: TextStyle(color: Color(0xFF777777)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
