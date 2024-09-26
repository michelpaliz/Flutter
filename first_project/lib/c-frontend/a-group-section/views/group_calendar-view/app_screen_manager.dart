import 'package:flutter/material.dart';

class AppScreenManager {
  double screenWidth = 0.0;
  double calendarHeight = 700;

  void setScreenWidthAndCalendarHeight(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    calendarHeight = screenWidth < 600 ? 650 : 700;
  }
}
