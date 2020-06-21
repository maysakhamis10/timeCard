// shokrn gbt l mac Address w 3ayz a3ml save lih

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timecarditg/Blocs/InternetConnectionBloc.dart';
import 'package:timecarditg/Screens/MainScreen.dart';
import 'package:timecarditg/Screens/SplashScreen.dart';
import 'package:timecarditg/Screens/transactions_screens.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          accentColor: Colors.white,
          primaryColor: Color(0xff0099FF),

        ),
        home: BlocProvider<InternetConnectionBloc>(
          child : SplashScreen(),
          create: (_)=> InternetConnectionBloc(),
        ),
    );
  }
}
