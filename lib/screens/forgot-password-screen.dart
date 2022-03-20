// ignore_for_file: prefer_const_constructors
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todoey_flutter/screens/login-screen.dart';
import '../widgets/my-widgets.dart';

class ForgotPassword extends StatefulWidget {
  static String id = 'forgot';

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  // form key
  final _formKey = GlobalKey<FormState>();
  // editing controller
  final emailC = TextEditingController();
  //fireBase
  final _auth = FirebaseAuth.instance;
  //String for displaying the error Message
  String? errorMessage;
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
                      'Forgot password!',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(
                    height: 80,
                  ),
                  Container(
                    width: 200,
                    height: 200,
                    margin: EdgeInsets.only(right: 15),
                    child: Image.asset('images/reset.png'),
                  ),
                  SizedBox(
                    height: 80,
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
                    height: 30,
                  ),
                  MyButtons(
                    buttonName: 'Reset',
                    onPress: () {
                      resetPassword(emailC.text);
                    },
                  ),
                  SizedBox(
                    height: 35,
                  ),
                  MyRichText(
                    textleft: "Go back to ",
                    text: ' Sign In',
                    onPress: () {
                      Navigator.pushNamed(context, Login.id);
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

  // resetPassword function
  void resetPassword(String email) async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.sendPasswordResetEmail(email: email).then((uid) => {
              Fluttertoast.showToast(
                msg: "reset password link send to your $email",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.SNACKBAR,
                backgroundColor: Colors.blueGrey,
                textColor: Colors.white,
                fontSize: 16.0,
              ),
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
