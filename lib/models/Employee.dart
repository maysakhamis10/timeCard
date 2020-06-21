class Employee{
  String  username;
  int employeeId ;
  String API_KEY;

  Employee({this.employeeId, this.username, this.API_KEY});
  factory Employee.fromJson(Map<String, dynamic> json) {


    return Employee(
      API_KEY:json['API_KEY'],
      employeeId : json['EmployeeId'],
      username: json['UserName'],
    );
}
}