import 'package:flutter/material.dart';
import 'package:sipisat/auth/login.dart';
import 'package:sipisat/home_app.dart';

void main() {
  runApp(MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  // const MyApp({Key? key}) : super(key: key);

  String? loginKey;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: loginKey != null ? LoginPage() : HomeApp(),
    );
  }
}
