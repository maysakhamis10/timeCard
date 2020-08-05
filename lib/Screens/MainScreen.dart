import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timecarditg/Blocs/CheckInBloc.dart';
import 'package:timecarditg/Blocs/ClientsBloc.dart';
import 'package:timecarditg/Blocs/InternetConnectionBloc.dart';
import 'package:timecarditg/Blocs/home_bloc.dart';
import 'package:timecarditg/customWidgets/CircleProgress.dart';
import 'package:timecarditg/models/HomeInformation.dart';
import 'package:timecarditg/utils/sharedPreference.dart';
import 'package:timecarditg/utils/utils.dart' ;
import 'AdditionalInfo.dart';
import 'transactions_screens.dart';

class MainScreen extends StatefulWidget {
  static const String routeName = '/home';
  MainScreen();

  @override
  _MainScreenState createState() => _MainScreenState();

}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin  {

  String checkInTime, checkOutTime;
  HomeInfo _homeInfo;
  var height, width;
  HomeInfoBloc homeInfoBloc;
  AnimationController progressController ;
  Animation animation ;
  double percentage ;
//  BuildContext _context ;
//  Future<AssetData> imageFile;
//  SharedPreferences prefs;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _homeInfo = new HomeInfo();
    homeInfoBloc = BlocProvider.of<HomeInfoBloc>(context);
    callHomeInfoService();
    var hours = 3.5;
    percentage = (hours / 9) * 100;
    progressController = AnimationController(vsync: this,duration: Duration(milliseconds: 2000));
    animation = Tween<double>(begin: 0, end: percentage).animate(progressController)
      ..addListener(() {
        setState(() {});
      });

    progressController.forward();

  }

  void callHomeInfoService() async {
    if (await UtilsClass.checkConnectivity() == connectStatus.connected) {
      homeInfoBloc.add(HomeInfoEvent());
    }
    else {
      String fetchHomeStr = await SharedPreferencesOperations.fetchHomeData();
      var homeJson = jsonDecode(fetchHomeStr);
      print('SHARED_PERF ===>>>> $homeJson');
      if (mounted) {
        setState(() {
          _homeInfo = HomeInfo.fromJson(homeJson);
          print('_homeInfo ===>>>> ${_homeInfo.toJson()}');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery
        .of(context)
        .size
        .height;
    width = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
        appBar: AppBar(title: new Center(
          child: Text('TimeCard', textAlign: TextAlign.center,),),
          backgroundColor: Color(0xff1295df),),
        body: BlocBuilder<HomeInfoBloc, BaseResultState>(
            builder: (context, state) {
              if (state.result == dataResult.Loading) {
              //  if (mounted) {
                 // showProgressDialog();
               // }
              }
              else if (state.result == dataResult.Loaded) {
                _homeInfo = state.model;
                print(('object from api => ${_homeInfo.toJson()}'));
//                if (pr != null) {
//                  pr.hide();
//                }
              }
              else if (state.result == dataResult.Error) {
//                if (pr != null) {
//                  pr.hide();
//                }
              }
              return buildHomeUi();
            }
        )
    );
  }

  Widget buildHomeUi() {
    return ListView(
      children: <Widget>[
        Center(
          child: Column(
            children: <Widget>[
              buildUserPic(),
              SizedBox(height: 10,),
              buildUserName(),
              SizedBox(height: 10,),
              buildTextInGridView(
                  title: 'Today Check in', checkType: CheckType.checkIn),
              SizedBox(height: 10,),
              buildTextInGridView(title: 'You Can Check out At ',
                  checkType: CheckType.checkOut),
              SizedBox(height: 10,),
              buildTextInGridView(title: 'Last Check out '),
              SizedBox(height: 10,),
              buildSignIn(),
              SizedBox(height: 10,),
              buildSignOut(),
              SizedBox(height: 10,),
              buildOtherButtons()
            ],
          ),
        ),
      ],
    );
  }

  Widget buildUserPic() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Center(
        child:  CustomPaint(
            foregroundPainter: CircleProgress(animation.value),
            child: Container(
              width: 200,
              height: 200,
              child: Center(
                child: GestureDetector(
//                  onTap: () {
//                    pickImageFromGallery();
//                  },
                  child:CircleAvatar(
    radius: 100,
    backgroundImage: NetworkImage(
    'http://kundenarea.at/app-assets/images/user/12.jpg') ,
                ),),
            ),
          ),
    ),
      ),
    );
  }

//  Widget showImage() {
//    return CircleAvatar(
//            radius: 100,
//            backgroundImage: FileImage(File(prefs.getString('user_profile_image')
//                ?? AssetImage('assets/images/logo.png')),),);
////    return FutureBuilder<AssetData>(
////      future: imageFile,
////      builder: (BuildContext context, AsyncSnapshot<AssetData> snapshot) {
////        if (snapshot.connectionState == ConnectionState.done &&
////            snapshot.data != null) {
////          return Container(
////              width: 200,
////              height: 200,
////              decoration: BoxDecoration(
////                shape: BoxShape.circle,
////                image: DecorationImage(
////                    image: AssetDataImage(snapshot.data,),
////                    fit: BoxFit.fill
////                ),
////              ),);
////        } else if (snapshot.error != null) {
////          return CircleAvatar(
////            radius: 100,
////            backgroundImage: FileImage(File(prefs.getString('user_profile_image')??
////                AssetImage('assets/images/logo.png')
////            ),),
////          );
////        } else {
////          return CircleAvatar(
////                      radius: 100,
////                      backgroundImage: FileImage(File(prefs.getString('user_profile_image')??
////                          AssetImage('assets/images/logo.png')
////        ),),
////                  );
////        }
////      },
////    );
//  }


  Widget buildUserName() {
    return Text('Maysa khamis',
      style: TextStyle(color: Colors.black, fontSize: 25),);
  }

  Widget buildSignIn() {
    return GestureDetector(
      onTap: () => signInOnTap(),
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(left: 15, right: 15),
        width: width * 0.6,
        height: height * .07,
        decoration: BoxDecoration(
          color: Color(0xff1295df),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              offset: Offset(0.0, 2.0),
            ),
          ],
        ),
        child: Text('Check in', style: TextStyle(color: Colors.white),),
      ),
    );
  }

  signInOnTap() {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) =>
            MultiBlocProvider(
              child: AdditionalInfo(checkType: 1,),
              providers: [
                BlocProvider<ClientsBloc>(
                  create: (_) => ClientsBloc(),
                ), BlocProvider(
                  create: (_) => CheckBloc(),
                ),
              ],
            )
    ));
  }

  Widget buildSignOut() {
    return GestureDetector(
      onTap: () => signOutOnTap(),
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(left: 15, right: 15),
        width: width * 0.6,
        height: height * .07,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              offset: Offset(0.0, 2.0),
            ),
          ],
        ),
        child: Text('Check out', style: TextStyle(color: Colors.white),),
      ),
    );
  }

  signOutOnTap() {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) =>
            MultiBlocProvider(
              child: AdditionalInfo(checkType: 0,),
              providers: [
                BlocProvider<ClientsBloc>(
                  create: (_) => ClientsBloc(),
                ), BlocProvider(
                  create: (_) => CheckBloc(),
                ),
              ],
            )
    ));
  }

  Widget buildTextInGridView({String title, CheckType checkType}) {
    return Container(

      ///  margin: EdgeInsets.only(right: 10.0),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(title, style: TextStyle(color: Colors.black54),),
                  Text(fetchTime(checkType) ?? "00.00.00",
                    style: TextStyle(color: Colors.black54),),
                ],
              )
            ],
          ),)

    );
  }

  String fetchTime(CheckType checkType) {
    if (_homeInfo != null) {
      if (checkType == CheckType.checkIn) {
        return _homeInfo.CheckIn;
      }
      else if (checkType == CheckType.checkOut) {
        return _homeInfo.CheckOutAt;
      }
      else {
        if (_homeInfo.LastCheckOutDate != null &&
            _homeInfo.LastCheckOutTime != null) {
          return _homeInfo.LastCheckOutDate + ' ' + _homeInfo.LastCheckOutTime;
        }
      }
    }
    return null;
  }

  Widget buildOtherButtons() {
    return Container(
        margin: EdgeInsets.all(10.0),
          padding: EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center ,
            children: <Widget>[
              GestureDetector(
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 30,
                      backgroundColor:Colors.black26,
                      child: Icon(Icons.date_range,
                        size: 20.0,color: Colors.white,),
                    ),
                    SizedBox(height: 10,),
                    Text('Transactions')],
                ),
                  onTap: () =>
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => TransactionsScreen()))
                //  onTap: print('test'),
              ),
              SizedBox(width: 40,),
              GestureDetector(
                child: Column(
                  children: <Widget>[ CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.black26,
                    child: Icon(Icons.add_to_home_screen,
                      size: 20.0,color: Colors.white,),
                  ),
                    SizedBox(height: 10,),
                    Text('Logout')],
                ),
                  onTap:()=> UtilsClass.logOut(context)
                //  onTap: print('test'),
              ),
            ],
          ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

//  pickImageFromGallery() {
//    ImagePicker.singlePicker(_context, singleCallback: (data) {
//      setState(() async {
//      final String path = await findLocalPath();
//      var  fileName = basename(data.path);
//      prefs = await SharedPreferences.getInstance();
//      prefs.setString('user_profile_image', '$path/$fileName');
//      });
//    });
//  }
//
//  Future<String> findLocalPath() async {
//    final directory = Platform.isAndroid
//        ? await getExternalStorageDirectory()
//        : await getApplicationDocumentsDirectory();
//    return directory.path;
//  }



}

enum CheckType{
  checkIn ,
  checkOut
}
