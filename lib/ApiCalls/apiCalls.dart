import 'dart:convert';
import 'package:timecarditg/models/CheckModel.dart';
import 'package:timecarditg/models/Client.dart';
import 'package:timecarditg/models/Employee.dart';
import 'package:timecarditg/models/HomeInformation.dart';
import 'package:timecarditg/models/checkInResponse.dart';
import 'package:timecarditg/models/login_error.dart';
import 'package:timecarditg/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:timecarditg/utils/sharedPreference.dart';
import 'package:timecarditg/utils/strings.dart';
import 'package:timecarditg/utils/utils.dart';
import '../utils/Constants.dart';


class ApiCalls {

  static Future<Object> loginCall (Logginer user) async{
    Employee emp ;
    print(user.username);
    print(user.password);
    print(user.macAddress);
    String request = Constants.getLoginUrl(user.username, user.password,user.macAddress);
    http.Response response = await http.post(request);
    print(request);
    print(response.body.toString() + '${response.statusCode}');
    var jsonDecsode = await jsonDecode(response.body);
    var flag = jsonDecsode['Flag'];
    if(flag==1){
      emp = Employee.fromJson(jsonDecsode);
      print(emp.apiKey);
      fetchClient(emp.apiKey);
      return emp;
    }
    else return LoginError.fromJson(jsonDecsode);
  }

  static Future<HomeInfo> fetchHomeInfo () async {
    Employee employee = await SharedPreferencesOperations.getApiKeyAndId();
    try {
      http.Response response = await http.get(Constants.getHomeInformationUrl(
          employee.employeeId.toString(), employee.apiKey));
      var jsonDecoded = jsonDecode(response.body);
      print('RESPONSE ===>>>> ${response.body}');
      SharedPreferencesOperations.saveHomeData(response.body);
      return HomeInfo.fromJson(jsonDecoded);
    }catch(ex){
      return null;
    }
  }

  static Future<CheckInResponse> checkService(CheckModel checkObject)async {
    String url = '' ;
    CheckInResponse checkInResponse= CheckInResponse();
    if(checkObject.checkType == 1){
      url = Constants.getCheckUrl(Constants.checkIn);
    }
    else {
      url = Constants.getCheckUrl(Constants.checkOut);
    }
    print('check in url : ' + url + checkObject.toString());
    var  mParams = new Map<String, String>();
    mParams["EmployeeId"]= checkObject.employeeId.toString();
    mParams["ApiKey"]= checkObject.apiKey;
    mParams["LogginMachine"] = checkObject.logginMachine;
    mParams["Locations"] =checkObject.location;
    mParams["Clients"]= checkObject.client == 'Client Name' ? " ' ' " : checkObject.client;
    mParams["AddressesInfo"] = checkObject.addressInfo != "" ? checkObject.addressInfo:" ' ' ";
    mParams["Times"] = checkObject.time;
/*    if(checkObject.fromWhere == from_itg) {
      mParams["FromWhere"] = "1";
    }else if(checkObject.fromWhere == from_home) {
      mParams["FromWhere"] = "2";
    }else if(checkObject.fromWhere == from_others){
      mParams["FromWhere"] = "3";
    }*/
    mParams["FromWhere"] = checkObject.fromWhere == from_itg ? "1" : checkObject.fromWhere == from_home ? "2" :  "3" ;
    print(jsonEncode(mParams).toString());
    if ( (await UtilsClass.checkConnectivity())==connectStatus.connected) {
      try {
        http.Response response = await http.post(url, body: mParams);
        print(response.body);
        var json = jsonDecode(response.body);
        var json2 = json['Status'];
        print(json2[0]);
        checkInResponse = CheckInResponse.fromJson(json);
        checkInResponse.status =json2[0].toString();
      }
      catch (ex) {
        checkInResponse.status = 'failed';
        checkInResponse.flag = 0 ;
        checkInResponse.message = 'failed';
      }
    }
    else {
      checkInResponse.status = 'failed';
      checkInResponse.flag = 0 ;
      checkInResponse.message = 'failed';
    }
    return checkInResponse;

  }


  static Future<List<Client>> fetchClient(String apiKey) async{
    var clientsUrl = Constants.getClientsUrl(apiKey);
    http.Response response =await   http.get(clientsUrl);
    var json = await jsonDecode(response.body);
    List<Client> clients = List() ;
    json['AllClients'].forEach((v) {
      clients.add(new Client.fromJson(v));
    });
    return clients;
  }

  static Future<List<String>> fetchClientNames (String apiKey) async{
    List<String>companyNames=List();
    companyNames.add('Client Name');
    var list = await fetchClient(apiKey);
    list.forEach((f){
      companyNames.add(f.companyName);
      print('${f.companyName}');
    });

    return companyNames;
  }

}

