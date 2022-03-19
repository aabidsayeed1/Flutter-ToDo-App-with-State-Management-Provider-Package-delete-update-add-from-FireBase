// ignore_for_file: prefer_const_constructors
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todoey_flutter/practice/todo.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../widgets/my-widgets.dart';
import 'registration-screen.dart';

class Login extends StatefulWidget {
  static String id = 'login';

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // form key
  final _formKey = GlobalKey<FormState>();
  // editing controller
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  //fireBase
  final _auth = FirebaseAuth.instance;
  //String for displaying the error Message
  String? errorMessage;
  // user Credential for keeping user loggedIn
  final storage = FlutterSecureStorage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE5E5E5),
      body: SingleChildScrollView(
        reverse: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('images/Shapetop1.png'),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 110),
                    width: double.infinity,
                    child: const Text(
                      'Welcome Back!',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(
                    height: 49,
                  ),
                  Container(
                    width: 156,
                    height: 186,
                    margin: EdgeInsets.only(left: 20),
                    child: Image.asset('images/login.png'),
                  ),
                  SizedBox(
                    height: 71,
                  ),
                  TextFields(
                      hindText: 'Enter Your Email',
                      controller: emailC,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return ('Please Enter a valid Email');
                        }
                        // reg expression for email validation
                        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                            .hasMatch(value)) {
                          return ("Please Enter a valid email");
                        }
                        return null;
                      },
                      onsaved: (value) {
                        emailC.text = value!;
                      }),
                  SizedBox(
                    height: 28,
                  ),
                  TextFields(
                    hindText: 'Enter Your Password',
                    controller: passwordC,
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
                      passwordC.text = value;
                    },
                  ),
                  SizedBox(
                    height: 22,
                  ),
                  Text(
                    'Forgot password',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xff24D0C6),
                    ),
                  ),
                  SizedBox(
                    height: 21,
                  ),
                  MyButtons(
                    buttonName: 'Sign In',
                    onPress: () {
                      signIn(emailC.text, passwordC.text);
                    },
                  ),
                  SizedBox(
                    height: 28,
                  ),
                  MyRichText(
                    textleft: "Don't have an Account",
                    text: ' Sign Up',
                    onPress: () {
                      Navigator.pushNamed(context, Registration.id);
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // login function
  void signIn(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        await storage
            .write(key: 'uid', value: userCredential.user?.uid)
            .then((uid) => {
                  Fluttertoast.showToast(
                    msg: "Login Successful",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.SNACKBAR,
                    backgroundColor: Colors.blueGrey,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  ),
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => Todo())),
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
        Fluttertoast.showToast(
          msg: errorMessage!,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        print(error.code);
      }
    }
  }
}
