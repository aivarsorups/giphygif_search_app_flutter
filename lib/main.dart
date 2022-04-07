// ignore_for_file: use_key_in_widget_constructors, unused_import

import 'package:flutter/material.dart';
import 'package:enough_giphy/enough_giphy.dart';
import 'gify_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      title: 'flutter app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GifyPage(),
    );
  }
}