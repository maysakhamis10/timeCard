import 'package:flutter/material.dart';
import 'package:timecarditg/Screens/SplashScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Time card',
        theme: ThemeData(
          accentColor: Colors.white,
          primaryColor: Color(0xff0099FF),
        ),
        home:  SplashScreen()
    );
  }
}
