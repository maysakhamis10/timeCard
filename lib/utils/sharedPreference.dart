import 'package:shared_preferences/shared_preferences.dart';
import 'package:timecarditg/utils/Constants.dart';
import 'package:timecarditg/models/Employee.dart';

class SharedPreferencesOperations {

  static Future<bool>saveApiKeyAndIdAndImg (String apiKey,int id , String img )async{
    final SharedPreferences prefs = await  SharedPreferences.getInstance();
    bool savedApiKey =await prefs.setString(Constants.apiKey, apiKey);
    bool savedId =await prefs.setInt(Constants.id, id);
    bool savedImg =await prefs.setString(Constants.Img, img);
    return savedApiKey && savedId && savedImg;
  }

  static Future<String>saveHomeData(String homeInfo)async{
    final SharedPreferences prefs = await  SharedPreferences.getInstance();
//    String convertObject  = json.encode(homeInfo);
    if( prefs.getString(Constants.homeInfoStr) !=null) {
      prefs.remove(Constants.homeInfoStr);
    }
    var saveObjectStr  = await prefs.setString(Constants.homeInfoStr , homeInfo);
    return saveObjectStr.toString();
  }

  static Future<String> fetchHomeData()async{
    final SharedPreferences prefs = await  SharedPreferences.getInstance();
    var homeInfo = prefs.getString(Constants.homeInfoStr);
    return homeInfo ;
  }


  static Future<Employee>getApiKeyAndId ( )async{
    final SharedPreferences prefs = await  SharedPreferences.getInstance();
    String savedApiKey = prefs.getString(Constants.apiKey);
    int savedId = prefs.getInt(Constants.id);
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
    bool savedKeepMe = prefs.getBool(Constants.keep);
    print('get keep me $savedKeepMe');
    return savedKeepMe;
  }

  static Future<bool>clearAll ( )async{
    final SharedPreferences prefs = await  SharedPreferences.getInstance();
     return await prefs.clear();
  }

  static Future<bool>saveLoggedOut (bool isLogged )async{

    final SharedPreferences prefs = await  SharedPreferences.getInstance();
    bool loggedOut =await prefs.setBool(Constants.isLoggedOut, isLogged);
    return loggedOut;
  }

  static Future<bool>getLoggedOut ( )async{
    final SharedPreferences prefs = await  SharedPreferences.getInstance();
    bool loggedOut = prefs.getBool(Constants.isLoggedOut);
    return loggedOut;
  }


  static Future<bool> removeAllShared() async {
    final SharedPreferences prefs = await  SharedPreferences.getInstance();
    bool logedOut = await prefs.clear();
    return logedOut;

  }

  static Future<bool>saveClients (String name)async{

    final SharedPreferences prefs = await  SharedPreferences.getInstance();
    bool loggedOut ;
    // if( prefs.getString(Constants.CLIENT_NAME) == null ){
      loggedOut = await prefs.setString(Constants.CLIENT_NAME, name);
    // }
    return loggedOut;
  }

  static Future<String> getClients ( )async{
    final SharedPreferences prefs = await  SharedPreferences.getInstance();
    String loggedOut = prefs.getString(Constants.CLIENT_NAME);
    return loggedOut;
  }



}