import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:timecarditg/Blocs/InternetConnectionBloc.dart';
import 'package:timecarditg/Blocs/LoginBloc.dart';
import 'package:timecarditg/Blocs/home_bloc.dart';
import 'package:flutter/services.dart';
import 'package:get_mac/get_mac.dart';
import 'package:device_info/device_info.dart';
import 'package:timecarditg/main.dart';
import 'package:timecarditg/models/Employee.dart';
import 'package:timecarditg/models/login_error.dart';
import 'package:timecarditg/models/user.dart';
import 'package:timecarditg/utils/sharedPreference.dart';
import 'package:timecarditg/utils/utils.dart';
import 'package:unique_identifier/unique_identifier.dart';

import 'MainScreen.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> with SingleTickerProviderStateMixin {
  String _address = "unkown";
  String _platformImei = 'Unknown';
  String uniqueId = "Unknown";
  ProgressDialog progressLoading;
  LoginBloc _bloc;

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool switchState ;
  var mainColor = Color(0xFF1589d2);
  var height, width;

  AnimationController _animationController;
  Animation<Offset> _logoSlideAnimation;
  Animation<double> _logoScaleAnimation;
  Animation<Offset> _formContainerAnimation;

  void _initAnimations() {
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
    getKeep();
    // getHomeData().then((onValue) {
      // if( onValue == null || onValue.isEmpty) {
        initPlatformState();
      // }
    // });
    _bloc = BlocProvider.of<LoginBloc>(context);
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailTextEditingController.dispose();
    passwordTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          width: width,
          height: height,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: SlideTransition(
                  position: _logoSlideAnimation,
                  child: ScaleTransition(
                    scale: _logoScaleAnimation,
                    child: buildLogo(),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: SlideTransition(
                      position: _formContainerAnimation,
                      child: Container(
                        margin:
                            EdgeInsets.only(left: 20, right: 20, bottom: 50),
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLogo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
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
          style: GoogleFonts.voces(
            color: mainColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
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
                var employee = (state.model as Employee);
                saveApiKey(employee);
                saveUsernameAndPassword();
                saveMac();
                Timer(Duration(seconds: 3), () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return MultiBlocProvider(
                        providers:[
                          BlocProvider(
                            child: MainScreen(),
                            create: (_) => HomeInfoBloc(),
                          ),BlocProvider(
                            create: (_) => LoginBloc(),
                          ),
                        ],
                        child: MainScreen(),
                      );
                    }),
                  );
                });
              } else if (state.result == dataResult.Error) {
                await Future.delayed(const Duration(seconds: 1),() {
                  if (progressLoading != null) {
                    progressLoading.hide();
                  }
                });
                if(state.model == null ){
                  scaffoldKey.currentState.showBottomSheet((widgetBuilder) {
                    return Container(
                      height: 50,
                      width: double.infinity,
                      color: Colors.blue,
                      child: Center(
                          child: Text(
                            "There is error in server please try later",
                            style: GoogleFonts.voces(
                                color: Colors.white, fontSize: 12.0),
                          )),
                    );
                  }, backgroundColor: Colors.blue);
                }else {
                  var error = (state.model as LoginError);
                  if (error != null) {
                    scaffoldKey.currentState.showBottomSheet((widgetBuilder) {
                      return Container(
                        height: 50,
                        width: double.infinity,
                        color: Colors.blue,
                        child: Center(
                            child: Text(
                              error.message,
                              style: GoogleFonts.voces(
                                  color: Colors.white, fontSize: 12.0),
                            )),
                      );
                    }, backgroundColor: Colors.blue);
                  }
                }
              }
            },
            child: Container(),
          ),
          buildUserName(),
          // SizedBox(
          //   height: 10,
          // ),
          buildPassword(),
          // SizedBox(
          //   height: 10,
          // ),
          buildKeepMeLogIn(),
          // SizedBox(
          //   height: 10,
          // ),
          buildMacAddress(),
          // SizedBox(
          //   height: 10,
          // ),
          buildLogInButton(),
        ]),
      ),
    );
  }

  Widget buildUserName() {
    return Expanded(
      flex: 3,
      child: Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.blue[300],
            ),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: TextFormField(
          controller: emailTextEditingController,
          textInputAction: TextInputAction.next,
          textAlign: TextAlign.start,
          style: TextStyle(color: Colors.blue, fontSize: 15.0),
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
          },
          focusNode: _nameFocus,
          onFieldSubmitted: (term) {
            _fieldFocusChange(context, _nameFocus, _passwordFocus);
          },
        ),
      ),
    );
  }

  Widget buildMacAddress() {
    return Expanded(
      flex: 1,
      child: Container(
          margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
          child: Align(
            child: Row(
              children: <Widget>[
                Text(
                  'Mac Address : ',
                  style: GoogleFonts.voces(
                      color: Colors.black87,
                      fontWeight: FontWeight.normal,
                      fontSize: 13.0),
                ),
                Expanded(
                  child: GestureDetector(
                    onLongPress: () {
                      Clipboard.setData(new ClipboardData(text: _platformImei));
                      scaffoldKey.currentState.showSnackBar(new SnackBar(
                        content: new Text("$_platformImei Copied to Clipboard"),
                      ));
                    },
                    child:  Text(
                        _platformImei,
                        style: GoogleFonts.voces(
                            color: mainColor,
                            fontWeight: FontWeight.normal,
                            fontSize: 13.0),

                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }

  void dismissLoading() async {
    await Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.of(context).pop();
    });
  }

  Widget buildPassword() {
    return Expanded(
      flex: 3,
      child: Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.blue[300],
            ),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: TextFormField(
          controller: passwordTextEditingController,
          textInputAction: TextInputAction.done,
          textAlign: TextAlign.start,
          obscureText: true,
          style: TextStyle(color: Colors.blue, fontSize: 15.0),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.lock,
              color: Colors.grey[700],
            ),
            labelText: 'Password',
            labelStyle: TextStyle(color: Colors.grey[700], letterSpacing: 1.0),
            border: InputBorder.none,
          ),
          validator: (val) {
            return val.length < 4 ? "Enter Password 6+ characters" : null;
          },
          focusNode: _passwordFocus,
          onFieldSubmitted: (term) {
            _passwordFocus.unfocus();
          },
        ),
      ),
    );
  }

  Widget buildKeepMeLogIn() {
    return Expanded(
      flex: 2,
      child: Container(
        margin: EdgeInsetsDirectional.only(start: 10.0, end: 10.0, top: 10.0),
        child: Row(
          children: <Widget>[
            Text(
              'Keep me logged in ',
              style: GoogleFonts.voces(
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                  fontSize: 13.0),
            ),
            Spacer(),
            Flexible(
              child: Container(
                alignment: Alignment.centerRight,
                child: Switch(
                  value: switchState ?? false,
                  activeColor: mainColor,
                  onChanged: (bool s) {
                    if(mounted) {
                      setState(() {
                        switchState = s;
                        saveKeepMeLoggedIn();
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLogInButton() {
    return Expanded(
      flex: 3,
      child: GestureDetector(
        onTap: () => logInFun(),
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: height/15),
          decoration: BoxDecoration(
            color: Color(0xff1295df),
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 7,
                offset: Offset(0, 3), //
              ),
            ],
          ),
          child: Text(
            'Sign in',
            style: GoogleFonts.voces(color: Colors.white, fontSize: 16.0),
          ),
        ),
      ),
    );
  }

  logInFun() async {
    connectStatus checkConnectivity = await UtilsClass.checkConnectivity();
    if (checkConnectivity == connectStatus.connected) {
      // String macAddress = await macAddressChecker();
      //to test for developers
      //String _platformImei = "00:00:00:00:00:00";
      if (formKey.currentState.validate()) {
        _bloc.add(LoginEvent(
            user: Logginer(
                username: emailTextEditingController.text,
                password: passwordTextEditingController.text,
                macAddress: _platformImei /*macAddress*/)));
      }
    } else {
      scaffoldKey.currentState.showBottomSheet((widgetBuilder) {
        return Container(
          height: 50,
          width: double.infinity,
          color: Colors.blue,
          child: Center(
              child: Text(
            'There is no internet connection',
            style: GoogleFonts.voces(fontSize: 12.0 , color:  Colors.white),
          )),
        );
      }, backgroundColor: Colors.blue);
/*      UtilsClass.showMyDialog(
          context: context,
          content: ,
          type: DialogType.warning);*/
    }
  }

  saveApiKey(Employee employee) async {
    await SharedPreferencesOperations.saveApiKeyAndIdAndImg(
            employee.apiKey, employee.employeeId, employee.employeeImage)
        .then((onValue) {
      print('api key and saved ');
    });
  }

  saveKeepMeLoggedIn() async {
    await SharedPreferencesOperations.saveKeepMeLoggedIn(switchState);
  }

  showProgressDialog() async {
    // await Future.delayed(const Duration(milliseconds: 100), () {
      progressLoading = ProgressDialog(
        context,
        type: ProgressDialogType.Normal,
        isDismissible: true,
        showLogs: false,
      );
      progressLoading.show();
    // });
  }

/*  Future<String> macAddressChecker() async {
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
  }*/

  Future<void> initPlatformState() async {
    if (Platform.isIOS) {
      getAddress();
    } else {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      String  identifier;
      if(androidInfo.version.sdkInt > 28){
        identifier = await UniqueIdentifier.serial;
      }else {
        identifier = await ImeiPlugin.getImei(shouldShowRequestPermissionRationale: false);
        // List<String> multiImei = await ImeiPlugin.getImeiMulti();
        // print(multiImei);
        // idunique = await ImeiPlugin.getId();
      }
      if(mounted) {
        setState(() {
          _platformImei = identifier;
          // uniqueId = idunique;
        });
      }
    }
  }
// mac address using channel in ios

  static const AddressChannel = const MethodChannel('macAddress');
//function
  Future<void> getAddress() async {
    String address;
    try {
      var result = await AddressChannel.invokeMethod('getMacAddress');
      address = result;
    } on PlatformException catch (e) {
      address = "failed to get address";
    }

    if(mounted) {
    setState(() {
      _platformImei = address;
    });
    }
  }

  requestPermission() async {
    var result = await Permission.storage.request();
    if (result.isGranted) {
      print('granted .. ');
    } else {
      print('denied');
    }
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }



   getKeep() async{
    if(await SharedPreferencesOperations.getKeepMeLoggedIn() == null){
      switchState = false;
    }else {
      switchState = await SharedPreferencesOperations.getKeepMeLoggedIn();
    }
    return switchState;
  }

  void saveUsernameAndPassword() async{
    await SharedPreferencesOperations.saveUserNameAndPassword(emailTextEditingController.text, passwordTextEditingController.text).
    then((value){
      print("username and password saved ");
    }).catchError((onError){
      print(onError.toString());
    });
  }

  void saveMac()async {
    await SharedPreferencesOperations.saveMac(_platformImei);
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
