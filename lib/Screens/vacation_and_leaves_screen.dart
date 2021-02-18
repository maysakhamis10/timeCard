import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timecarditg/Screens/request_vacation_screen.dart';
import 'package:timecarditg/base/base_stateful_widget.dart';
import 'package:timecarditg/customWidgets/application_app_bar.dart';
import 'package:timecarditg/customWidgets/circular_state_container.dart';
import 'package:timecarditg/models/refine_model.dart';
import 'package:timecarditg/resources/colors.dart';
import 'package:timecarditg/resources/images.dart';
import 'package:timecarditg/resources/strings.dart';

abstract class VacationAndLeavesScreenCommon extends BaseStatefulWidget {
  final bool isVacation;

  VacationAndLeavesScreenCommon(this.isVacation);
}

abstract class VacationAndLeavesState<T extends VacationAndLeavesScreenCommon>
    extends BaseState<T> {
  bool isVacation;
  List<RefineModel> refineList = new List();
  BehaviorSubject<RefineModel> refineSubject =
      new BehaviorSubject<RefineModel>();

  @override
  void initState() {
    isVacation = widget.isVacation;
    initRefineList();
    super.initState();
  }

  @override
  void dispose() {
    refineSubject.close();

    super.dispose();
  }

  @override
  Widget getAppbar() {
    return ApplicationAppBar(
      title: getTitle(),
    );
  }

  @override
  Widget getBody(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildFilterContainer(),
          buildMyList(),
        ],
      ),
    );
  }

  @override
  buildFloatButton() {
    return FloatingActionButton(
      onPressed: navigateToRequestScreen,
      backgroundColor: application_color,
      child: Icon(
        Icons.add,
        color: white_color,
      ),
    );
  }

  getTitle() {
    return isVacation ? vacation_title : leaves_title;
  }

  buildFilterContainer() {
    return Card(
      elevation: 4,
      borderOnForeground: true,
      margin: EdgeInsets.only(bottom: 8),
      child: Container(
        height: 100,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildRefineRow(),
            buildFilterListRow(),
          ],
        ),
      ),
    );
  }

  buildMyList();

  buildRefineRow() {
    return Expanded(
      flex: 1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [refileTitle, refineIcon],
      ),
    );
  }

  Widget refileTitle = Expanded(
      flex: 4,
      child: Container(
        margin: EdgeInsetsDirectional.only(start: 15, end: 15),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                "From 1/12/2021",
                style: GoogleFonts.poppins(
                    color: light_grey_color, fontSize: 12.0),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                "To 1/12/2021",
                style: GoogleFonts.poppins(
                    color: light_grey_color, fontSize: 12.0),
              ),
            ),
          ],
        ),
      ));
  Widget refineIcon = Expanded(
      flex: 1,
      child: GestureDetector(onTap: () {}, child: Image.asset(refine_image)));

  buildFilterListRow() {
    return Expanded(
      flex: 1,
      child: StreamBuilder<RefineModel>(
          initialData: null,
          stream: refineSubject.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: refineList
                    .map<Widget>((refineItem) =>
                        buildRefineItem(refineItem, snapshot.data))
                    .toList(),
              );
            }
            return Container(
              color: Colors.yellow,
            );
          }),
    );
  }

  void initRefineList() {
    refineList.clear();
    refineList
        .add(RefineModel(all_state, false, application_color, grey_color));
    refineList.add(RefineModel(accept_state, false, green_color, grey_color));
    refineList.add(RefineModel(pending_state, false, orange_color, grey_color));
    refineList.add(RefineModel(reject_state, false, red_color, grey_color));
    refineSubject.sink
        .add(RefineModel(all_state, false, application_color, grey_color));
  }

  buildRefineItem(RefineModel refineItem, RefineModel snapShot) {
    return GestureDetector(
      onTap: () {
        refineSubject.sink.add(refineItem);
      },
      child: CircularStateContainer(
        name: refineItem.name,
        color: refineItem.name == snapShot.name
            ? refineItem.selectedColor
            : refineItem.unSelectedColor,
      ),
    );
  }

  void navigateToRequestScreen() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RequestVacationScreen(isVacation)));
  }
}
