import 'dart:convert';
import 'dart:ui';
import 'package:timecarditg/models/Client.dart';
import 'package:timecarditg/models/Employee.dart';
import 'package:timecarditg/models/HomeInformation.dart';
import 'package:timecarditg/models/checkInResponse.dart';
import 'package:timecarditg/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:timecarditg/utils/sharedPreference.dart';
import 'package:timecarditg/utils/utils.dart';
import '../utils/Constants.dart';


class ApiCalls {
  static Future<Employee> Login (Logginer user) async{
    Employee emp ;
    http.Response response =await   http.post(Constants.getLoginUrl(user.username, user.password, '00:00:00:00:00:00'));
    print(response.body.toString() + '${response.statusCode}');
    var jsonDecsode = await jsonDecode(response.body);
    var flag = jsonDecsode['Flag'];
    if(flag==1){
      emp = Employee.fromJson(jsonDecsode);
      print(emp.apiKey);

      getClient(emp.apiKey);
      return emp;
    }
    else return null;



  }
  static Future<HomeInfo> getHomeInformation () async{
    Employee employee = await SharedPreferencesOperations.getApiKeyAndId();
    http.Response response =await   http.get(Constants.getHomeInformationUrl(employee.employeeId.toString(),employee.apiKey));
        var jsonDecoded = jsonDecode(response.body);
       return HomeInfo.fromJson(jsonDecoded);
  }
  static Future<CheckInResponse> checkIn(  String apiKey, String employeeId,String checkInTime, String logginMachine
      , String location, String client, String addressInfo)async {
    String url;
    url = Constants.getCheckUrl(Constants.checkIn);
    print('check in url : ' + url +'\n'+
        'api key = '+apiKey +'\n'+
        'employeeId = '+employeeId +'\n'+
        'checkInTime = '+checkInTime +'\n'+
        'logginMachine = '+logginMachine +'\n'+
        'location = '+location +'\n'+
        'client = '+client +'\n'+
        'addressInfo = '+addressInfo +'\n'

    );

    var  mParams = new Map<String, String>();
    //addressInfo = addressInfo.replace(" "] "%20");
    mParams["EmployeeId"]= employeeId;
    mParams["ApiKey"]= apiKey;
    mParams["LogginMachine"] =logginMachine;
    mParams["Locations"] =location;
    mParams["Clients"]= client == 'Client Name' ? " ' ' " : client;
    mParams["AddressesInfo"] = addressInfo != "" ? addressInfo:" ' ' ";
    mParams["Times"] =checkInTime;

    if ( (await Utils.checkConnectivity())==connectStatus.connected) {// check connection
      try {
        http.Response response = await http.post(url, body: mParams);
        print(response.body);
        CheckInResponse checkInResponse= CheckInResponse();
        var json = jsonDecode(response.body);
        var json2 = json['Status'];
        print(json2[0]);
        checkInResponse = CheckInResponse.fromJson(json);
        checkInResponse.status =json2[0].toString();
        return checkInResponse;
      }
      catch (ex)
      {
        print("XXXXXXXX ERROR XXXXXXXXX "+ex.toString());
      }
    } else {
    }
  }
  static Future<CheckInResponse> checkOut(  String apiKey, String employeeId,String checkOutTime, String logginMachine
      , String location, String client, String addressInfo)async {
    String url;
    url = Constants.getCheckUrl(Constants.checkOut);
    print('check in url : ' + url +'\n'+
        'api key = '+apiKey +'\n'+
        'employeeId = '+employeeId +'\n'+
        'checkInTime = '+checkOutTime +'\n'+
        'logginMachine = '+logginMachine +'\n'+
        'location = '+location +'\n'+
        'client = '+client +'\n'+
        'addressInfo = '+addressInfo +'\n'

    );

    var  mParams = new Map<String, String>();
    //addressInfo = addressInfo.replace(" "] "%20");
    mParams["EmployeeId"]= employeeId;
    mParams["ApiKey"]= apiKey;
    mParams["LogginMachine"] =logginMachine;
    mParams["Locations"] =location;
    mParams["Clients"]= client == 'Client Name' ? " ' ' " : client;
    mParams["AddressesInfo"] = addressInfo != "" ? addressInfo:" ' ' ";
    mParams["Times"] =checkOutTime;

    if ( (await Utils.checkConnectivity())==connectStatus.connected) {// check connection
      try {
        http.Response response = await http.post(url, body: mParams);
        print(response.body);
        CheckInResponse checkInResponse= CheckInResponse();
        var json = jsonDecode(response.body);
        var json2 = json['Status'];
        print(json2[0]);
        checkInResponse = CheckInResponse.fromJson(json);
        checkInResponse.status =json2[0].toString();
        return checkInResponse;
      }
      catch (ex)
      {
        print("XXXXXXXX ERROR XXXXXXXXX "+ex.toString());
      }
    } else {
    }
  }

  static Future<List<Client>> getClient(String apiKey) async{
    var clientsUrl = Constants.getClientsUrl(apiKey);
    http.Response response =await   http.get(clientsUrl);
    var json = await jsonDecode(response.body);
    List<Client> clients =List() ;
    json['AllClients'].forEach((v) {
      clients.add(new Client.fromJson(v));
    });

    return clients;
  }
  static Future<List<String>> getClientNames (String apiKey) async{
    List<String>companyNames=List();
    companyNames.add('Client Name');
    var list = await getClient(apiKey);
    list.forEach((f){
      companyNames.add(f.companyName);
    });

    return companyNames;
  }

}

