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
    'time': time.text,
    'content': content.text,
    'priority': priority,
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
              Text("Time: " + data['time']),
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
                    items: const [
                      DropdownMenuItem(
                        child: Text("가장 중요"),
                        value: 1,
                      ),
                      DropdownMenuItem(
                        child: Text("중요"),
                        value: 2,
                      ),
                      DropdownMenuItem(
                        child: Text("일반"),
                        value: 3,
                      )
                    ],
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
                if (data == null) saveToDo(_time, _content, _value);
                updateTodo(data, _time, _content, _value);
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

var today = DateTime.now();
String todayDate = DateFormat('yyyy년 MM월 d일').format(DateTime.now());

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
                                      icon: Icon(Icons.check_box_outline_blank),
                                      onPressed: () => null,
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          showContentDialog(context, data),
                                      child: Text(
                                        data['content'],
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black),
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
            ],
          ),
        ],
      ),
    );
  }
}
