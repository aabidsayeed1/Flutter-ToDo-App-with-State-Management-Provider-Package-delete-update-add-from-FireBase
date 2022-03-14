// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;

class Todo extends StatefulWidget {
  @override
  State<Todo> createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  List todos = [];
  String title = '';
  String description = '';
  createToDo() {
    DocumentReference documentReference =
        _firestore.collection('MyTodos').doc();
    Map<String, String> todoList = {
      'todoTitle': title,
      'todoDesc': description,
    };
    documentReference
        .set(todoList)
        .whenComplete(() => print('Data stored sucessfully'));
  }

  deleteTodo(selectedItem) {
    DocumentReference documentReference =
        _firestore.collection('MyTodos').doc(selectedItem);
    documentReference.delete().whenComplete(() => print('deleted sucessfully'));
  }

  updateTodo(selectedItem) {
    DocumentReference documentReference =
        _firestore.collection('MyTodos').doc(selectedItem);
    Map<String, String> todoList = {
      'todoTitle': title,
      'todoDesc': description,
    };
    documentReference
        .update(todoList)
        .whenComplete(() => print('Data updated sucessfully'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todo')),
      body: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('MyTodos').snapshots(),
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
                                    title: Text('Add Todo'),
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
                                        child: Text('Update'),
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
                        child: Icon(Icons.archive_sharp),
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
                        elevation: 5,
                        child: ListTile(
                          title: Text((documentSnapshot != null)
                              ? (documentSnapshot['todoTitle'])
                              : ''),
                          subtitle: Text((documentSnapshot != null)
                              ? ((documentSnapshot['todoDesc'] != null)
                                  ? documentSnapshot['todoDesc']
                                  : '')
                              : ''),
                          leading: IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Add Todo'),
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
                                          child: Text('Update'),
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
                          trailing: IconButton(
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
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Add Todo'),
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
                    child: Text('Add'),
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
