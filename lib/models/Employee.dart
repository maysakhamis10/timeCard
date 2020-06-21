import 'package:timecarditg/models/BaseModel.dart';

class Employee extends BaseModel{
  String  username;
  int employeeId ;
  String apiKey;

  Employee({this.employeeId, this.username, this.apiKey});
  factory Employee.fromJson(Map<String, dynamic> json) {

    var jsonDecoded =json['Employee_Information'];

    return Employee(
      apiKey:json['API_KEY'],
      employeeId : jsonDecoded['EmployeeId'],
      username: jsonDecoded['UserName'],
    );
}
}