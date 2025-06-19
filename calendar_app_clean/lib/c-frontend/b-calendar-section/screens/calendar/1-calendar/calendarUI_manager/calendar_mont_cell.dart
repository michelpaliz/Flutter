import 'package:first_project/a-models/group_model/event/event.dart';
import 'package:first_project/c-frontend/c-event-section/utils/color_manager.dart'; // make sure this is imported
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

Widget buildMonthCell({
  required BuildContext context,
  required MonthCellDetails details,
  required DateTime? selectedDate,
  required List<Event> events,
}) {
  final isSelected = selectedDate != null &&
      selectedDate.year == details.date.year &&
      selectedDate.month == details.date.month &&
      selectedDate.day == details.date.day;

  final eventsForDay = events.where((e) =>
      e.startDate.year == details.date.year &&
      e.startDate.month == details.date.month &&
      e.startDate.day == details.date.day);

  final textColor =
      Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final cellColor = isSelected
      ? (isDarkMode ? Colors.blue[700] : Colors.blue[300])
      : Colors.transparent;

  return Container(
    margin: const EdgeInsets.all(1.5), // Reduced from 2
    constraints: const BoxConstraints(
      minHeight: 36, // Minimum height to prevent overflow
      maxHeight: 48, // Maximum height constraint
    ),
    decoration: BoxDecoration(
      color: cellColor?.withOpacity(0.6),
      borderRadius: BorderRadius.circular(6), // Slightly smaller radius
      boxShadow: isSelected
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4, // Reduced blur
                spreadRadius: 0.5, // Reduced spread
              )
            ]
          : null,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 👇 Add custom info above the day number
        if (eventsForDay.isNotEmpty)
          Text(
            '${eventsForDay.length} Event${eventsForDay.length > 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? Colors.white70 : textColor.withOpacity(0.6),
              fontWeight: FontWeight.w400,
            ),
          ),

        // 👇 Day number
        Text(
          details.date.day.toString(),
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : textColor,
          ),
        ),

        // 👇 Event indicators below day number
        if (eventsForDay.isNotEmpty) ...[
          const SizedBox(height: 2),
          SizedBox(
            height: 10,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 2,
              runSpacing: 1,
              children: eventsForDay.take(3).map((event) {
                final color = (event.eventColorIndex >= 0 &&
                        event.eventColorIndex < ColorManager.eventColors.length)
                    ? ColorManager.eventColors[event.eventColorIndex]
                    : Colors.grey;
                return Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.all(0.5),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 2,
                        spreadRadius: 0.3,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    ),
  ).animate().scale(duration: 200.ms, curve: Curves.easeInOut);
}
