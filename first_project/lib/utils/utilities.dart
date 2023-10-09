import 'dart:convert';

import 'package:first_project/costume_widgets/color_manager.dart';
import 'package:first_project/models/recurrence_rule.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_calendar/calendar.dart'; // Import the http package

class Utilities {


  static Future<List<String>> getAddressSuggestions(String pattern) async {
    final baseUrl = Uri.parse('https://nominatim.openstreetmap.org/search');
    final queryParameters = {
      'format': 'json',
      'q': pattern,
    };

    final response =
        await http.get(baseUrl.replace(queryParameters: queryParameters));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      final suggestions =
          data.map((item) => item['display_name'] as String).toList();
      return suggestions;
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  Appointment _getCalendarDataSource(String, id, String title, DateTime startDate, DateTime endDate, int colorIndex, RecurrenceRule? recurrenceRule) {
    late Appointment appointment; 

    // Iterate through each event
      // Check if the event has a recurrence rule
      if (recurrenceRule != null) {
        // Generate recurring appointments based on the recurrence rule
        final appointments = _generateRecurringAppointment(title, startDate, endDate, colorIndex, recurrenceRule);
        appointment = (appointments);
      } else {
        // If the event doesn't have a recurrence rule, add it as a single appointment
        appointment = (Appointment(
          id: id, // Assign a unique ID here
          startTime: startDate,
          endTime: endDate,
          subject: title,
          color: ColorManager().getColor(colorIndex),
        ));
      }
    

    return appointment;
  }

  Appointment _generateRecurringAppointment( String title, DateTime startDate, DateTime endDate, int colorIndex, RecurrenceRule recurrenceRule) {
    late final Appointment recurringAppointment;

    // Get the start date and end date from the event
    final startDateFetched = startDate;
    final endDateFetched = endDate;

    // Get the recurrence rule details
    final recurrenceRuleFetched = recurrenceRule;
    final repeatInterval = recurrenceRuleFetched.repeatInterval ??
        1; // Provide a default value of 1 if null
    final untilDate = recurrenceRuleFetched.untilDate;

    // Generate recurring appointments until the specified end date (if provided)
    DateTime currentStartDate = startDateFetched;
    while (untilDate == null || currentStartDate.isBefore(untilDate)) {
      recurringAppointment = (Appointment(
        startTime: currentStartDate,
        endTime: endDateFetched,
        subject: title,
        color: ColorManager().getColor(colorIndex),
      ));
      currentStartDate = currentStartDate.add(Duration(days: repeatInterval));
    }

    return recurringAppointment;
  }

  
}
