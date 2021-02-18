import 'package:shared_preferences/shared_preferences.dart';
import 'package:timecarditg/models/Employee.dart';
import 'package:timecarditg/utils/Constants.dart';

class SharedPreferencesOperations {
  static Future<bool> saveApiKeyAndIdAndImg(
      String apiKey, int id, String img) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool savedApiKey = await prefs.setString(Constants.apiKey, apiKey);
    bool savedId = await prefs.setInt(Constants.id, id);
    bool savedImg = await prefs.setString(Constants.img, img);
    return savedApiKey && savedId && savedImg;
  }

  static Future<String> saveHomeData(String homeInfo) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
//    String convertObject  = json.encode(homeInfo);
    if (prefs.getString(Constants.homeInfoStr) != null) {
      prefs.remove(Constants.homeInfoStr);
    }
    var saveObjectStr = await prefs.setString(Constants.homeInfoStr, homeInfo);
    return saveObjectStr.toString();
  }

  static Future<String> fetchHomeData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var homeInfo = prefs.getString(Constants.homeInfoStr);
    return homeInfo;
  }

  static Future<Employee> getApiKeyAndId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedApiKey = prefs.getString(Constants.apiKey);
    int savedId = prefs.getInt(Constants.id);
    print(savedApiKey + savedId.toString());
    return Employee(apiKey: savedApiKey, employeeId: savedId);
  }

  static Future<bool> saveKeepMeLoggedIn(bool isKeep) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool savedKeepMe = await prefs.setBool(Constants.keep, isKeep);
    print('save keep me logged in $isKeep');
    return savedKeepMe;
  }

  static Future<bool> saveMac(String macAddress) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool savedMacAddress =
        await prefs.setString(Constants.macAddress, macAddress);
    print('save mac address   $savedMacAddress');
    return savedMacAddress;
  }

  static Future<String> getMac() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedMacAddress = prefs.getString(Constants.macAddress);
    print('get mac address  $savedMacAddress');
    return savedMacAddress;
  }

  static Future<bool> saveUserNameAndPassword(
      String username, String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool savedUsername = await prefs.setString(Constants.username, username);
    bool savedPassword = await prefs.setString(Constants.password, password);
    print('save username  $savedUsername');
    print('save password $savedPassword');
    return savedUsername;
  }

  static Future<List<String>> getUsernameAndPassword() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> info = List();
    String savedUsername = prefs.getString(Constants.username);
    String savedPassword = prefs.getString(Constants.username);
    info.add(savedUsername);
    info.add(savedPassword);
    return info;
  }

  static Future<bool> getKeepMeLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool savedKeepMe = prefs.getBool(Constants.keep);
    print('get keep me $savedKeepMe');
    return savedKeepMe;
  }

  static Future<bool> clearAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.clear();
  }

  static Future<bool> saveLoggedOut(bool isLogged) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedOut = await prefs.setBool(Constants.isLoggedOut, isLogged);
    return loggedOut;
  }

  static Future<bool> getLoggedOut() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedOut = prefs.getBool(Constants.isLoggedOut);
    return loggedOut;
  }

  static Future<bool> removeAllShared() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool logedOut = await prefs.clear();
    return logedOut;
  }

  static Future<bool> saveClients(String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedOut;
    // if( prefs.getString(Constants.CLIENT_NAME) == null ){
    loggedOut = await prefs.setString(Constants.CLIENT_NAME, name);
    // }
    return loggedOut;
  }

  static Future<String> getClients() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String loggedOut = prefs.getString(Constants.CLIENT_NAME);
    return loggedOut;
  }
}
