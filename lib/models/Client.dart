import 'package:timecarditg/models/BaseModel.dart';

class Client extends BaseModel{
  String companyName ;
  int companyId ;

  Client({this.companyName, this.companyId});

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
     companyName : json['CombanyName'],
      companyId : json['CombanyId'],
    );
  }
}