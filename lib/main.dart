import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timecarditg/Blocs/LoginBloc.dart';
import 'package:timecarditg/Blocs/home_bloc.dart';
import 'package:timecarditg/Screens/LoginScreen.dart';
import 'package:timecarditg/Screens/MainScreen.dart';
import 'package:timecarditg/utils/sharedPreference.dart';

void main() =>  runApp(/*DevicePreview(
builder: (context) =>*/MyApp())/*)*/;

class MyApp extends StatelessWidget {
  bool keepLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    getKeep().then((onValue) {
      print(onValue);
      keepLoggedIn = onValue ?? false;
    });

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Time card',
        theme: ThemeData(
          accentColor: Colors.white,
          primaryColor: Color(0xff0099FF),
        ),
        home: keepLoggedIn
            ? BlocProvider<HomeInfoBloc>(
                create: (_) => HomeInfoBloc(),
                child: MainScreen(),
              )
            : BlocProvider<LoginBloc>(
                create: (_) => LoginBloc(),
                child: SignIn(),
              ));
  }

  Future<bool> getKeep() async {
    return await SharedPreferencesOperations.getKeepMeLoggedIn();
  }
}
