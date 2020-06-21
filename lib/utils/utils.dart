import 'dart:io';
import 'package:ext_storage/ext_storage.dart';
import 'package:get_mac/get_mac.dart';
import 'package:flutter/services.dart';


class Utils {
  static Future <connectStatus> checkConnectivity ()async{
    bool checkConnection = await _checkInternetConnection();
    return checkConnection ? connectStatus.connected: connectStatus.disconnected;

  }
  static Future<bool> _checkInternetConnection ()async{
    bool iSConnected ;
    try{
      final result = await InternetAddress.lookup('google.com');
      if(result.isNotEmpty && result[0].rawAddress.isNotEmpty)
      {
        iSConnected =true;
      }
    }on SocketException catch(_){
      iSConnected =false ;
    }
    return iSConnected;
  }

  static String platformVersion;
  static String path='/storage/emulated/0/DCIM/deviceMacAddressData.dat';


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
    final file = await File(path);
    // Write the file.
    return file.writeAsString(macAddress);
  }
 static Future<String> loadMacAddress() async {
    try {
      final file = await File(path);
/*
      await file.delete();
*/
      // Read the file.
      String contents = await file.readAsString();
      print(contents);
      return contents;
    } catch (e) {
      // If encountering an error, return 0.
      return '';
    }
  }
}


enum connectStatus{
  disconnected ,
  connected

}
// Save Mac Address

