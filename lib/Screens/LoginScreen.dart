import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:timecarditg/Blocs/InternetConnectionBloc.dart';
import 'package:timecarditg/Blocs/LoginBloc.dart';
import 'package:timecarditg/Blocs/home_bloc.dart';
import 'package:flutter/services.dart';
import 'package:get_mac/get_mac.dart';
import 'package:timecarditg/models/Employee.dart';
import 'package:timecarditg/models/user.dart';
import 'package:timecarditg/utils/sharedPreference.dart';
import 'package:timecarditg/utils/utils.dart';

import 'MainScreen.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> with SingleTickerProviderStateMixin {
  String _platformVersion = 'Unknown';
  ProgressDialog progressLoading;
  LoginBloc _bloc;

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool switchState = true;
  var mainColor = Color(0xFF1589d2);
  var height, width;

  AnimationController _animationController;
  Animation<Offset> _logoSlideAnimation;
  Animation<double> _logoScaleAnimation;
  Animation<Offset> _formContainerAnimation;

  void _initAnimations(){
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 1000,
      ),
    );
    _logoSlideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset(0, 0),
    ).animate(_animationController);
    _logoScaleAnimation = Tween<double>(
      begin: 2,
      end: 1,
    ).animate(_animationController);
    _formContainerAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset(0, 0),
    ).animate(_animationController);
    _animationController.forward();
  }

  @override
  void initState() {
    super.initState();
    _initAnimations();
    initPlatformState();
    _bloc = BlocProvider.of<LoginBloc>(context);
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    emailTextEditingController.dispose();
    passwordTextEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            SlideTransition(
              position: _logoSlideAnimation,
              child: ScaleTransition(
                scale: _logoScaleAnimation,
                child: buildLogo(),
              ),
            ),
            SlideTransition(
              position: _formContainerAnimation,
              child: Container(
                margin:
                EdgeInsets.only(top: 240, left: 20, right: 20, bottom: 50),
                width: width,
                height: height * 0.6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(1.0, 4.0),
                    ),
                  ],
                ),
                child: buildLoginForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLogo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 60,
        ),
        Center(
          child: Image.asset(
            'assets/images/logo.png',
            height: 100,
            width: 100,
            fit: BoxFit.contain,
          ),
        ),
        Text(
          '  ITG TimeCard',
          style: TextStyle(
              color: mainColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ],
    );
  }

  Widget buildLoginForm() {
    return Container(
      margin: EdgeInsets.all(20.0),
      child: Form(
        key: formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          BlocListener<LoginBloc, BaseResultState>(
            bloc: _bloc,
            listener: (context, state) async {
              if (state.result == dataResult.Loading) {
                showProgressDialog();
              } else if (state.result == dataResult.Loaded) {
                saveKeepMeLoggedIn();
                var employee = (state.model as Employee);
                saveApiKey(employee);
                Timer(Duration(seconds: 3), () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return BlocProvider(
                        child: MainScreen(),
                        create: (_) => HomeInfoBloc(),
                      );
                    }),
                  );
                });
              } else if (state.result == dataResult.Error) {
                if (progressLoading != null) {
                  progressLoading.hide();
                }
                UtilsClass.showMyDialog(
                    content: "Invalid username or password or may "
                        "be your mac Address is not Registered",
                    context: context,
                    type: DialogType.warning,
                    onPressed: dismissLoading);
              }
            },
            child: Container(),
          ),
          buildUserName(),
          SizedBox(
            height: 10,
          ),
          buildPassword(),
          SizedBox(
            height: 10,
          ),
          buildKeepMeLogIn(),
          SizedBox(
            height: 10,
          ),
          buildMacAddress(),
          SizedBox(
            height: 10,
          ),
          buildLogInButton(),
        ]),
      ),
    );
  }

  Widget buildUserName() {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.blue,
          ),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: TextFormField(
          controller: emailTextEditingController,
          textAlign: TextAlign.start,
          style: TextStyle(color: Colors.blue[50]),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.account_circle,
              color: Colors.grey[700],
            ),
            labelText: 'User Name',
            labelStyle: TextStyle(color: Colors.grey[700], letterSpacing: 1.0),
            border: InputBorder.none,
          ),
          validator: (val) {
            return val.length < 4 ? "Enter a Valid username" : null;
          }),
    );
  }

  Widget buildMacAddress() {
    return Container(
        margin: EdgeInsets.only(left: 10.0, right: 10.0),
        child: Align(
          child: Row(
            children: <Widget>[
              Text(
                'Mac Address :',
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.normal),
              ),
              Text(
                _platformVersion,
                style:
                TextStyle(color: mainColor, fontWeight: FontWeight.normal),
              )
            ],
          ),
        ));
  }

  void dismissLoading() async {
    await Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.of(context).pop();
    });
  }

  Widget buildPassword() {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.blue,
          ),
          borderRadius: BorderRadius.all(Radius.circular(30))),
      child: TextFormField(
          controller: passwordTextEditingController,
          textAlign: TextAlign.start,
          obscureText: true,
          style: TextStyle(color: Colors.blue),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.lock,
              color: Colors.blue,
            ),
            labelText: 'Password',
            labelStyle: TextStyle(color: Colors.blue, letterSpacing: 1.0),
            border: InputBorder.none,
          ),
          validator: (val) {
            return val.length < 4 ? "Enter Password 6+ characters" : null;
          }),
    );
  }

  Widget buildKeepMeLogIn() {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Text(
            'Keep me logged in ',
            style:
            TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
          ),
          Spacer(),
          Flexible(
            child: Container(
              alignment: Alignment.centerRight,
              child: Switch(
                value: switchState,
                activeColor: mainColor,
                onChanged: (bool s) {
                  setState(() {
                    switchState = s;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLogInButton() {
    return Expanded(
      child: GestureDetector(
        onTap: () => logInFun(),
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(left: 10, right: 10, top: 20),
          width: width,
          height: height * 0.08,
          decoration: BoxDecoration(
            color: Color(0xff1295df),
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                offset: Offset(0.0, 2.0),
              ),
            ],
          ),
          child: Text(
            'Sign in',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }

  logInFun() async {
    connectStatus checkConnectivity = await UtilsClass.checkConnectivity();
    if (checkConnectivity == connectStatus.connected) {
      String macAddress = await macAddressChecker();
      if (formKey.currentState.validate()) {
        _bloc.add(LoginEvent(
            user: Logginer(
                username: emailTextEditingController.text,
                password: passwordTextEditingController.text,
                macAddress: macAddress)));
      }
    } else {
      UtilsClass.showMyDialog(
          context: context,
          content: 'There is no internet connection',
          type: DialogType.warning);
    }
  }

  saveApiKey(Employee employee) async {
    await SharedPreferencesOperations.saveApiKeyAndId(
        employee.apiKey, employee.employeeId)
        .then((onValue) {
      print('api key and saved ');
    });
  }

  saveKeepMeLoggedIn() async {
    await SharedPreferencesOperations.saveKeepMeLoggedIn(switchState);
  }

  showProgressDialog() async {
    await Future.delayed(const Duration(milliseconds: 100), () {
      progressLoading = ProgressDialog(
        context,
        type: ProgressDialogType.Normal,
        isDismissible: true,
        showLogs: false,
      );
      progressLoading.show();
    });
  }

  Future<String> macAddressChecker() async {
    try {
      await requestPermission();
      String macAddress = await UtilsClass.loadMacAddress();
      if (macAddress == '') {
        return _platformVersion;
      } else {
        print('loaded : $macAddress');
        return macAddress;
      }
    } catch (e) {
      print(e);
      return 'error';
    }
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await GetMac.macAddress;
    } on PlatformException {
      platformVersion = 'Failed to get Device MAC Address.';
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  requestPermission() async {
    var result = await Permission.storage.request();
    if (result.isGranted) {
      print('granted .. ');
    } else {
      print('denied');
    }
  }

//  Widget buildLoginUiWithOldDesign(){
//   return Container(
//      color: Color(0xFFF5F5F5),
//      child: Stack(
//        children: <Widget>[
//          Container(
//              width: width,
//              height: height*0.6,
//              decoration: BoxDecoration(
//                color: Colors.grey[200],
//                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),
//                    bottomRight: Radius.circular(10)),
//                boxShadow: [
//                  BoxShadow(
//                    color: Colors.black26,
//                    blurRadius: 3,
//                    offset: Offset(0.0, 5.0),
//                  ),
//                ],
//              ),
//              child:
//              Column(
//                crossAxisAlignment: CrossAxisAlignment.center,
//                children: <Widget>[
//                  SizedBox(height: 80,),
//                  Center(
//                    child:
//                    Image.asset('assets/images/logo.png',
//                      height: 100,
//                      width: 100,
//                      fit: BoxFit.contain,),
//                  ),
//                  Text('  ITG TimeCard' , style:  TextStyle(
//                      color: mainColor, fontWeight: FontWeight.bold, fontSize: 20),
//                  ),
//                ],
//              )
//          ),
//          Container(
//            margin: EdgeInsets.only(top: 250,left: 20,right: 20,bottom: 50),
//            width: width,
//            height: height*0.54,
//            decoration: BoxDecoration(
//              color: Colors.blue,
//              borderRadius: BorderRadius.circular(20.0),
//              boxShadow: [
//                BoxShadow(
//                  color: Colors.white12,
//                  blurRadius: 10,
//                  offset: Offset(1.0, 4.0),
//                ),
//              ],
//            ),
//            child: ListView(
//              children: <Widget>[
//                buildLoginForm()
//              ],
//            ),
//          ),
//        ],
//      ),
//    )
//  }

}
