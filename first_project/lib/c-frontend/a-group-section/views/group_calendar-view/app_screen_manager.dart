import 'package:flutter/material.dart';

class AppScreenManager {
  double screenWidth = 0.0;
  double calendarHeight = 700;

  void setScreenWidthAndCalendarHeight(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    
    // Calculate a more dynamic height based on screen dimensions
    if (screenWidth < 600) {
      calendarHeight = screenHeight * 0.8; // For smaller screens, take 80% of screen height
    } else {
      calendarHeight = screenHeight * 0.85; // For larger screens, take 85% of screen height
    }
  }
}
