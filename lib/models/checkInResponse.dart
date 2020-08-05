import 'package:timecarditg/models/BaseModel.dart';

class CheckInResponse extends BaseModel{
  String status ;
  String message ;
  int flag;

  CheckInResponse({this.status, this.message, this.flag});

  factory CheckInResponse.fromJson(Map<String, dynamic> json) {
    return CheckInResponse(
      flag: json['Flag'],
      message : json['Message'],
    );
  }


  }
