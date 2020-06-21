import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sweet_alert_dialogs/sweet_alert_dialogs.dart';
import 'package:timecarditg/ApiCalls/apiCalls.dart';
import 'package:timecarditg/Blocs/CheckInBloc.dart';
import 'package:timecarditg/Blocs/ClientsBloc.dart';
import 'package:timecarditg/Blocs/InternetConnectionBloc.dart';
import 'package:timecarditg/Screens/app_drawer.dart';
import 'package:timecarditg/database/database.dart';
import 'package:timecarditg/models/CheckModel.dart';
import 'package:timecarditg/models/Employee.dart';
import 'package:timecarditg/models/HomeInformation.dart';
import 'package:timecarditg/models/checkInResponse.dart';
import 'package:timecarditg/utils/sharedPreference.dart';
import 'package:timecarditg/utils/utils.dart';
import 'dart:io' show Platform;
import 'AdditionalInfo.dart';
class MainScreen extends StatefulWidget {
//  Employee empModel ;
  static const String routeName = '/home';

  MainScreen();

  @override
  _MainScreenState createState() => _MainScreenState();

}


class _MainScreenState extends State<MainScreen> {
  String checkInTime, checkOutTime;
  Employee empModel;
  CheckInBloc _bloc ;
  String location='';
  HomeInfo homeInfo;
  DateTime now;
  static const platform = const MethodChannel('com.myapp/intent');
  String _responseFromNativeCode = 'Waiting for Response...';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getLocation().then((onValue) {
      location = onValue;
    });
    _gpsService();
   _bloc = BlocProvider.of<CheckInBloc>(context);
}
  var height, width;
  @override
  Widget build(BuildContext context) {
     height = MediaQuery.of(context).size.height;
     width = MediaQuery.of(context).size.width;
    getApiKeyAndId();
     ApiCalls.getHomeInformation().then((onValue){
       homeInfo=onValue;
     });
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
                    buildTextInGridView(title:'Today Check in',checkType:CheckType.checkIn),
                    buildTextInGridView(title:'You Can Check out At ',checkType :CheckType.checkOut),
                    buildTextInGridView(title:'Last Check out '),
                    buildTextInGridView(title:'empty'),
                  ],
                ),
              ),
              SizedBox(height: height*.05,),
              GestureDetector(
                onTap:(){
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) =>
                          MultiBlocProvider(
                            child: AdditionalInfo(),
                            providers: [
                              BlocProvider<ClientsBloc>(
                                create: (_) => ClientsBloc(),
                              ), BlocProvider(
                                create: (_) => CheckInBloc(),
                              ),
                            ],

                          )
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
              checkOutListener(),
              GestureDetector(
                onTap: ()async{
                   now = DateTime.now();
                   if(await Utils.checkConnectivity()==connectStatus.connected){
                  _bloc.add(CheckOutEvent(
                      employeeId: empModel.employeeId.toString(),
                      logginMachine: Platform.isAndroid ? 'Android' : "IOS",
                      client: "' '",
                      addressInfo: "' '",
                      location: location,
                      checkOutTime: now.toString(),
                      apiKey: empModel.apiKey.toString()
                  ));
                  await saveChecksToDB(synced: true);
                   }
                   else{
                     await saveChecksToDB(synced: false);
                     Utils.showMyDialog(content: 'There is no internet now , your transactions will saved locally and it will be synced later ',
                         context: context,
                         type: DialogType.warning,
                     );
                   }
                },
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

  Widget buildTextInGridView ({String title,CheckType checkType} ){
    if(title=='empty'){
      return Container(color: Colors.white,);
    }
    else {
      return Container(
          child:
            Container(
              margin: EdgeInsets.only(left : width*.005),
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
                    Text(getTime(checkType)??"00.00.00", style: TextStyle(color: Colors.blue),),
                  ],
                )
              ],
            ),)

      );
    }
  }
String getTime(CheckType checkType){
    if(homeInfo!=null){
      if(checkType==CheckType.checkIn){
        return homeInfo.CheckIn;
      }
    else if(checkType==CheckType.checkOut){
        return homeInfo.CheckOutAt;
      }
      else{
        return homeInfo.LastCheckOutDate + ' '+ homeInfo.LastCheckOutTime;
      }
    }
    else{

    }
}
  Future<String> _getLocation() async {
    Position position = await Utils.getCurrentLocation();
    return position.latitude.toString() + ":" + position.longitude.toString();
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
        _getLocation();

      }
    });
  }

  Future _gpsService() async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      _checkGps();
      return null;
    } else
      _getLocation();
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



  Widget checkOutListener() {
    return BlocListener<CheckInBloc, BaseResultState>(
      listener: (context, state) {
        if (state.result == dataResult.Empty) {

        }
        else if (state.result == dataResult.Loaded) {
          var flag = (state.model as CheckInResponse).flag;
          if (flag == 1) {
            Utils.showMyDialog(context: context,
              content: 'Checked out successfully .',
              type: DialogType.confirmation,
            );
          }
          else {
            Utils.showMyDialog(context: context,
              content: 'something went wrong , please check out again .',
              type: DialogType.warning,
            );
          }
        }
      },
      child: Container(),
    );
  }

  getApiKeyAndId() async {
    empModel = await SharedPreferencesOperations.getApiKeyAndId();
  }
  saveChecksToDB({bool synced}){
    var  nowDate = now.year.toString() + '/'+now.month.toString() + '/'+now.day.toString();
    var nowTime= now.hour.toString() + ':'+now.minute.toString() + ':'+now.second.toString();
    DbOperations _operations = DbOperations();
    _operations.openMyDatabase().then((onValue){
      _operations.insertTransaction(CheckModel(
          apiKey: empModel.apiKey,
          addressInfo: " ' ' ",
          location: location ,
          client: " ' ' ",
          logginMachine:Platform.isAndroid ? 'Android' : 'IOS' ,
          date:nowDate  ,
          time: nowTime,
          checkType: 2,
          sync: synced ?1 :0,
          isOnline: synced? 1:0,
          employeeId: empModel.employeeId.toString()
      ));
    });
  }
}
enum CheckType{
  checkIn ,
  checkOut
}
