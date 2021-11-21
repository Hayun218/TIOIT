import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'dashboard.dart';

class MonthlyPage extends StatefulWidget {
  const MonthlyPage({Key? key}) : super(key: key);

  @override
  State<MonthlyPage> createState() => _MonthlypageState();
}

class _MonthlypageState extends State<MonthlyPage> {
  List queryDates = [];
  String queryDateString = '';
  final todaysDate = DateTime.now();
  var _focusedCalendarDate = DateTime.now();
  final _initialCalendarDate = DateTime(2000);
  final _lastCalendarDate = DateTime(2050);
  DateTime? selectedCalendarDate;
  final titleController = TextEditingController();
  final descpController = TextEditingController();

  late Map<DateTime, List<MyEvents>> mySelectedEvents;

  @override
  void initState() {
    selectedCalendarDate = _focusedCalendarDate;
    mySelectedEvents = {};
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Stream toDoList = FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('toDo')
        .where('date', isEqualTo: queryDateString)
        .snapshots();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TableCalendar(
                focusedDay: _focusedCalendarDate,
                // today's date
                firstDay: _initialCalendarDate,
                // earliest possible date
                lastDay: _lastCalendarDate,
                // latest allowed date
                calendarFormat: CalendarFormat.month,
                // default view when displayed
                // default is Saturday & Sunday but can be set to any day.
                // instead of day number can be mentioned as well.
                weekendDays: const [DateTime.sunday, 6],
                // default is Sunday but can be changed according to locale
                startingDayOfWeek: StartingDayOfWeek.sunday,
                // height between the day row and 1st date row, default is 16.0
                daysOfWeekHeight: 40.0,
                // height between the date rows, default is 52.0
                rowHeight: 60.0,
                // this property needs to be added if we want to show events
//              eventLoader: _listOfDayEvents,
                // Calendar Header Styling
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleTextStyle:
                      TextStyle(color: Colors.black, fontSize: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: Colors.black,
                    size: 28,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
                // Calendar Days Styling
                daysOfWeekStyle: const DaysOfWeekStyle(
                  // Weekend days color (Sat,Sun)
                  weekendStyle: TextStyle(color: Colors.cyan),
                ),
                // Calendar Dates styling
                calendarStyle: const CalendarStyle(
                  // Weekend dates color (Sat & Sun Column)
                  weekendTextStyle: TextStyle(color: Colors.cyan),
                  // highlighted color for today
                  todayDecoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  // highlighted color for selected day
                  selectedDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
//                markerDecoration:
//                    BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
                selectedDayPredicate: (currentSelectedDate) {
                  // as per the documentation 'selectedDayPredicate' needs to determine
                  // current selected day
                  return (isSameDay(
                      selectedCalendarDate!, currentSelectedDate));
                },
                onDaySelected: (selectedDay, focusedDay) {
                  // as per the documentation
                  if (!isSameDay(selectedCalendarDate, selectedDay)) {
                    setState(() {
                      selectedCalendarDate = selectedDay;
                      _focusedCalendarDate = focusedDay;
                    });
                    List date = [
                      selectedCalendarDate
                          .toString()
                          .substring(0, 10)
                          .split('-')
                    ];
                    queryDates = [date[0][0], date[0][1], date[0][2]];
                    print(selectedCalendarDate);
                    print(queryDates);
                    queryDateString = queryDates[0] +
                        '년 ' +
                        queryDates[1] +
                        '월 ' +
                        queryDates[2] +
                        '일';
                    print(queryDateString);
                  }
                },
              ),
            ),
            Container(
              width: 280,
              child: StreamBuilder(
                stream: toDoList,
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData) return Text('Please fill your list');

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
                              Text(
                                data['content'],
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
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
          ],
        ),
      ),
    );
  }
}

class MyEvents {
  final String eventTitle;
  final String eventDescp;

  MyEvents({required this.eventTitle, required this.eventDescp});

  @override
  String toString() => eventTitle;
}
