import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timecarditg/resources/colors.dart';

class CircularStateContainer extends StatelessWidget {
  final String name;
  final Color color;

  const CircularStateContainer({Key key, this.name, this.color})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: name.length * 11.toDouble(),
      height: 25,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Center(
          child: Text(
        name,
        style: GoogleFonts.poppins(
            color: white_color, fontSize: 13.0, fontWeight: FontWeight.w600),
      )),
    );
  }
}
