import 'package:backgroundlocator/test_nav.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BackgroundLocationTest',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BackgroundLocationTest(),
    );
  }
}
