import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:timecarditg/Blocs/CheckInBloc.dart';
import 'package:timecarditg/Blocs/InternetConnectionBloc.dart';
import 'package:timecarditg/Blocs/LoginBloc.dart';
import 'package:timecarditg/Blocs/home_bloc.dart';
import 'package:timecarditg/customWidgets/customWidgets.dart';
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

class _SignInState extends State<SignIn> {

  String _platformVersion = 'Unknown';
  ProgressDialog pr;
  LoginBloc _bloc ;
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool switchState = true;
  var mainColor = Color(0xFF1589d2);

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _bloc = BlocProvider.of<LoginBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery
        .of(context)
        .size
        .height;
    var width = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
        body: Stack(
          children: <Widget>[
            Image.asset('assets/images/login.png', height: height,
              width: width,
              fit: BoxFit.cover,),
            SingleChildScrollView(
                child:
                Column(
                  children: <Widget>[
                    buildLogo(),
                    buildTitle(),
                    SizedBox(height: height * .23,),
                    Container(height: height - 50, child:
                    Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24
                          ),
                          child: buildLoginForm()
                      ),
                    ),
                  ],
                )),
          ],
        )
    );
  }

  Widget buildLogo(){
    return  Padding(
      padding: const EdgeInsets.only(top:50.0),
      child: Center(
        child: Image.asset('assets/images/logo.png',height: 100,),
      ),
    );
}

  Widget buildTitle(){
    return  Center(child: Padding(
      padding: const EdgeInsets.only(top : 8.0),
      child: Text('  ITG TimeCard' , style:  TextStyle(
          color: Color(0xff0066CC), fontWeight: FontWeight.bold, fontSize: 20
      ),
      ),
    ));
}

  Widget buildLoginForm(){
    return Form(
      key: formKey,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            BlocListener<LoginBloc , BaseResultState>(
              bloc: _bloc,
              listener: (context , state) async{
                if (state.result == dataResult.Loading) {
                  showProgressDialog();
                }
                else if (state.result == dataResult.Loaded) {
                  saveKeepMeLoggedIn();
                  var employee = (state.model as Employee);
                  saveApiKey(employee);
                  Timer(Duration(seconds: 3), () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return   BlocProvider(
                          child: MainScreen(),
                          create: (_)=>HomeInfoBloc(),
                        );
                      }),
                    );
                  });
                }
                else if (state.result == dataResult.Error) {
                  if(pr !=null){
                    pr.hide();}
                  UtilsClass.showMyDialog(content: "Invalid username or password or may "
                      "be your mac Address is not Registered",
                    context: context,
                    type: DialogType.warning,
                    onPressed: dismissLoading
                  );
                }
              },
              child: Container(),
            ),
            buildUserName(),
            SizedBox(height:8,) ,
            buildPassword(),
            SizedBox(height: 8,),
            buildKeepMeLogIn(),
            SizedBox(height: 8,),
            buildLogInButton(),
            SizedBox(height: 16,),
            Row(
              children: <Widget>[
                Text('Mac Address :', style: TextStyle(color: Colors.black87 , fontWeight: FontWeight.bold),),
                Text(_platformVersion, style: TextStyle(color: mainColor , fontWeight: FontWeight.bold),)
              ],
            )
          ]
      ),
    );
  }

  Widget buildUserName(){
    return TextFormField(
            controller: emailTextEditingController,
            textAlign: TextAlign.start,
            style: TextStyle(color: Colors.black),
            decoration: customInputDecoration('username') ,
            validator: (val){
              return val.length < 4 ? "Enter a Valid username" : null;
            }
      );
  }



  void dismissLoading()async{
    await Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.of(context).pop();
    });

  }


  Widget buildPassword(){
    return  TextFormField(
        controller: passwordTextEditingController,
        style: TextStyle(color: Colors.black),
        decoration: customInputDecoration('Password') ,
        obscureText: true,
        validator: (val){
          return val.length < 4 ? "Enter Password 6+ characters" : null;
        }
    );
  }

  Widget buildKeepMeLogIn() {
  return Row(
    children: <Widget>[
      Text('Keep me logged in ', style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black
      ),),
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
  );
}

  Widget buildLogInButton(){
    return GestureDetector(
      onTap: () => logInFun(),
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('Sign in' , style:  simpleTextStyle(),),
        decoration: BoxDecoration(
          color: mainColor,
        ),
      ),
    );

}

  logInFun() async {
  connectStatus checkConnectivity = await UtilsClass.checkConnectivity();
  if (checkConnectivity == connectStatus.connected) {
    String macAddress = await macAddressChecker();
    if (formKey.currentState.validate()) {
      _bloc.add(
          LoginEvent(user: Logginer(username: emailTextEditingController.text,
              password: passwordTextEditingController.text,
              macAddress: macAddress)));
    }
  }
  else {
    UtilsClass.showMyDialog(context: context,
        content: 'There is no internet connection',
        type: DialogType.warning);
  }
}

  saveApiKey(Employee employee)async{
    await SharedPreferencesOperations.saveApiKeyAndId(employee.apiKey , employee.employeeId).then((onValue){
      print('api key and saved ');
    });
  }

  saveKeepMeLoggedIn()async{
    await SharedPreferencesOperations.saveKeepMeLoggedIn(switchState);
  }

  showProgressDialog()async{
    pr = await ProgressDialog(context,type: ProgressDialogType.Normal,
      isDismissible: true,
      showLogs: false,);
    pr..style(
        message: 'Loading ...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(backgroundColor: Colors.grey,),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
    );
    pr.show();
  }

  Future<String> macAddressChecker ()async{
    try{
      await requestPermission();
      String macAddress = await UtilsClass.loadMacAddress();
      if( macAddress  =='') {
        return _platformVersion;
      }
      else{
        print('loaded : $macAddress');
        return macAddress;
      }
    }
    catch (e){
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

  requestPermission()async{
    var result = await Permission.storage.request();
    if(result.isGranted){
      print('granted .. ');
    }
    else {
      print('denied');
    }
  }

}

