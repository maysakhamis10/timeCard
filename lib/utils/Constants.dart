import 'package:timecarditg/Screens/MainScreen.dart';
import 'package:timecarditg/models/HomeInformation.dart';

import '../Screens/transactions_screens.dart';

class Constants {

  static String baseUrl = "https://mobileapp.itgsolutions.com/EmployeePortal/";
  static String checkIn = "CheckIn";
  static String employeeId = "";
  static String keep = "keepMe";
  static String IsLoggedOut = "IsLoggedOut";
  static String checkOut = "CheckOut";
  static String apiKey = "apiKey";
  static String id = "id";
  static String homeInfoStr = "HomeInfo";

  static const String HomePage = MainScreen.routeName;
  static const String TRANSACTIONS = TransactionsScreen.routeName;

  static String getLoginUrl(String userName, String pass, String macAddress) {
    String loginurl = baseUrl;
    loginurl += "LogIn?" + "Username=" + userName + "&Password=" + pass +
        "&MacAddress=" + macAddress;//macAddress;
    return loginurl;
  }

  static String getHomeInformationUrl(String employeeId, String apiKey) {
    String homeInformationUrl = baseUrl;
    homeInformationUrl += "GetHomeInformation?" + "employeeId=" + employeeId + "&apiKey=" + apiKey;
    return homeInformationUrl;
  }

  static String getCheckUrl(String type) {
    String checkUrl = baseUrl;

    if (type == checkIn) {
      checkUrl += "CheckIn";
    } else {
      checkUrl += "CheckOut";
    }
    //  checkUrl += "employeeId=" + EmployeeId + "&apiKey=" + apiKey + "&logginMachine=" + logginMachine + "&location=" + location + "&client=" + client + "&addressInfo=" + addressInfo + "&checkInTime=" + checkInTime;

    return checkUrl;
  }

  static String getClientsUrl(String apiKey) {
    String clientsUrl = baseUrl;
    clientsUrl += "GetClients?" + "apiKey=" + apiKey;
    return clientsUrl;
  }

}