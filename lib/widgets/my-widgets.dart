// ignore_for_file: prefer_const_constructors

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TextFields extends StatelessWidget {
  dynamic validator;
  dynamic onsaved;
  final String? hindText;
  TextEditingController? controller;

  TextFields({this.hindText, this.controller, this.onsaved, this.validator});

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: 20),
      width: 306,
      height: 46,
      margin: EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: TextFormField(
        validator: validator,
        onSaved: onsaved,
        controller: controller,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(left: 20),
          hintText: hindText,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
                color: Color(0xff6AE0D9),
                width: 47.0,
                style: BorderStyle.solid),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.white, width: 1.0),
          ),
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

class MyButtons extends StatelessWidget {
  dynamic onPress;
  final String buttonName;
  MyButtons({
    required this.onPress,
    required this.buttonName,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: 56,
      minWidth: 272,
      padding: EdgeInsets.symmetric(horizontal: 40),
      onPressed: onPress,
      color: Color(0xff50C2C9),
      child: Text(
        buttonName,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class MyRichText extends StatelessWidget {
  dynamic onPress;
  final String text;
  final String textleft;
  MyRichText({
    Key? key,
    required this.onPress,
    required this.text,
    required this.textleft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
          text: textleft,
          style: TextStyle(fontSize: 16, color: Colors.black),
          children: [
            TextSpan(
                text: text,
                style: TextStyle(color: Color(0xff24D0C6)),
                recognizer: TapGestureRecognizer()..onTap = onPress),
          ]),
    );
  }
}
