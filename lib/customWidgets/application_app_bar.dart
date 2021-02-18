import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timecarditg/resources/colors.dart';

class ApplicationAppBar extends StatelessWidget {
  final String title;
  final List<Widget> actions;

  const ApplicationAppBar({Key key, this.title, this.actions})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: application_color,
      title: Text(title,
          style: GoogleFonts.poppins(color: white_color, fontSize: 18.0)),
      actions: actions != null ? actions : [],
    );
  }
}
