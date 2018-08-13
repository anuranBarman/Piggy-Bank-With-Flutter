import 'package:flutter/material.dart';
import 'firstscreen.dart';
import 'secondscreen.dart';
void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {

  @override
    State<StatefulWidget> createState() {
      // TODO: implement createState
      return _MyApp();
    }

}
class _MyApp extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: FirstScreen(),
      theme: ThemeData(fontFamily: 'Roboto'),
    );
  }
}










