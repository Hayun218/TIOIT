import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const String groupKey = 'lydia.tiot';
const String ChannelId = 'gourped channel id';
const String ChannelName = 'grouped channel name';
const String ChannelDescription = 'grouped channel description';

Future<void> initialize() async {
  tz.initializeTimeZones();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  // 알림 초기화
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {
    // onSelectNotification: 알림을 선택했을 때 발생
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
  });
}

class PushNotifications {
  Future<void> setPushNotification(int id, String content, String date) async {
    final birthday = DateTime(2021, 11, 29, 11, 00);
    final date2 = DateTime.now();
    final difference = date2.difference(birthday).inMinutes;
    initialize();
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'add',
        'first add list: ' + content + "\ntime" + difference.toString(),
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                ChannelId, ChannelName, ChannelDescription)),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> modifyNotifications(int id, String content, String date) async {
    initialize();
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        "modify",
        "modify todo list: " + content,
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5, minutes: 0)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                ChannelId, ChannelName, ChannelDescription)),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> deleteNotifications(int id) async {
    initialize();
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        "delete",
        "delete todo list: id - " + id.toString(),
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5, minutes: 0)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                ChannelId, ChannelName, ChannelDescription)),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
    await flutterLocalNotificationsPlugin.cancel(1);
  }
}
