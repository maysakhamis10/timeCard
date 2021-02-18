import 'package:flutter/material.dart';
import 'package:timecarditg/resources/colors.dart';
import 'package:timecarditg/resources/images.dart';

class LeaveModel {
  String date,
      type,
      dateOfRequest,
      state,
      dateIcon,
      typeIcon,
      dateOfRequestIcon,
      from,
      to,
      timerIcon;
  Color color;
  LeaveModel(
      {this.date,
      this.type,
      this.dateOfRequest,
      this.state,
      this.from,
      this.to,
      this.timerIcon,
      this.dateIcon,
      this.typeIcon,
      this.dateOfRequestIcon,
      this.color});

  static List<LeaveModel> getList() {
    List<LeaveModel> data = new List();
    data.add(LeaveModel(
        date: "2/2/2021 - 2/2/2021",
        type: "Personal Vacation",
        dateOfRequest: "2/2/2021 - 08:00:00 AM",
        state: "Accepted",
        from: "From 11:00:00 AM",
        to: "To 02:00:00 PM",
        timerIcon: timer_image,
        dateIcon: date_image,
        typeIcon: type_image,
        dateOfRequestIcon: date_of_request_image,
        color: green_color));
    data.add(LeaveModel(
        date: "2/2/2021 - 2/2/2021",
        type: "Personal Vacation",
        dateOfRequest: "2/2/2021 - 08:00:00 AM",
        state: "Pending",
        from: "From 11:00:00 AM",
        to: "To 02:00:00 PM",
        timerIcon: timer_image,
        dateIcon: date_image,
        typeIcon: type_image,
        dateOfRequestIcon: date_of_request_image,
        color: orange_color));
    data.add(LeaveModel(
        date: "2/2/2021 - 2/2/2021",
        type: "Personal Vacation",
        dateOfRequest: "2/2/2021 - 08:00:00 AM",
        state: "Rejected",
        from: "From 11:00:00 AM",
        to: "To 02:00:00 PM",
        timerIcon: timer_image,
        dateIcon: date_image,
        typeIcon: type_image,
        dateOfRequestIcon: date_of_request_image,
        color: red_color));
    return data;
  }
}
