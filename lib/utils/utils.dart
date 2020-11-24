import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_mac/get_mac.dart';
import 'package:flutter/services.dart';
import 'package:timecarditg/Blocs/LoginBloc.dart';
import 'package:timecarditg/Screens/LoginScreen.dart';
import 'package:timecarditg/utils/sharedPreference.dart';


class UtilsClass {
 static logOut(BuildContext context){
   SharedPreferencesOperations.saveKeepMeLoggedIn(false);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> BlocProvider<LoginBloc>(
      create: (_) => LoginBloc(),
      child: SignIn(),
    )));
  }
  static Future <connectStatus> checkConnectivity() async {
    bool checkConnection = await _checkInternetConnection();
    return checkConnection ? connectStatus.connected : connectStatus
        .disconnected;
  }

  static Future<bool> _checkInternetConnection() async {
    bool iSConnected;
    try {
      final result = await InternetAddress.lookup("google.com");
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        iSConnected = true;
      }
    } on SocketException catch (_) {
      iSConnected = false;
    }
    return iSConnected;
  }

  static String platformVersion;
  static String path = '/storage/emulated/0/DCIM/deviceMacAddressData.dat';


  static Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await GetMac.macAddress;
    } on PlatformException {
      platformVersion = 'Failed to get Device MAC Address.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

  }


  static Future<File> saveMacAddress(String macAddress) async {
    await initPlatformState();
    final file =  File(path);
    return file.writeAsString(macAddress);
  }

  static Future<String> loadMacAddress() async {
    try {
      final file =  File(path);
      String contents = await file.readAsString();
      print(contents);
      return contents;
    } catch (e) {
      return '';
    }
  }

  static Future<Position> getCurrentLocation() async {
    final Geolocator userLocation = Geolocator()
      ..forceAndroidLocationManager;
    return await userLocation
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  }

  static void showMyDialog({BuildContext context, DialogType type,
      String content, Function onPressed}) {
    AlertDialog successDialog = AlertDialog(
      title: Text(type != DialogType.confirmation ? 'Warning' : 'Confirmation'),
      content: Text(content),
      actions: <Widget>[
        FlatButton(
          child: Text(
              'Ok'
          ),
          onPressed: () => onPressed(),
        )
      ],
    );
    showDialog(context: context,
        barrierDismissible: false,
        builder: (c) => successDialog);
  }
}
enum connectStatus{
  disconnected ,
  connected

}
enum DialogType{
  confirmation ,
  warning

}
// Save Mac Address

