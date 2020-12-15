import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timecarditg/Blocs/LoginBloc.dart';
import 'package:timecarditg/Blocs/home_bloc.dart';
import 'package:timecarditg/Screens/LoginScreen.dart';
import 'package:timecarditg/Screens/MainScreen.dart';
import 'package:timecarditg/utils/sharedPreference.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  return runApp(/*DevicePreview(
builder: (context) =>*/
      MyApp()); /*)*/

}

class MyApp extends StatelessWidget {
  bool keepLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    // getKeep().then((onValue) {
    //   print(onValue);
    //   keepLoggedIn = onValue ?? false;
    //   print(keepLoggedIn.toString());
    // });

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Time card',
        theme: ThemeData(
          accentColor: Colors.white,
          primaryColor: Color(0xff0099FF),
        ),
        home: FutureBuilder(
          future: getKeep(),
          builder: (context, AsyncSnapshot snap) =>
          snap.data ?? false ? FutureBuilder(
            future:getHomeData(),
            builder: (context, AsyncSnapshot snap) =>
            snap.hasData ?? false ? MultiBlocProvider(
              providers:[
                BlocProvider<HomeInfoBloc>(
                  create: (_) => HomeInfoBloc(),
                ),
                BlocProvider<LoginBloc>(
                  create: (_) => LoginBloc(),
                ),
              ] ,
              child: MainScreen(),

            ) :
            BlocProvider<LoginBloc>(
              create: (_) => LoginBloc(),
              child: SignIn(),
            ),
          ) : BlocProvider<LoginBloc>(
            create: (_) => LoginBloc(),
            child: SignIn(),
          ),
        )
    );
  }

  Future<bool> getKeep() async {
    if (await SharedPreferencesOperations.getKeepMeLoggedIn() == null) {
      return false;
    } else {
      return await SharedPreferencesOperations.getKeepMeLoggedIn();
    }
  }


}
  Future<String> getHomeData() async{
  String savedHomeInfo =  await SharedPreferencesOperations.fetchHomeData() ?? null;
  return savedHomeInfo;
}