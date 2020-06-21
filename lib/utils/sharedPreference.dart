import 'package:shared_preferences/shared_preferences.dart';
import 'package:timecarditg/utils/Constants.dart';
import 'package:timecarditg/models/Employee.dart';

class SharedPreferencesOperations {
  static Future<bool>saveApiKeyAndId (String apiKey,int id )async{

    final SharedPreferences prefs = await  SharedPreferences.getInstance();
    bool savedApiKey =await prefs.setString(Constants.apiKey, apiKey);
    bool savedId =await prefs.setInt(Constants.id, id);
    return savedApiKey && savedId;
  }

  static Future<Employee>getApiKeyAndId ( )async{
    final SharedPreferences prefs = await  SharedPreferences.getInstance();
    String savedApiKey =await prefs.getString(Constants.apiKey);
    int savedId =await prefs.getInt(Constants.id);
    print(savedApiKey + savedId.toString());
    return Employee(apiKey: savedApiKey, employeeId: savedId);

  }
  static Future<bool>saveKeepMeLoggedIn (bool isKeep )async{

    final SharedPreferences prefs = await  SharedPreferences.getInstance();
    bool savedKeepMe =await prefs.setBool(Constants.keep, isKeep);
    print('save keep me logged in $isKeep');
    return savedKeepMe;
  }
  static Future<bool>getKeepMeLoggedIn ( )async{
    final SharedPreferences prefs = await  SharedPreferences.getInstance();
    bool savedKeepMe =await prefs.getBool(Constants.keep);
    print('get keep me $savedKeepMe');
    return savedKeepMe;
  }
  static Future<bool>clearAll ( )async{
    final SharedPreferences prefs = await  SharedPreferences.getInstance();
     return await prefs.clear();
  }
  static Future<bool>saveLoggedOut (bool isLogged )async{

    final SharedPreferences prefs = await  SharedPreferences.getInstance();
    bool loggedOut =await prefs.setBool(Constants.IsLoggedOut, isLogged);
    return loggedOut;
  }
  static Future<bool>getLoggedOut ( )async{
    final SharedPreferences prefs = await  SharedPreferences.getInstance();
    bool loggedOut =await prefs.getBool(Constants.IsLoggedOut);
    return loggedOut;
  }
/*  static Future<bool>saveCheckInTime (String time)async{
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    bool saved =await prefs.setString(Constants.CheckIn, time);
    return saved;
  }

  static Future<bool>saveCheckOutTime (String time)async{
     Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
     final SharedPreferences prefs = await _prefs;
     bool saved =await prefs.setString(Constants.CheckOut, time);
     return saved;
   }
   static  Future<String>getCheckOutTime ()async{
     Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
     final SharedPreferences prefs = await _prefs;
     String saved =await prefs.getString(Constants.CheckOut);
     return saved;
   }
   static Future<String>getCheckInTime ()async{
     Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
     final SharedPreferences prefs = await _prefs;
     String saved =await prefs.getString(Constants.CheckOut);
     return saved;
   }*/



}