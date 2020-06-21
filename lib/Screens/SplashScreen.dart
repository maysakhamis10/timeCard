import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timecarditg/Blocs/InternetConnectionBloc.dart';
import 'package:timecarditg/Blocs/LoginBloc.dart';
import 'package:timecarditg/LoadingWidget.dart';

import 'LoginScreen.dart';

class SplashScreen extends StatelessWidget {
   InternetConnectionBloc _bloc ;
  @override
  Widget build(BuildContext context) {
    _bloc = BlocProvider.of<InternetConnectionBloc>(context);
    _bloc.add(CheckInternetEvent());
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: BlocBuilder<InternetConnectionBloc , BaseResultState>(
        bloc: _bloc,
        builder: (context , state){
          if(state.result==dataResult.Loaded){
            Timer(Duration(seconds: 3), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) {
                  return  BlocProvider<LoginBloc>(
                    create:(_)=> LoginBloc(),
                    child: SignIn(),
                  );
                }),
              );
            });
          }
          else if(state.result==dataResult.Error){
            print('Not Connected');
          }
          return LoadingWidget();
        },

      )
      ,
    );
  }

}


