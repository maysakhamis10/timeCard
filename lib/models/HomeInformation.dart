import 'BaseModel.dart';

class HomeInfo extends BaseModel{
  String checkIn ,breakOut , breakIn , shortBreak,checkOutAt,
      lastCheckOutTime,lastCheckOutDate,diviceMacAddress;

  HomeInfo({
      this.checkIn,
      this.breakOut,
      this.breakIn,
      this.shortBreak,
      this.checkOutAt,
      this.lastCheckOutTime,
      this.lastCheckOutDate,
      this.diviceMacAddress});

  factory HomeInfo.fromJson(Map<String, dynamic> json) {
  var jsonDecoded = json['Attendance_Information'];
    return HomeInfo(
      checkIn:jsonDecoded['CheckIn'],
      breakOut : jsonDecoded['BreakOut'],
      breakIn: jsonDecoded['BreakIn'],
      shortBreak: jsonDecoded['ShortBreak'],
      checkOutAt: jsonDecoded['CheckOutAt'],
      lastCheckOutTime: jsonDecoded['LastCheckOutTime'],
      lastCheckOutDate: jsonDecoded['LastCheckOutDate'],
      diviceMacAddress: jsonDecoded['DiviceMacAddress'],
    );
  }
  Map<String, dynamic> toJson() => {
    'CheckIn': checkIn,
    'BreakOut': breakOut,
    'BreakIn': breakIn,
    'ShortBreak': shortBreak,
    'CheckOutAt' : checkOutAt ,
    'LastCheckOutTime' : lastCheckOutTime,
    'LastCheckOutDate' : lastCheckOutDate,
    'DiviceMacAddress' : diviceMacAddress,
  };


}