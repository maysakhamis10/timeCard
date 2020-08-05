import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timecarditg/Blocs/CheckInBloc.dart';
import 'package:timecarditg/Blocs/LoginBloc.dart';
import 'package:timecarditg/Blocs/home_bloc.dart';
import 'package:timecarditg/customWidgets/LoadingWidget.dart';
import 'package:timecarditg/Screens/MainScreen.dart';
import 'package:timecarditg/utils/sharedPreference.dart';

import 'LoginScreen.dart';

class SplashScreen extends StatelessWidget {
  bool keepLoggedIn = false;
  @override
  Widget build(BuildContext context) {

    getKeep().then((onValue){
      print(onValue);
      keepLoggedIn=onValue??false;
    });

  _count(context);
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .primaryColor,
      body: Container(
        child: LoadingWidget(),
      ),
    );
  }

  _count(context){
  Timer(Duration(seconds: 3), () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) {
        return keepLoggedIn ? BlocProvider<HomeInfoBloc>(
          create: (_) => HomeInfoBloc(),
          child: MainScreen(),
        ) :
        BlocProvider<LoginBloc>(
          create: (_) => LoginBloc(),
          child: SignIn(),
        );
      }),
    );
  });
}

  Future<bool>  getKeep() async{
    return  await SharedPreferencesOperations.getKeepMeLoggedIn();
  }

}

