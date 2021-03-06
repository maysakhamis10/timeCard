import 'package:flutter/material.dart';

Widget appBarMain(BuildContext context) {
  return AppBar(
    title: Image.asset('assets/images/logo.png', height: 40,),

  );
}

InputDecoration customInputDecoration(String hintText) {
  return InputDecoration(
    prefixIcon: Icon(Icons.lock,color: Colors.blue[300],),
    labelText: hintText,
    labelStyle: TextStyle(color: Colors.blue,letterSpacing: 1.0),
//    focusedBorder: UnderlineInputBorder(
//        borderSide: BorderSide(
//            color: Colors.black
//        )
//    ),
    border: InputBorder.none,
//    enabledBorder: UnderlineInputBorder(
//        borderSide: BorderSide(
//          color: Colors.black,
//
//        )
//    ),
  );
}
TextStyle simpleTextStyle (){
  return TextStyle( color:  Colors.white , fontSize: 16);

}TextStyle  mediumTextStyle(){
  return TextStyle( color:  Colors.white , fontSize: 17);
}