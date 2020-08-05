import 'package:timecarditg/Blocs/InternetConnectionBloc.dart';

class CheckModel  extends BaseEvent{

  String  client , addressInfo ,date , time ,apiKey, logginMachine ,location;
  int checkType , sync ,isOnline , employeeId , isAdded;


//  (employee_id INTEGER , date TEXT, '
//  'time INTEGER,api_key TEXT,check_type INTEGER , '
//  'client TEXT , address_info TEXT , loggin_machine TEXT , '
//  'location TEXT , sync INTEGER ,  isOnline INTEGER)');
  CheckModel({
    this.employeeId,
    this.client,
    this.addressInfo,
    this.date,
    this.time,
    this.apiKey,
    this.logginMachine,
    this.location,
    this.checkType,
    this.sync,
    this.isOnline,
  this.isAdded});



  CheckModel.fromJson(Map<String, dynamic> json)
      : employeeId = json['employee_id'],
        client = json['client'],
        addressInfo=json['address_info'],
        date = json['date'],
        time=json['time'],
        apiKey =json['api_key'],
        logginMachine = json['loggin_machine'] ,
        location =json['location'],
        checkType = json['check_type'] ,
        sync= json['sync'],
        isAdded = json['isAdded'],
        isOnline = json['isOnline'];

  Map<String, dynamic> toJson() => {
    'employee_id': employeeId,
    'client': client,
    'address_info' : addressInfo,
    'date': date,
    'time': time,
    'api_key' : apiKey ,
    'loggin_machine' : logginMachine,
    'location' : location,
    'check_type' : checkType,
    'sync' : sync,
    'isAdded' :isAdded,
    'isOnline' : isOnline
  };

}