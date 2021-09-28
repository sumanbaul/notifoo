import 'package:flutter/material.dart';
import 'widgets/NotificationsLog.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NotificationsLog(),
      //  theme: ThemeData(
      //   primarySwatch: Colors.blue,
      // ),
    );
  }
}
