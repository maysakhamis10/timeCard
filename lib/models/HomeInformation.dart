class HomeInfo{
  String CheckIn ,BreakOut , BreakIn , ShortBreak,CheckOutAt, LastCheckOutTime,LastCheckOutDate,DiviceMacAddress;

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

    var jsonDecoded =json['Attendance_Information'];

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
}