import 'package:flutter/material.dart';
import 'package:timecarditg/Screens/request_vacation_leave_screen.dart';

class RequestVacationScreen extends RequestVacationAndLeaveScreen {
  RequestVacationScreen(bool requestVacation) : super(requestVacation);

  @override
  State<StatefulWidget> createState() => RequestVacationState();
}

class RequestVacationState
    extends RequestVacationAndLeaveState<RequestVacationScreen> {
  @override
  void submitRequest() {}
}
