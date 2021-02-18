import 'package:flutter/material.dart';
import 'package:timecarditg/resources/colors.dart';
import 'package:timecarditg/resources/images.dart';

class VacationModel {
  String date,
      type,
      dateOfRequest,
      state,
      dateIcon,
      typeIcon,
      dateOfRequestIcon;
  Color color;
  VacationModel(
      {this.date,
      this.type,
      this.dateOfRequest,
      this.state,
      this.dateIcon,
      this.typeIcon,
      this.dateOfRequestIcon,
      this.color});

  static List<VacationModel> getList() {
    List<VacationModel> data = new List();
    data.add(VacationModel(
        date: "2/2/2021 - 2/2/2021",
        type: "Personal Vacation",
        dateOfRequest: "2/2/2021 - 08:00:00 AM",
        state: "Accepted",
        dateIcon: date_image,
        typeIcon: type_image,
        dateOfRequestIcon: date_of_request_image,
        color: green_color));
    data.add(VacationModel(
        date: "2/2/2021 - 2/2/2021",
        type: "Personal Vacation",
        dateOfRequest: "2/2/2021 - 08:00:00 AM",
        state: "Pending",
        dateIcon: date_image,
        typeIcon: type_image,
        dateOfRequestIcon: date_of_request_image,
        color: orange_color));
    data.add(VacationModel(
        date: "2/2/2021 - 2/2/2021",
        type: "Personal Vacation",
        dateOfRequest: "2/2/2021 - 08:00:00 AM",
        state: "Rejected",
        dateIcon: date_image,
        typeIcon: type_image,
        dateOfRequestIcon: date_of_request_image,
        color: red_color));
    return data;
  }
}
