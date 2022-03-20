// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:todoey_flutter/models/user-model.dart';

import '../screens/login-screen.dart';

final _firestore = FirebaseFirestore.instance;

class Todo extends StatefulWidget {
  @override
  State<Todo> createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((value) {
      this.loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  List todos = [];
  String title = '';
  String description = '';
  createToDo() {
    DocumentReference documentReference = _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('MyTodos')
        .doc();
    Map<String, dynamic> todoList = {
      'todoTitle': title,
      'todoDesc': description,
      'time': FieldValue.serverTimestamp(),
      'isDone': false
    };
    documentReference
        .set(todoList)
        .whenComplete(() => print('Data stored sucessfully'));
  }

  deleteTodo(selectedItem) {
    DocumentReference documentReference = _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('MyTodos')
        .doc(selectedItem);
    documentReference.delete().whenComplete(() => print('deleted sucessfully'));
  }

  // update task data
  updateTodo(selectedItem) {
    DocumentReference documentReference = _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('MyTodos')
        .doc(selectedItem);
    Map<String, dynamic> todoList = {
      'todoTitle': title,
      'todoDesc': description,
    };
    documentReference
        .update(todoList)
        .whenComplete(() => print('Data updated sucessfully'));
  }

  //update checkBox
  bool isChecked = false;
  updateCheckBox(selectedItem) {
    DocumentReference documentReference = _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('MyTodos')
        .doc(selectedItem);
    Map<String, dynamic> todoList = {
      'isDone': isChecked,
    };
    documentReference
        .update(todoList)
        .whenComplete(() => print('Data updated sucessfully'));
  }

  // for logout and deleting uid of current user
  final storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE5E5E5),
      appBar: AppBar(
          backgroundColor: Color(0xff24D0C6),
          shadowColor: Color(0xff50C2C9),
          elevation: 7,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('${loggedInUser.fullName}'),
              ElevatedButton(
                  style: ButtonStyle(),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    await storage.delete(key: "uid");
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Login(),
                        ),
                        (route) => false);
                  },
                  child: Icon(
                    Icons.settings_power_rounded,
                  ))
            ],
          )),
      body: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('users')
              .doc(user!.uid)
              .collection('MyTodos')
              .orderBy('time', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('something went wrong');
            } else if (snapshot.hasData || snapshot.data != null) {
              return ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (BuildContext context, index) {
                    QueryDocumentSnapshot? documentSnapshot =
                        snapshot.data?.docs[index];
                    return Dismissible(
                      // direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        setState(() {
                          title = documentSnapshot?['todoTitle'];
                          description = documentSnapshot?['todoDesc'];
                          switch (direction) {
                            case DismissDirection.endToStart:
                              deleteTodo((documentSnapshot != null)
                                  ? (snapshot.data?.docs[index].id)
                                  : '');
                              break;
                            case DismissDirection.startToEnd:
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Color(0xff24D0C6),
                                    title: Text(
                                      'Update Task',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                      ),
                                    ),
                                    content: Container(
                                      width: 40,
                                      height: 100,
                                      child: Column(children: [
                                        TextField(
                                          onChanged: (value) {
                                            title = value;
                                          },
                                        ),
                                        TextField(
                                          onChanged: (value) {
                                            description = value;
                                          },
                                        ),
                                      ]),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            updateTodo(
                                                (documentSnapshot != null)
                                                    ? (snapshot
                                                        .data?.docs[index].id)
                                                    : '');
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Update',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );

                              break;
                          }
                        });
                      },
                      key: UniqueKey(),
                      // Key(index.toString()),
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.green,
                        child: Icon(Icons.edit),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.red,
                        child: Icon(
                          Icons.cancel_presentation_sharp,
                          color: Colors.white,
                        ),
                      ),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        shadowColor: Color(0xff24D0C6),
                        elevation: 5,
                        child: ListTile(
                          title: Text(
                            (documentSnapshot != null)
                                ? (documentSnapshot['todoTitle'])
                                : '',
                            style: TextStyle(
                                decoration: documentSnapshot?['isDone']
                                    ? TextDecoration.lineThrough
                                    : null),
                          ),
                          subtitle: Text(
                            (documentSnapshot != null)
                                ? ((documentSnapshot['todoDesc'] != null)
                                    ? documentSnapshot['todoDesc']
                                    : '')
                                : '',
                            style: TextStyle(
                              decoration: documentSnapshot?['isDone']
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          leading: IconButton(
                              onPressed: () {
                                title = documentSnapshot?['todoTitle'];
                                description = documentSnapshot?['todoDesc'];
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Color(0xff24D0C6),
                                      title: Text(
                                        'Update Task',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 30,
                                        ),
                                      ),
                                      content: Container(
                                        width: 40,
                                        height: 100,
                                        child: Column(children: [
                                          TextField(
                                            onChanged: (value) {
                                              title = value;
                                            },
                                          ),
                                          TextField(
                                            onChanged: (value) {
                                              description = value;
                                            },
                                          ),
                                        ]),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              updateTodo(
                                                  (documentSnapshot != null)
                                                      ? (snapshot
                                                          .data?.docs[index].id)
                                                      : '');
                                            });

                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'Update',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Colors.grey,
                              )),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                activeColor: Color(0xff24D0C6),
                                value: documentSnapshot?['isDone'],
                                onChanged: (documentSnapshot) {
                                  setState(() {
                                    isChecked = !isChecked;
                                    updateCheckBox((documentSnapshot != null)
                                        ? (snapshot.data?.docs[index].id)
                                        : '');
                                  });
                                },
                              ),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      deleteTodo((documentSnapshot != null)
                                          ? (snapshot.data?.docs[index].id)
                                          : '');
                                    });
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            }
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff50C2C9),
        onPressed: () {
          title = '';
          description = '';
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Add Todo',
                  style: TextStyle(
                    fontSize: 30,
                    color: Color(0xff24D0C6),
                  ),
                ),
                content: Container(
                  width: 40,
                  height: 100,
                  child: Column(children: [
                    TextField(
                      onChanged: (value) {
                        title = value;
                      },
                    ),
                    TextField(
                      onChanged: (value) {
                        description = value;
                      },
                    ),
                  ]),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        createToDo();
                      });
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xff24D0C6),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
