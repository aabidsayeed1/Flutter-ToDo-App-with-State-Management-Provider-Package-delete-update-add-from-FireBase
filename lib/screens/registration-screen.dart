// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todoey_flutter/practice/todo.dart';
import '../models/user-model.dart';
import '../widgets/my-widgets.dart';
import 'login-screen.dart';

class Registration extends StatefulWidget {
  static String id = 'registration';

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final _auth = FirebaseAuth.instance;

  // string for displaying the error Message
  String? errorMessage;

  // our form key
  final _formKey = GlobalKey<FormState>();
  // editing Controller
  final fullNameEditingController = TextEditingController();
  // final secondNameEditingController = TextEditingController();
  final emailEditingController = TextEditingController();
  final passwordEditingController = TextEditingController();
  final confirmPasswordEditingController = TextEditingController();
  // user Credential for keeping user loggedIn
  final storage = FlutterSecureStorage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE5E5E5),
      body: SingleChildScrollView(
        reverse: true,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('images/Shapetop1.png'),
              Column(
                children: [
                  SizedBox(
                    height: 70,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 110),
                    width: 400,
                    child: const Text(
                      'Welcome Onboard!',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 65),
                    width: double.infinity,
                    child: const Text(
                      "Let's help you to meet your Task!",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 41,
                  ),
                  TextFields(
                    hindText: 'Enter Your Full Name',
                    controller: fullNameEditingController,
                    validator: (value) {
                      RegExp regex = RegExp(r'^.{3,}$');
                      if (value!.isEmpty) {
                        return ("Name cannot be Empty");
                      }
                      if (!regex.hasMatch(value)) {
                        return ("Enter Valid name(Min. 3 Character)");
                      }
                      return null;
                    },
                    onsaved: (value) {
                      fullNameEditingController.text = value!;
                    },
                  ),
                  SizedBox(
                    height: 28,
                  ),
                  TextFields(
                    hindText: 'Enter Your Email',
                    controller: emailEditingController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return ("Please Enter Your Email");
                      }
                      // reg expression for email validation
                      if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                          .hasMatch(value)) {
                        return ("Please Enter a valid email");
                      }
                      return null;
                    },
                    onsaved: (value) {
                      emailEditingController.text = value!;
                    },
                  ),
                  SizedBox(
                    height: 28,
                  ),
                  TextFields(
                    hindText: 'Enter Your Password',
                    controller: passwordEditingController,
                    validator: (value) {
                      RegExp regex = RegExp(r'^.{6,}$');
                      if (value!.isEmpty) {
                        return ("Password is required for login");
                      }
                      if (!regex.hasMatch(value)) {
                        return ("Enter Valid Password(Min. 6 Character)");
                      }
                    },
                    onsaved: (value) {
                      passwordEditingController.text = value!;
                    },
                  ),
                  SizedBox(
                    height: 28,
                  ),
                  TextFields(
                    hindText: 'Confirm Your Password',
                    controller: confirmPasswordEditingController,
                    validator: (value) {
                      if (confirmPasswordEditingController.text !=
                          passwordEditingController.text) {
                        return "Password don't match";
                      }
                    },
                    onsaved: (value) {
                      confirmPasswordEditingController.text = value!;
                    },
                  ),
                  SizedBox(
                    height: 67,
                  ),
                  MyButtons(
                    buttonName: 'Register',
                    onPress: () {
                      signUp(emailEditingController.text,
                          passwordEditingController.text);
                    },
                  ),
                  SizedBox(
                    height: 28,
                  ),
                  MyRichText(
                    textleft: 'Already have an Account?',
                    text: ' Sign In',
                    onPress: () {
                      Navigator.pushNamed(context, Login.id);
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void signUp(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: email, password: password);
        await storage
            .write(key: 'uid', value: userCredential.user?.uid)
            .then((value) => {postDetailsToFirestore()})
            .catchError((e) {
          Fluttertoast.showToast(msg: e!.message);
        });
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "invalid-email":
            errorMessage = "Your email address appears to be malformed.";
            break;
          case "wrong-password":
            errorMessage = "Your password is wrong.";
            break;
          case "user-not-found":
            errorMessage = "User with this email doesn't exist.";
            break;
          case "user-disabled":
            errorMessage = "User with this email has been disabled.";
            break;
          case "too-many-requests":
            errorMessage = "Too many requests";
            break;
          case "operation-not-allowed":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          default:
            errorMessage = "An undefined Error happened.";
        }
        Fluttertoast.showToast(msg: errorMessage!);
        print(error.code);
      }
    }
  }

  Future postDetailsToFirestore() async {
    // calling our firestore
    // calling our user model
    // sending these values
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;
    UserModel userModel = UserModel();
    userModel.email = user!.email;
    userModel.uid = user.uid;
    userModel.fullName = fullNameEditingController.text;
    await firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toMap());
    Fluttertoast.showToast(msg: 'Account created sucessfully ');
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => Todo()), (route) => false);
  }
}
