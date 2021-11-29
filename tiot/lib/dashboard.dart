import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tiot/words.dart';
import 'package:weather/weather.dart';
import 'package:location/location.dart';

WeatherFactory wf = WeatherFactory("2548a763bdb778e939137dbaa880a353");
String cityName = "Pohang";

getWeather() async {
  Weather w = await wf.currentWeatherByCityName(cityName);
  double? celsius = w.temperature!.celsius;

  return celsius;
}

var today = DateTime.now();
var format = DateFormat('yyyy년 MM월 d일');
String todayDate = format.format(DateTime.now());
String firstDate = format.format(today.subtract(const Duration(days: 6)));
String secondDate = format.format(today.subtract(const Duration(days: 5)));
String thirdDate = format.format(today.subtract(const Duration(days: 4)));
String fourthDate = format.format(today.subtract(const Duration(days: 3)));
String fifthDate = format.format(today.subtract(const Duration(days: 2)));
String sixthDate = format.format(today.subtract(const Duration(days: 1)));
List<String> days = [
  firstDate,
  secondDate,
  thirdDate,
  fourthDate,
  fifthDate,
  sixthDate,
  todayDate
];

String greeting() {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Morning';
  }
  if (hour < 17) {
    return 'Afternoon';
  }
  return 'Evening';
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

Icon selectIcon(data) {
  if (data['status'] == "Complete") return Icon(Icons.check_box);
  if (data['status'] == "In Progress") return Icon(Icons.star_half);
  if (data['status'] == "Postponed") return Icon(Icons.forward);
  if (data['status'] == "Cancel") {
    return Icon(Icons.cancel_presentation_outlined);
  }

  return const Icon(Icons.check_box_outline_blank);
}

class _DashboardPageState extends State<DashboardPage> {
  Stream toDoList = FirebaseFirestore.instance
      .collection('user')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('toDo')
      .where("date", isEqualTo: todayDate)
      .orderBy("priority")
      .orderBy("time")
      .limit(3)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "Hello, " + currentUser!.displayName.toString(),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(currentUser.photoURL.toString()),
              ),
            ],
          ),
        ),
        SizedBox(height: 23),
        if (greeting() == "Morning")
          Text(
            (morning.toList()..shuffle()).first,
            style: TextStyle(fontSize: 15),
          ),
        if (greeting() == "Afternoon")
          Text(
            (afternoon.toList()..shuffle()).first,
            style: TextStyle(fontSize: 15),
          ),
        if (greeting() == "Evening")
          Text(
            (goodWords.toList()..shuffle()).first,
            style: TextStyle(fontSize: 15),
          ),
        SizedBox(height: 40),
        Center(
          child: Text(
            todayDate,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(20),
          child: Center(
            child: LineChartSample2(),
          ),
        ),
        Divider(),
        Center(
          child: Container(
            width: 280,
            child: StreamBuilder(
              stream: toDoList,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData) return LoadingFlipping.circle();

                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot data = snapshot.data.docs[index];

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: selectIcon(data),
                              onPressed: () => null,
                            ),
                            Expanded(
                              child: Text(
                                data['content'],
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 10, thickness: 1),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class LineChartSample2 extends StatefulWidget {
  const LineChartSample2({Key? key}) : super(key: key);

  @override
  _LineChartSample2State createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  Stream toDoData = FirebaseFirestore.instance
      .collection('user')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('statistic')
      .where(FieldPath.documentId, whereIn: days)
      .snapshots();

  List<Color> gradientColors = [
    const Color(0xff90caf9),
    const Color(0xff2196f3),
  ];

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.30,
          child: Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(18),
                ),
                color: Color(0xffe3f2fd)),
            child: Padding(
              padding: const EdgeInsets.only(
                  right: 18.0, left: 12.0, top: 24, bottom: 12),
              child: StreamBuilder(
                  stream: toDoData,
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData) {
                      return LoadingFlipping.circle();
                    }

                    List<DocumentSnapshot> documents = snapshot.data.docs;

                    return LineChart(
                        showAvg ? showPer(documents) : mainData(documents));
                  }),
            ),
          ),
        ),
        SizedBox(
          width: 60,
          height: 34,
          child: TextButton(
            onPressed: () {
              setState(() {
                showAvg = !showAvg;
              });
            },
            child: Text(
              'per',
              style: TextStyle(
                  fontSize: 12,
                  color:
                      showAvg ? Colors.black.withOpacity(0.3) : Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData mainData(documents) {
    return LineChartData(
      gridData: FlGridData(
        show: false,
        drawVerticalLine: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 20,
          interval: 1,
          getTextStyles: (context, value) =>
              const TextStyle(color: Color(0xff68737d), fontSize: 12),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return firstDate.split(" ")[2];
              case 2:
                return secondDate.split(" ")[2];
              case 3:
                return thirdDate.split(" ")[2];
              case 4:
                return fourthDate.split(" ")[2];
              case 5:
                return fifthDate.split(" ")[2];
              case 6:
                return sixthDate.split(" ")[2];
              case 7:
                return todayDate.split(" ")[2];
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTextStyles: (context, value) => const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return '0';
              case 3:
                return '3';
              case 6:
                return '6';
            }
            return '';
          },
          reservedSize: 32,
          margin: 13,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: 7,
      minY: 0,
      maxY: 8,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, 0),
            FlSpot(1, findSpot(documents, 0)),
            FlSpot(2, findSpot(documents, 1)),
            FlSpot(3, findSpot(documents, 2)),
            FlSpot(4, findSpot(documents, 3)),
            FlSpot(5, findSpot(documents, 4)),
            FlSpot(6, findSpot(documents, 5)),
            FlSpot(7, findSpot(documents, 6)),
          ],
          isCurved: true,
          colors: gradientColors,
          barWidth: 5,
          isStrokeCapRound: false,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }

  double findSpot(documents, int index) {
    for (var document in documents) {
      if (document.id == days[index]) {
        return document.data()["completed"].toDouble();
      }
    }
    return 0;
  }

  double findPer(documents, int index) {
    double comp = 0;
    double total = 0;
    for (var document in documents) {
      if (document.id == days[index]) {
        comp = document.data()["completed"].toDouble();
        total = document.data()["totalN"].toDouble();
        if (total == 0) return 0;
        return ((comp / total) * 100).roundToDouble();
      }
    }
    return 0;
  }

  LineChartData showPer(documents) {
    return LineChartData(
      gridData: FlGridData(
        show: false,
        drawVerticalLine: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 20,
          interval: 1,
          getTextStyles: (context, value) =>
              const TextStyle(color: Color(0xff68737d), fontSize: 12),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return firstDate.split(" ")[2];
              case 2:
                return secondDate.split(" ")[2];
              case 3:
                return thirdDate.split(" ")[2];
              case 4:
                return fourthDate.split(" ")[2];
              case 5:
                return fifthDate.split(" ")[2];
              case 6:
                return sixthDate.split(" ")[2];
              case 7:
                return todayDate.split(" ")[2];
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTextStyles: (context, value) => const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return '0';
              case 50:
                return '50';
              case 100:
                return '100';
            }
            return '';
          },
          reservedSize: 32,
          margin: 13,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: 7,
      minY: 0,
      maxY: 110,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, 0),
            FlSpot(1, findPer(documents, 0)),
            FlSpot(2, findPer(documents, 1)),
            FlSpot(3, findPer(documents, 2)),
            FlSpot(4, findPer(documents, 3)),
            FlSpot(5, findPer(documents, 4)),
            FlSpot(6, findPer(documents, 5)),
            FlSpot(7, findPer(documents, 6)),
          ],
          isCurved: true,
          colors: gradientColors,
          barWidth: 5,
          isStrokeCapRound: false,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }
}
