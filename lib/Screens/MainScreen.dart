import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sweet_alert_dialogs/sweet_alert_dialogs.dart';
import 'package:timecarditg/Blocs/CheckInBloc.dart';
import 'package:timecarditg/Screens/app_drawer.dart';
import 'package:timecarditg/models/Employee.dart';
import 'dart:io' show Platform;

import '../Constants.dart';


class MainScreen extends StatefulWidget {

//  Employee empModel ;

  static const String routeName = '/home';

  MainScreen();

  @override
  _MainScreenState createState() => _MainScreenState();

}


class _MainScreenState extends State<MainScreen> {

  CheckInBloc _bloc ;
  Position _currentPosition;
  static const platform = const MethodChannel('com.myapp/intent');
  String _responseFromNativeCode = 'Waiting for Response...';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getCurrentLocation();

    _gpsService();

   _bloc = BlocProvider.of<CheckInBloc>(context);

}

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar:
      AppBar(title: new Center(child: Text('Information'),),
        backgroundColor: Color(0xff1295df),),
      body: buildBodyView(height,width),
      drawer: AppDrawer()
    );
  }

  Widget buildBodyView( var height ,   var width){
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xff1295df),
                    Colors.white
                  ]
              )
          ),
          child:  Column(
            children: <Widget>[
              Container(
                color: Colors.white,
                height: height*.4,
                child: GridView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: false,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 0.0,
                      mainAxisSpacing: 0.0,
                      childAspectRatio: 2
                  ),
                  children: <Widget>[
                    buildTextInGridView('Today Check in'),
                    buildTextInGridView('You Can Check out At '),
                    buildTextInGridView('Last Check out '),
                    buildTextInGridView('empty'),
                  ],
                ),
              ),

              SizedBox(height: height*.05,),
              GestureDetector(
                onTap:(){
                  DateTime now = DateTime.now();
                  print(now);
                  _bloc.add(CheckInEvent(
                      employeeId: Constants.employeeId,
                      apiKey: Constants.apiKey,
                      logginMachine: Platform.isAndroid ? "Android" : "iPhone",
                      location: '30.0875198:31.3305295',
                      checkInTime: now.toString(),
                      addressInfo: '',
                      client:''
                  ));
                },
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 15, right: 15),
                  width: width,
                  height: height * .08,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Text('Check in'),
                ),
              ),
              SizedBox(height: height*.01,),
              GestureDetector(
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 15, right: 15),
                  width: width,
                  height: height * .08,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [
                            Color(0xff1295df),
                            Color(0xff0d88cd)
                          ]
                      )
                  ),
                  child: Text('Check out', style: TextStyle(
                      color: Colors.white
                  ),),
                ),
              ),

            ],
          ) ,
        ),
      ],
    );
  }

  Widget buildTextInGridView (String title){
    if(title=='empty'){
      return Container(color: Colors.white,);
    }
    else {
      return Container(
        child:
          Container(
            margin: EdgeInsets.all(10.0),
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
              IconButton(
                icon: new Image.asset('assets/images/clock_blue.png'),
                onPressed: ()=> print('okay'),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(title, style: TextStyle(color: Colors.black54),),
                  Text('00.00.00', style: TextStyle(color: Colors.blue),),
                ],
              )
            ],
          ),)
      );
    }
  }

//  Widget buildDrawerMenu(){
//  return  Drawer(
//      child: ListView(
//        padding: EdgeInsets.zero,
//        children: <Widget>[
//          DrawerHeader(
//            child: Container(
//              child:Image.asset("assets/images/logo.png",),),
//          ),
//          ListTile(
//            title: Text('Home'),
//            onTap: () {
//              Navigator.pop(context);
//              Navigator.pushReplacementNamed(
//                context, Constants.HomePage ,
//              );
//            },
//          ),
//          ListTile(
//            title: Text('Transactions'),
//            onTap: () {
//              Navigator.pop(context);
//              Navigator.pushReplacementNamed(
//                context, Constants.TRANSACTIONS ,);
//              },
//          ),
//          ListTile(
//            title: Text('Logout'),
//            onTap: () {
//              Navigator.pop(context);
//            },
//          ),
//        ],
//      ),
//    );
//  }

  _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        print('Current location ==> latitude  ===> ${_currentPosition.latitude}  and'
            '    longitude ==>  ${_currentPosition.longitude}');

      });
    }).catchError((e) {
      print(e);
    });
  }


  Future<void> responseFromNativeCode() async {
    String response = "";
    try {
      final String result = await platform.invokeMethod('settings');
      response = result;
    } on PlatformException catch (e) {
      response = "Failed to Invoke: '${e.message}'.";
    }
    setState(() {
      _responseFromNativeCode = response;
      print('response is ==> $_responseFromNativeCode');
      if(_responseFromNativeCode=="ENABLED"){
        _getCurrentLocation();

      }
    });
  }

  Future _gpsService() async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      _checkGps();
      return null;
    } else
      _getCurrentLocation();
    return true;
  }

  Future _checkGps() async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return RichAlertDialog(
                alertTitle: richTitle("Can't get current location"),
                alertSubtitle: richSubtitle("Please make sure you enable GPS"),
                alertType: RichAlertType.INFO,
                actions: <Widget>[
                  FlatButton(
                    textColor: Colors.black,
                    child: Text("OK"),
                    onPressed: (){
                      responseFromNativeCode();
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            });
      }
    }
  }



}
