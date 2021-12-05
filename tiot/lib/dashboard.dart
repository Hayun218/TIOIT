import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'dart:convert'; //json으로 바꿔주기 위해 필요한 패키지
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';

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

late String lat;
late String lon;
Location location = Location();
late bool _serviceEnabled;
late PermissionStatus _permissionGranted;

Future<void> _locateMe() async {
  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      print("no service");
      return;
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return;
    }
  }

  var currentPosition = await Geolocator.getCurrentPosition();
  final coordinates =
      Coordinates(currentPosition.latitude, currentPosition.longitude);

  var addresses =
      await Geocoder.local.findAddressesFromCoordinates(coordinates);
  var first = addresses.first;
  print(
      ' ${first.locality}, ${first.adminArea},${first.subLocality}, ${first.subAdminArea},${first.addressLine}, ${first.featureName},${first.thoroughfare}, ${first.subThoroughfare}');

  lat = currentPosition.latitude.toString();
  lon = currentPosition.longitude.toString();
}

class Weather {
  final double temp; //현재 온도
  final double tempMin; //최저 온도
  final double tempMax; //최고 온도
  final String weatherMain; //흐림정도
  final int code; //흐림정도의 id(icon 작업시 필요)

  Weather({
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    required this.weatherMain,
    required this.code,
  });
}

Future<Weather?> getWeather() async {
  //api 호출을 위한 주소
  if (lat == "" || lon == "") {
    CircularProgressIndicator();
  }
  String apiAddr =
      "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=2548a763bdb778e939137dbaa880a353&units=metric";
  http.Response response; //http request의 결과 즉 api 호출의 결과를 받기 위한 변수
  var data1; //api 호출을 통해 받은 정보를 json으로 바꾼 결과를 저장한다.
  Weather? weather;
  try {
    response = await http.get(Uri.parse(apiAddr)); //필요 api 호출
    data1 = json.decode(response.body); //받은 정보를 json형태로 decode
    //받은 데이터정보를 필요한 형태로 저장한다.
    weather = Weather(
        temp: data1["main"]["temp"].toDouble(),
        tempMax: data1["main"]["temp_max"].toDouble(),
        tempMin: data1["main"]["temp_min"].toDouble(),
        weatherMain: data1["weather"][0]
            ["main"], //weather부분의 경우 리스트로 json에 들어가고 있기 때문에 첫번째것을 쓴다고 표시를 해준다.
        code: data1["weather"][0]
            ["id"]); //weather부분의 경우 리스트로 json에 들어가고 있기 때문에 첫번째것을 쓴다고 표시를 해준다.
  } catch (e) {
    weather = null;
    print("something wrong");
    print(e);
  }

  return weather;
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
    _locateMe();

    //_determinePosition();
    User? currentUser = FirebaseAuth.instance.currentUser;
    return ListView(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "Hello, " + currentUser!.displayName.toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        NetworkImage(currentUser.photoURL.toString()),
                  ),
                ],
              ),
            ),
            FutureBuilder(
                future: getWeather(), //future작업을 진행할 함수
                //snapshot은 getWeather()에서 return해주는 타입에 맞추어 사용한다.
                builder: (context, AsyncSnapshot<Weather?> snapshot) {
                  //데이터가 만약 들어오지 않았을때는 뱅글뱅글 로딩이 뜬다
                  if (snapshot.hasData == false) {
                    return CircularProgressIndicator();
                  }
                  //데이터가 제대로 불러와진 경우 현재온도, 최저,최고 온도와 코드에 따른 아이콘을 표시하는 부분
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('현재 온도 : ${snapshot.data!.temp.toString()}'),
                      Text('최저 온도 : ${snapshot.data!.tempMin.toString()}'),
                      Text('최고 온도 : ${snapshot.data!.tempMax.toString()}'),
                      //아이콘의 경우 적절한것이 기본적으로 제공이 되지 않고 있다. 제대로된 앱을 위해서는 적절한 이미지를 삽입하는것이 옳은것 같다.
                      snapshot.data!.code == 800
                          ? Icon(Icons.wb_sunny)
                          : snapshot.data!.code / 100 == 8 ||
                                  snapshot.data!.code / 100 == 2
                              ? Icon(Icons.wb_cloudy)
                              : snapshot.data!.code / 100 == 3 ||
                                      snapshot.data!.code / 100 == 5
                                  ? Icon(Icons.beach_access)
                                  : snapshot.data!.code / 100 == 6
                                      ? Icon(Icons.ac_unit)
                                      : Icon(Icons.cloud_circle)
                    ],
                  );
                }),
            const SizedBox(height: 10),
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
            SizedBox(height: 10),
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
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
    double result = 0;
    for (var document in documents) {
      if (document.id == days[index]) {
        comp = document.data()["completed"].toDouble();
        total = document.data()["totalN"].toDouble();
        if (total == 0) return 0;
        result = ((comp / total) * 100).roundToDouble();

        return result;
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
