import 'package:flutter/material.dart';

import 'file:///D:/Hadeer_Mohamed/Flutter_Projects/timeCard/lib/resources/strings.dart';

class LayoutUtils {
  static TextDirection getLayoutDirection() {
    return english ? TextDirection.ltr : TextDirection.rtl;
  }

  static Widget wrapWithtinLayoutDirection(Widget widget) {
    return new Directionality(
        textDirection: getLayoutDirection(), child: widget);
  }

  static EdgeInsetsGeometry marPad(
      double top, double bottom, double start, double end) {
    return new EdgeInsets.fromLTRB(
        english ? start : end, top, english ? end : start, bottom);
  }
}
