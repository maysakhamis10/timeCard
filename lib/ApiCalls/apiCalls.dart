import 'dart:convert';
import 'package:timecarditg/models/Employee.dart';
import 'package:timecarditg/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:timecarditg/utils/utils.dart';
import '../Constants.dart';


class ApiCalls {
 static Future<Employee> Login (Logginer user) async{
   http.Response response =await   http.post(Constants.getLoginUrl(user.username, user.password, '00:00:00:00:00:00'));
   print(response.body.toString() + '${response.statusCode}');
   var jsonDecsode = await jsonDecode(response.body);
   var flag = jsonDecsode['Flag'];
   if(flag==1){
     Employee emp = Employee.fromJson(jsonDecsode['Employee_Information']);
     print(emp.username);
     return emp;
   }
   else return null;



  

  }
  void checkIn(  String apiKey, String employeeId,String checkInTime, String logginMachine
     , String location, String client, String addressInfo)async {
   String url;
   url = Constants.getCheckUrl(Constants.CheckIn);
  var  mParams = new Map<String, String>();
   //addressInfo = addressInfo.replace(" "] "%20");
   mParams["EmployeeId"]= employeeId;
   mParams["ApiKey"]= apiKey;
   mParams["LogginMachine"] =logginMachine;
   mParams["Locations"] =location;
   mParams["Clients"]= client;
   mParams["AddressesInfo"] =addressInfo;
   mParams["Times"] =checkInTime;


   if ( (await Utils.checkConnectivity())==connectStatus.connected) {// check connection
     http.Response response =await   http.post(url,body: mParams);
     print(response.body);
   } else {
   }
 }

  }

