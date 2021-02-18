import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timecarditg/base/base_stateful_widget.dart';
import 'package:timecarditg/customWidgets/application_app_bar.dart';
import 'package:timecarditg/resources/colors.dart';
import 'package:timecarditg/resources/images.dart';
import 'package:timecarditg/resources/strings.dart';

abstract class RequestVacationAndLeaveScreen extends BaseStatefulWidget {
  final bool requestVacation;

  RequestVacationAndLeaveScreen(this.requestVacation);
}

abstract class RequestVacationAndLeaveState<
    T extends RequestVacationAndLeaveScreen> extends BaseState<T> {
  bool requestVacation = false;

  @override
  void initState() {
    requestVacation = widget.requestVacation;
    super.initState();
  }

  @override
  Widget getAppbar() {
    return ApplicationAppBar(
      title: getTitle(),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Center(
            child: GestureDetector(
              onTap: () {
                submitRequest();
              },
              child: Text(submit,
                  style:
                      GoogleFonts.poppins(color: white_color, fontSize: 16.0)),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget getBody(BuildContext context) {
    return Container(
      color: white_color,
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 2,
      padding: EdgeInsets.all(
        20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: !requestVacation
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildRow(
              type_image, reason_text, "", true, true, 20.0, onDropDownClick),
          buildRow(date_image, date_title, "2/2/2021", !requestVacation, false,
              !requestVacation ? 0.0 : 50.0, datePickerShow),
          buildRow(
              requestVacation ? date_image : timer_image,
              requestVacation ? from_date_text : from_time_text,
              "11:00:00 AM",
              true,
              false,
              !requestVacation ? 0.0 : 50.0,
              requestVacation ? datePickerShow : fromTimePicker),
          buildRow(
              requestVacation ? date_image : timer_image,
              requestVacation ? to_date_text : to_time_text,
              "03:00:00 pM",
              true,
              false,
              !requestVacation ? 0.0 : 50.0,
              requestVacation ? datePickerShow : toTimePicker),
        ],
      ),
    );
  }

  getTitle() {
    return requestVacation ? request_vacation : request_leave;
  }

  // buildResionRow() {
  //   return Row(
  //     mainAxisSize: MainAxisSize.max,
  //     mainAxisAlignment: MainAxisAlignment.spaceAround,
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       buildIcon(type_image),
  //       buildColumn(),
  //     ],
  //   );
  // }

  buildIcon(String img) {
    return Image.asset(img);
  }

  // buildColumn() {
  //   return Expanded(
  //       child: Padding(
  //     padding: const EdgeInsetsDirectional.only(start: 10.0),
  //     child: Column(
  //       mainAxisSize: MainAxisSize.max,
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           mainAxisSize: MainAxisSize.max,
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: [
  //             Text(
  //               reason_text,
  //               style: GoogleFonts.poppins(
  //                   color: application_color, fontSize: 15.0),
  //             ),
  //             Text(
  //               astrix_text,
  //               style: GoogleFonts.poppins(color: red_color, fontSize: 15.0),
  //             ),
  //           ],
  //         ),
  //         DropdownButton(
  //           underline: Container(),
  //           isDense: false,
  //           isExpanded: true,
  //           // value: "d",
  //           icon: Icon(
  //             Icons.keyboard_arrow_down,
  //             color: application_color,
  //           ),
  //           items: [
  //             DropdownMenuItem(child: Text("g")),
  //             DropdownMenuItem(child: Text("g")),
  //             DropdownMenuItem(child: Text("g")),
  //             DropdownMenuItem(child: Text("g")),
  //           ],
  //         ),
  //         buildDivider()
  //       ],
  //     ),
  //   ));
  // }

  buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Divider(
        color: grey_color,
        height: 1,
      ),
    );
  }

  int _value = 0;
  buildRow(String icon, String title, String value, bool opacity,
      bool buildDropDown, double padding, Function onclick) {
    return opacity
        ? Padding(
            padding: EdgeInsets.only(top: padding),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildIcon(icon),
                buildColumn(
                    title, value, opacity, buildDropDown, padding, onclick)
              ],
            ),
          )
        : Container(
            width: 0,
            height: 0,
          );
  }

  void submitRequest();

  buildColumn(String title, String value, bool opacity, bool buildDropDown,
      double padding, Function onClick) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                          color: application_color, fontSize: 15.0),
                    ),
                    Text(
                      astrix_text,
                      style:
                          GoogleFonts.poppins(color: red_color, fontSize: 15.0),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.poppins(
                          color: light_grey_color, fontSize: 13.0),
                    ),
                    Opacity(
                      opacity: buildDropDown ? 0.0 : 1.0,
                      child: GestureDetector(
                        onTap: onClick,
                        child: Icon(
                          Icons.chevron_right,
                          color: application_color,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
            buildDropDown
                ? DropdownButton(
                    underline: Container(),
                    isDense: false,
                    isExpanded: true,
                    value: _value,
                    hint: Text(
                      select_reasons_text,
                      style: GoogleFonts.poppins(
                          color: light_grey_color, fontSize: 13.0),
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: application_color,
                    ),
                    items: _value == 0
                        ? []
                        : [
                            DropdownMenuItem(
                              child: Text(""),
                              value: 1,
                            ),
                            DropdownMenuItem(
                              child: Text("First Item"),
                              value: 2,
                            ),
                            DropdownMenuItem(
                              child: Text("Second Item"),
                              value: 3,
                            ),
                            DropdownMenuItem(
                                child: Text("Third Item"), value: 4),
                            DropdownMenuItem(
                                child: Text("Fourth Item"), value: 5)
                          ],
                    onChanged: (value) {
                      setState(() {
                        _value = value;
                        onClick();
                      });
                    })
                : Container(),
            buildDivider()
          ],
        ),
      ),
    );
  }

  onDropDownClick() {
    print("onDropDownClick");
  }

  datePickerShow() async {
    DateTime selectedDate = DateTime.now();
    print("datePickerShow");
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime.now().subtract(Duration(days: 0)),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  fromTimePicker() async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute),
    );
  }

  toTimePicker() async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute),
    );
  }
}
