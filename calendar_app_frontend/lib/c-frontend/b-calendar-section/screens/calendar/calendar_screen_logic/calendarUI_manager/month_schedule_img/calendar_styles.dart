import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

Widget buildScheduleMonthHeader(ScheduleViewMonthHeaderDetails details) {
  final imageAsset = _getImageForMonth(details.date.month);

  return Container(
    height: 100,
    width: double.infinity,
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage(imageAsset),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          Colors.black.withOpacity(0.4),
          BlendMode.darken,
        ),
      ),
    ),
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Text(
      _getFormattedMonth(details.date),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

String _getImageForMonth(int month) {
  const images = {
    1: 'assets/images/months/january.png',
    2: 'assets/images/months/february.png',
    3: 'assets/images/months/march.png',
    4: 'assets/images/months/april.png',
    5: 'assets/images/months/may.png',
    6: 'assets/images/months/june.png',
    7: 'assets/images/months/july.png',
    8: 'assets/images/months/august.png',
    9: 'assets/images/months/september.png',
    10: 'assets/images/months/october.png',
    11: 'assets/images/months/november.png',
    12: 'assets/images/months/december.png',
  };
  return images[month] ?? 'assets/images/default.png';
}

String _getFormattedMonth(DateTime date) {
  const monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  return '${monthNames[date.month - 1]} ${date.year}';
}
