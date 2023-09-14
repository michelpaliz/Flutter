import 'package:first_project/enums/days_week.dart';

class RecurrenceRule {
  final String name;
  final DayOfWeek? dayOfWeek;
  final int? dayOfMonth;
  final int? month;

  const RecurrenceRule.daily()
      : name = 'Daily',
        dayOfWeek = null,
        dayOfMonth = null,
        month = null;

  const RecurrenceRule.weekly(this.dayOfWeek)
      : name = 'Weekly',
        dayOfMonth = null,
        month = null;

  const RecurrenceRule.monthly(this.dayOfMonth)
      : name = 'Monthly',
        dayOfWeek = null,
        month = null;

  const RecurrenceRule.yearly(this.month, this.dayOfMonth)
      : name = 'Yearly',
        dayOfWeek = null;


  static RecurrenceRule? fromString(String ruleString) {
    switch (ruleString) {
      case 'daily':
        return RecurrenceRule.daily();
      case 'weekly':
        return RecurrenceRule.weekly(null); // Pass the appropriate DayOfWeek value if needed
      case 'monthly':
        return RecurrenceRule.monthly(null); // Pass the appropriate dayOfMonth value if needed
      case 'yearly':
        return RecurrenceRule.yearly(null, null); // Pass the appropriate month and dayOfMonth values if needed
      default:
        return null; // Handle unrecognized ruleString
    }
  }
}