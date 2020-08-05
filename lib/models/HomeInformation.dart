import 'BaseModel.dart';

class HomeInfo extends BaseModel{
  String CheckIn ,BreakOut , BreakIn , ShortBreak,CheckOutAt,
      LastCheckOutTime,LastCheckOutDate,DiviceMacAddress;

  HomeInfo({
      this.CheckIn,
      this.BreakOut,
      this.BreakIn,
      this.ShortBreak,
      this.CheckOutAt,
      this.LastCheckOutTime,
      this.LastCheckOutDate,
      this.DiviceMacAddress});

  factory HomeInfo.fromJson(Map<String, dynamic> json) {
  var jsonDecoded = json['Attendance_Information'];
    return HomeInfo(
      CheckIn:jsonDecoded['CheckIn'],
      BreakOut : jsonDecoded['BreakOut'],
      BreakIn: jsonDecoded['BreakIn'],
      ShortBreak: jsonDecoded['ShortBreak'],
      CheckOutAt: jsonDecoded['CheckOutAt'],
      LastCheckOutTime: jsonDecoded['LastCheckOutTime'],
      LastCheckOutDate: jsonDecoded['LastCheckOutDate'],
      DiviceMacAddress: jsonDecoded['DiviceMacAddress'],
    );
  }
  Map<String, dynamic> toJson() => {
    'CheckIn': CheckIn,
    'BreakOut': BreakOut,
    'BreakIn': BreakIn,
    'ShortBreak': ShortBreak,
    'CheckOutAt' : CheckOutAt ,
    'LastCheckOutTime' : LastCheckOutTime,
    'LastCheckOutDate' : LastCheckOutDate,
    'DiviceMacAddress' : DiviceMacAddress,
  };


}