import 'package:flutter/material.dart';
import 'package:timecarditg/Screens/vacation_and_leaves_screen.dart';
import 'package:timecarditg/customWidgets/vacation_Leave_item.dart';
import 'package:timecarditg/models/leave_model.dart';
import 'package:timecarditg/models/refine_model.dart';
import 'package:timecarditg/resources/colors.dart';
import 'package:timecarditg/resources/strings.dart';

class LeavesScreen extends VacationAndLeavesScreenCommon {
  LeavesScreen(bool isVacation) : super(isVacation);

  @override
  State<StatefulWidget> createState() => LeavesState();
}

class LeavesState extends VacationAndLeavesState<LeavesScreen> {
  @override
  buildMyList() {
    return Expanded(
      child: StreamBuilder<RefineModel>(
          stream: refineSubject.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return ListView(
                  shrinkWrap: true,
                  children: LeaveModel.getList()
                      .where((element) =>
                          snapshot.data.name == all_state ||
                          element.state == snapshot.data.name)
                      .toList()
                      .map<Widget>((e) => buildListItem(e))
                      .toList());
            } else {
              return Center(
                child: CircularProgressIndicator(
                  backgroundColor: application_color,
                ),
              );
            }
          }),
    );
  }

  buildListItem(LeaveModel myModel) {
    return VacationLeaveItem(
      model: myModel,
    );
  }
}
