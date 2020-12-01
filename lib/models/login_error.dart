import 'BaseModel.dart';

class LoginError extends BaseModel{
  String message , employeeInformation , expiredTime;
  int flag ;


  LoginError(
  {this.message, this.employeeInformation, this.expiredTime, this.flag});

  factory LoginError.fromJson(Map<String, dynamic> json) {
    return LoginError(
      message: json["Message"],
      employeeInformation:  json["Employee_Information"],
      expiredTime: json["Expired_Time"],
      flag: json["Flag"],
    );
  }
}