import 'dart:ui';
import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:first_project/utilities/color_manager.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class DataSource extends CalendarDataSource<Event> {
  DataSource(List<Event>? source) {
    appointments = source?.map(_generateRecurringAppointment).toList();
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].endTime;
  }

  @override
  String getSubject(int index) {
    return appointments![index].subject;
  }

  @override
  Color getColor(int index) {
    return appointments![index].color;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }

  // Updated convertAppointmentToObject to match the new Event class structure
  @override
  Event convertAppointmentToObject(Event customData, Appointment appointment) {
    return Event(
      id: customData.id,
      startDate: appointment.startTime.toUtc(),
      endDate: appointment.endTime.toUtc(),
      title: appointment.subject,
      groupId: customData.groupId,
      done: customData.done,
      recurrenceRule: customData.recurrenceRule,
      localization: customData.localization,
      allDay: appointment.isAllDay,
      note: customData.note,
      description: customData.description,
      eventColorIndex: customData.eventColorIndex,
      recipients: customData.recipients, // Keep the recipient list
      ownerID: customData.ownerID, // Include the ownerID (creator of the event)
    )..updateHistory = customData.updateHistory; // Copy the update history
  }

  // Setter for events to reset and notify listeners
  set events(List<Event>? newEvents) {
    appointments = newEvents?.map(_generateRecurringAppointment).toList();
    notifyListeners(CalendarDataSourceAction.reset, appointments!);
  }

  // Method to calculate the number of days between two dates, avoiding leap years
  int _calculateDaysBetweenDatesAvoidLeapYears(DateTime startDate, DateTime endDate) {
    final difference = endDate.difference(startDate).inDays;
    return difference;
  }

  // Helper method to convert day of the week to recurrence rule pattern
  String _convertDayToRRulePattern(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return 'MO';
      case 'tuesday':
        return 'TU';
      case 'wednesday':
        return 'WE';
      case 'thursday':
        return 'TH';
      case 'friday':
        return 'FR';
      case 'saturday':
        return 'SA';
      case 'sunday':
        return 'SU';
      default:
        return '';
    }
  }

  // Method to generate an appointment from an Event, including recurrence logic
  Appointment _generateRecurringAppointment(Event event) {
    final startDate = event.startDate;
    final endDate = event.endDate;
    final count = _calculateDaysBetweenDatesAvoidLeapYears(startDate, endDate);

    final recurrenceRule = event.recurrenceRule;
    final recurrenceType = recurrenceRule?.recurrenceType.name;
    final repeatInterval = recurrenceRule?.repeatInterval;
    final untilDate = recurrenceRule?.untilDate;

    // Extract and convert the days of the week for weekly recurrence
    final List<String> weeklyDays = [];
    final daysOfWeek = recurrenceRule?.daysOfWeek;
    if (daysOfWeek != null) {
      for (var day in daysOfWeek) {
        final abbreviation = _convertDayToRRulePattern(day.toString());
        weeklyDays.add(abbreviation);
      }
    }

    // Create an Appointment object for the calendar
    final appointment = Appointment(
      id: event.id,
      startTime: startDate.toUtc(),
      endTime: endDate.toUtc(),
      subject: event.description ?? "",
      color: ColorManager().getColor(event.eventColorIndex),
      isAllDay: event.allDay,
    );

    // Create recurrence rule string pattern based on the type
    String recurrenceRuleString = '';
    if (recurrenceType == 'Daily') {
      recurrenceRuleString = 'FREQ=DAILY;INTERVAL=$repeatInterval';
    } else if (recurrenceType == 'Weekly' && weeklyDays.isNotEmpty) {
      final daysOfWeekString = weeklyDays.join(',');
      recurrenceRuleString = 'FREQ=WEEKLY;INTERVAL=$repeatInterval;BYDAY=$daysOfWeekString';
    } else if (recurrenceType == 'Monthly') {
      final dayOfMonth = startDate.day;
      recurrenceRuleString = 'FREQ=MONTHLY;INTERVAL=$repeatInterval;BYMONTHDAY=$dayOfMonth';
    } else if (recurrenceType == 'Yearly') {
      final monthIndex = startDate.month;
      final dayOfMonth = startDate.day;
      recurrenceRuleString = 'FREQ=YEARLY;INTERVAL=$repeatInterval;BYMONTH=$monthIndex;BYMONTHDAY=$dayOfMonth';
    }

    // Add the "UNTIL" parameter if specified
    if (untilDate != null) {
      final untilDateString = DateFormat('yyyyMMddTHHmmss').format(untilDate.toUtc());
      recurrenceRuleString += ';UNTIL=$untilDateString';
    }

    // Add the "COUNT" parameter if count is greater than 0
    if (count > 0) {
      recurrenceRuleString += ';COUNT=$count';
    }

    appointment.recurrenceRule = recurrenceRuleString;
    print('This is the recurrence rule: ${appointment.recurrenceRule}');

    return appointment;
  }
}
