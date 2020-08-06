import 'dart:math';

import 'package:flutter/material.dart';

class CircleProgress extends CustomPainter{
  double currentProgress ;

  CircleProgress(this.currentProgress);

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
  Paint outerCircle = Paint()
      ..strokeWidth=4
    ..color = Colors.black26
      ..style = PaintingStyle.stroke;
  Paint completeArc = Paint()
  ..strokeWidth =4
  .. style = PaintingStyle.stroke
    ..color=Colors.blue
   .. strokeCap= StrokeCap.round;
  Offset center =Offset(size.width/2, size.height/2);
  double radius = min(size.width/2 , size.height/2);
  double angel = (currentProgress/100)*pi*2;
  canvas.drawCircle(center, radius, outerCircle);
  canvas.drawArc(Rect.fromCircle(center: center,radius: radius), -pi/2, angel, false, completeArc);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }

}