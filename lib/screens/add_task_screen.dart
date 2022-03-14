// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todoey_flutter/models/task_data.dart';

import '../models/task.dart';

final _firestore = FirebaseFirestore.instance;

class AddTaskScreen extends StatefulWidget {
  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  @override
  void initState() {
    todoeyStream();
    super.initState();
  }

  void todoeyStream() async {
    await for (var snapshot in _firestore.collection('Todoey').snapshots()) {
      for (var todo in snapshot.docs) {
        print(todo.data());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String? newTaskTitle;
    TextEditingController textC = TextEditingController();
    return Container(
      color: Color(0xff757575),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Task',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.lightBlueAccent,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: textC,
              onChanged: (value) {
                newTaskTitle = value;
              },
              autofocus: true,
              textAlign: TextAlign.center,
              decoration: InputDecoration(),
            ),
            SizedBox(
              height: 20,
            ),
            MaterialButton(
              color: Colors.lightBlueAccent,
              onPressed: () {
                if (newTaskTitle == null) {
                  print('please enter data');
                } else {
                  Provider.of<TaskData>(context, listen: false)
                      .addTask(newTaskTitle!);
                  // _firestore.collection('Todoey').add({
                  //   'text': newTaskTitle,
                  // });
                  Navigator.pop(context);
                }
              },
              child: Text(
                'Add',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
