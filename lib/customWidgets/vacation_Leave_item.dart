import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timecarditg/customWidgets/circular_state_container.dart';
import 'package:timecarditg/models/leave_model.dart';
import 'package:timecarditg/models/vacation_model.dart';
import 'package:timecarditg/resources/colors.dart';
import 'package:timecarditg/resources/strings.dart';

class VacationLeaveItem extends StatelessWidget {
  final Object model;

  const VacationLeaveItem({Key key, this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LeaveModel leaveModel;
    VacationModel vacationModel;
    if (model is LeaveModel) {
      leaveModel = model;
    } else if (model is VacationModel) {
      vacationModel = model;
    }
    return Container(
      color: white_color,
      height: 250,
      margin: EdgeInsets.all(10),
      child: Card(
          elevation: 2,
          child: vacationModel != null
              ? Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildChild(
                        date_title,
                        vacationModel.date,
                        vacationModel.state,
                        vacationModel.dateIcon,
                        vacationModel.color),
                    buildChild(type_title, vacationModel.type,
                        vacationModel.state, vacationModel.typeIcon, null),
                    buildChild(
                        date_of_request_title,
                        vacationModel.dateOfRequest,
                        vacationModel.state,
                        vacationModel.dateOfRequestIcon,
                        null),
                  ],
                )
              : leaveModel != null
                  ? Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildChild(
                            date_title,
                            leaveModel.date,
                            leaveModel.state,
                            leaveModel.dateIcon,
                            leaveModel.color),
                        buildChild(
                            time_title,
                            leaveModel.from + "         " + leaveModel.to,
                            leaveModel.state,
                            leaveModel.timerIcon,
                            null),
                        buildChild(type_title, leaveModel.type,
                            leaveModel.state, leaveModel.typeIcon, null),
                        buildChild(
                            date_of_request_title,
                            leaveModel.dateOfRequest,
                            leaveModel.state,
                            leaveModel.dateOfRequestIcon,
                            null),
                      ],
                    )
                  : Container()),
    );
  }

  buildChild(String title, String description, String state, String icon,
      Color stateColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildColumn(title, description, icon),
          stateColor != null
              ? buildStateContainer(state, stateColor)
              : Container()
        ],
      ),
    );
  }

  buildStateContainer(String state, Color stateColor) {
    return CircularStateContainer(
      name: state,
      color: stateColor,
    );
  }

  buildColumn(
    String title,
    String description,
    String icon,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(icon),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: application_color,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                        color: light_grey_color, fontSize: 13.0),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
