import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/utils/color_manager.dart';
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

  // ✅ UPDATED: Include any event that overlaps this day
  final cellStart =
      DateTime(details.date.year, details.date.month, details.date.day);
  final cellEnd = cellStart.add(const Duration(days: 1));

  final eventsForDay = events
      .where(
        (e) => e.startDate.isBefore(cellEnd) && e.endDate.isAfter(cellStart),
      )
      .toList();

  final textColor =
      Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final cellColor = isSelected
      ? (isDarkMode ? Colors.blue[700] : Colors.blue[300])
      : Colors.transparent;

  return LayoutBuilder(
    builder: (context, constraints) {
      final isCompact = constraints.maxHeight < 56;

      return Container(
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: cellColor?.withOpacity(0.6),
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 0.5,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isCompact && eventsForDay.isNotEmpty)
              Text(
                '${eventsForDay.length} Event${eventsForDay.length > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 10,
                  color:
                      isSelected ? Colors.white70 : textColor.withOpacity(0.6),
                  fontWeight: FontWeight.w400,
                ),
              ),
            Text(
              details.date.day.toString(),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : textColor,
              ),
            ),
            if (eventsForDay.isNotEmpty)
              SizedBox(
                height: 10,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 2,
                  runSpacing: 1,
                  children: eventsForDay.take(3).map((event) {
                    final color = (event.eventColorIndex >= 0 &&
                            event.eventColorIndex <
                                ColorManager.eventColors.length)
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
        ),
      ).animate().scale(duration: 200.ms, curve: Curves.easeInOut);
    },
  );
}
