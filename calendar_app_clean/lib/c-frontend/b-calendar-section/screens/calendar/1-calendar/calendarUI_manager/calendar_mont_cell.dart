import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:first_project/c-frontend/c-event-section/utils/color_manager.dart'; // make sure this is imported
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

Widget buildMonthCell({
  required BuildContext context,
  required MonthCellDetails details,
  required DateTime? selectedDate,
  required bool isDarkMode,
  required List<Event> events,
}) {
  final isSelected = selectedDate != null &&
      selectedDate.year == details.date.year &&
      selectedDate.month == details.date.month &&
      selectedDate.day == details.date.day;

  final eventsForDay = events
      .where((e) =>
          e.startDate.year == details.date.year &&
          e.startDate.month == details.date.month &&
          e.startDate.day == details.date.day)
      .toList();

  final cellColor = isSelected
      ? (isDarkMode ? Colors.blue[700] : Colors.blue[300])
      : Colors.transparent;
  return Container(
    margin: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      color: cellColor!.withOpacity(0.6),
      borderRadius: BorderRadius.circular(8),
      boxShadow: isSelected
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                spreadRadius: 1,
              )
            ]
          : null,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          details.date.day.toString(),
          style: GoogleFonts.poppins(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        if (eventsForDay.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              children: List.generate(
                eventsForDay.length.clamp(0, 3),
                (index) {
                  final event = eventsForDay[index];
                  final color = (event.eventColorIndex >= 0 &&
                          event.eventColorIndex <
                              ColorManager.eventColors.length)
                      ? ColorManager.eventColors[event.eventColorIndex]
                      : Colors.grey; // fallback for invalid index

                  return Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    ),
  ).animate().scale(duration: 200.ms, curve: Curves.easeInOut);
}
