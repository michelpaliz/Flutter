import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

Color getTextColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;

Color getBackgroundColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]!
        : Colors.white;

BoxDecoration buildContainerDecoration(Color backgroundColor) => BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: backgroundColor,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 2,
          offset: Offset(0, 4),
        ),
      ],
    );

CalendarHeaderStyle buildHeaderStyle(double fontSize, Color textColor) =>
    CalendarHeaderStyle(
      textAlign: TextAlign.center,
      backgroundColor: Colors.transparent,
      textStyle: GoogleFonts.poppins(
        fontSize: fontSize * 1.2,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );

ViewHeaderStyle buildViewHeaderStyle(
        double fontSize, Color textColor, bool isDarkMode) =>
    ViewHeaderStyle(
      backgroundColor: isDarkMode ? Colors.grey[850] : Colors.grey[100],
      dateTextStyle: GoogleFonts.poppins(fontSize: fontSize, color: textColor),
      dayTextStyle: GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );

ScheduleViewSettings buildScheduleSettings(
        double fontSize, Color backgroundColor) =>
    ScheduleViewSettings(
      appointmentItemHeight: 80,
      monthHeaderSettings: MonthHeaderSettings(
        monthFormat: 'MMMM yyyy',
        height: 60,
        textAlign: TextAlign.left,
        backgroundColor: backgroundColor,
        monthTextStyle: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );

MonthViewSettings buildMonthSettings() => MonthViewSettings(
      showAgenda: true,
      agendaItemHeight: 80,
      dayFormat: 'EEE',
      appointmentDisplayMode: MonthAppointmentDisplayMode.none,
      appointmentDisplayCount: 4,
      showTrailingAndLeadingDates: false,
      navigationDirection: MonthNavigationDirection.vertical,
    );
