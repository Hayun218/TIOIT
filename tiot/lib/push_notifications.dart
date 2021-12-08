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

bool isInt(String str) {
  if (str == null) {
    return false;
  }
  return int.tryParse(str) != null;
}

final List<int> timeList = [];

List<int> extractTime(String date, String time) {
  timeList.clear();
  timeList.add(int.parse(date.substring(0, 4)));
  if (isInt(date.substring(6, 8))) {
    timeList.add(int.parse(date.substring(6, 8)));
    if (isInt(date.substring(10, 12))) {
      timeList.add(int.parse(date.substring(10, 12)));
    } else {
      timeList.add(int.parse(date.substring(10, 11)));
    }
  } else {
    timeList.add(int.parse(date.substring(6, 7)));
    if (isInt(date.substring(9, 11))) {
      timeList.add(int.parse(date.substring(9, 11)));
    } else {
      timeList.add(int.parse(date.substring(9, 10)));
    }
  }
  timeList.add(int.parse(time.substring(0, 2)));
  timeList.add(int.parse(time.substring(3, 5)));
  return timeList;
}

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
  Future<void> setPushNotification(
      int id, String content, String date, String time) async {
    List<int> times = extractTime(date, time);
    final alert = DateTime(times[0], times[1], times[2], times[3], times[4]);
    final today = DateTime.now();
    final difference = alert.difference(today).inMinutes + 1;
    initialize();
    if (difference >= 10) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          'reminder',
          '[' + content + '] will begin in 10 minutes.',
          tz.TZDateTime.now(tz.local).add(Duration(minutes: difference - 10)),
          const NotificationDetails(
              android: AndroidNotificationDetails(
                  ChannelId, ChannelName, ChannelDescription)),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
    }
  }

  Future<void> modifyNotifications(
      int id, String content, String date, String time) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    List<int> times = extractTime(date, time);
    final alert = DateTime(times[0], times[1], times[2], times[3], times[4]);
    final today = DateTime.now();
    final difference = alert.difference(today).inMinutes + 1;
    initialize();
    if (difference >= 10) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          "reminder",
          '[' + content + '] will begin in 10 minutes.',
          tz.TZDateTime.now(tz.local).add(Duration(minutes: difference - 10)),
          const NotificationDetails(
              android: AndroidNotificationDetails(
                  ChannelId, ChannelName, ChannelDescription)),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
    }
  }

  Future<void> deleteNotifications(int id) async {
    initialize();
//    await flutterLocalNotificationsPlugin.zonedSchedule(
//        0,
//        "delete",
//        "delete todo list: id - " + id.toString(),
//        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5, minutes: 0)),
//        const NotificationDetails(
//            android: AndroidNotificationDetails(
//                ChannelId, ChannelName, ChannelDescription)),
//        androidAllowWhileIdle: true,
//        uiLocalNotificationDateInterpretation:
//            UILocalNotificationDateInterpretation.absoluteTime);
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
