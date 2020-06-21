import 'package:timecarditg/Screens/MainScreen.dart';

import 'Screens/transactions_screens.dart';

class Constants {

     static  String baseUrl = "https://mobileapp.itgsolutions.com/EmployeePortal/";
     static  String CheckIn = "CheckIn";

     static  String apiKey = "";
     static  String employeeId = "";


     static const String HomePage = MainScreen.routeName;
     static const String TRANSACTIONS = TransactionsScreen.routeName;





    static String getLoginUrl(String userName, String pass, String macAddress) {
      String loginurl = baseUrl;
      loginurl += "LogIn?" + "Username=" + userName + "&Password=" + pass + "&MacAddress=" + macAddress;
      print('url is ==> ${loginurl}');
      return loginurl;
   }
      static String getCheckUrl(String type) {
        String checkUrl = baseUrl;
        if (type == CheckIn) {
          checkUrl += "CheckIn";
        } else {
          checkUrl += "CheckOut";
        }
        return checkUrl;
      }

}