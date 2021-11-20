import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

User user = FirebaseAuth.instance.currentUser!;
CollectionReference toDo = FirebaseFirestore.instance
    .collection('user')
    .doc(user.uid)
    .collection('toDo');
var today = DateTime.now();
String todayDate = DateFormat('yyyy년 MM월 d일').format(DateTime.now());

Future<void> deleteToDo(data) {
  return toDo.doc(data.id).delete().then(
    (value) {
      print('Data Deleted');
    },
  );
}

Future<void> saveToDo(
    TextEditingController time, TextEditingController content, int priority) {
  return toDo.doc().set({
    'date': todayDate,
    'time': time.text,
    'content': content.text,
    'priority': priority,
    'status': "Incomplete",
  }).then((value) => print("Data Added"));
}

Future<void> updateTodo(data, TextEditingController time,
    TextEditingController content, int priority) {
  return toDo.doc(data.id).update({
    'time': time.text,
    'content': content.text,
    'priority': priority,
  }).then((value) => print("Data Updated"));
}

// List<Map<String, Object>> status_todo = [
//   {"status": "Incomplete", "icon": const Icon(Icons.crop_square_outlined)},
// ];

Future<void> updateStatus(data, String text, context) {
  return toDo.doc(data.id).update({
    'status': text,
  }).then((value) {
    print("Status Updated");
    Navigator.pop(context);
  });
}

void showStatus(context, data) {
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ButtonBar(
                children: [
                  TextButton(
                    onPressed: () => updateStatus(data, 'Complete', context),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_box,
                        ),
                        SizedBox(width: 10),
                        Text('Complete'),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => updateStatus(data, 'In Progress', context),
                    child: Row(
                      children: [
                        Icon(Icons.star_half),
                        SizedBox(width: 10),
                        Text('In Progress'),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => updateStatus(data, 'Postponed', context),
                    child: Row(
                      children: [
                        Icon(Icons.forward),
                        SizedBox(width: 10),
                        Text('Postponed'),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => updateStatus(data, 'Cancel', context),
                    child: Row(
                      children: [
                        Icon(Icons.cancel_presentation_outlined),
                        SizedBox(width: 10),
                        Text('Cancel'),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => updateStatus(data, 'Incomplete', context),
                    child: Row(
                      children: [
                        Icon(Icons.check_box_outline_blank),
                        SizedBox(width: 10),
                        Text('Incomplete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      });
}

void showContentDialog(context, data) {
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text("To Do")),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Date: " + data['date']),
              SizedBox(height: 10),
              Text("Time: " + data['time']),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Priority: "),
                  if (data['priority'] == 1)
                    Icon(Icons.circle, color: Colors.red),
                  if (data['priority'] == 2)
                    Icon(Icons.circle, color: Colors.blue),
                  if (data['priority'] == 3)
                    Icon(Icons.circle, color: Colors.green),
                ],
              ),
              SizedBox(height: 10),
              Text("Content: " + data['content']),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: new Text("삭제"),
              onPressed: () {
                deleteToDo(data);
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: new Text("수정"),
              onPressed: () {
                Navigator.pop(context);
                addContentDialog(context, data);
              },
            ),
          ],
        );
      });
}

TextEditingController _time = TextEditingController();
TextEditingController _content = TextEditingController();
int _value = 1;

void addContentDialog(context, data) {
  if (data != null) {
    _content = TextEditingController(text: data['content']);
    _time = TextEditingController(text: data['time']);
    _value = data['priority'];
  }
  myProvider provider = myProvider();

  final List<int> listItems = <int>[1, 2, 3];
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text("To Do")),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    child: const Text("Time: "),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _time,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Priority: "),
                  DropdownButton(
                    value: _value,
                    items: listItems.map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text("$value 순위"),
                      );
                    }).toList(),
                    onChanged: (value) {
                      provider.setPriority(value);
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Content: "),
                  Expanded(
                    child: TextField(
                      maxLines: null,
                      controller: _content,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: new Text("취소"),
              onPressed: () {
                _time.clear();
                _content.clear();

                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: new Text("저장"),
              onPressed: () {
                if (data == null) {
                  saveToDo(_time, _content, _value);
                } else {
                  updateTodo(data, _time, _content, _value);
                }
                _time.clear();
                _content.clear();
                Navigator.pop(context);
              },
            ),
          ],
        );
      });
}

class myProvider with ChangeNotifier {
  void setPriority(value) {
    print(value);
    _value = value as int;
    notifyListeners();
  }
}

Icon selectIcon(data) {
  if (data['status'] == "Complete") return Icon(Icons.check_box);
  if (data['status'] == "In Progress") return Icon(Icons.star_half);
  if (data['status'] == "Postponed") return Icon(Icons.forward);
  if (data['status'] == "Cancel")
    return Icon(Icons.cancel_presentation_outlined);

  return Icon(Icons.check_box_outline_blank);
}

class ToDoPage extends StatefulWidget {
  const ToDoPage({Key? key}) : super(key: key);

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  Stream toDoList = FirebaseFirestore.instance
      .collection('user')
      .doc(user.uid)
      .collection('toDo')
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 10),
              child: IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: () {},
                iconSize: 40,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 150, 0, 0),
                child: Text(
                  todayDate,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
              Center(
                child: Container(
                  width: 280,
                  margin: EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: Flexible(
                    child: Column(
                      children: [
                        StreamBuilder(
                            stream: toDoList,
                            builder: (BuildContext context,
                                AsyncSnapshot<dynamic> snapshot) {
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                              if (!snapshot.hasData)
                                return Text('Please fill your list');

                              return ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: snapshot.data.docs.length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot data =
                                      snapshot.data.docs[index];

                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      IconButton(
                                        icon: selectIcon(data),
                                        onPressed: () =>
                                            showStatus(context, data),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            showContentDialog(context, data),
                                        child: Text(
                                          data['content'],
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }),
                        IconButton(
                            onPressed: () => addContentDialog(context, null),
                            icon: Icon(Icons.add))
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
