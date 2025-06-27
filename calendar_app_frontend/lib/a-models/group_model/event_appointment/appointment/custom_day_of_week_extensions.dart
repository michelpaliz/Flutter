import 'package:calendar_app_frontend/a-models/group_model/event_appointment/appointment/custom_day_week.dart';

extension CustomDayOfWeekRRuleExtension on CustomDayOfWeek {
  String toRRuleDay() {
    return CustomDayOfWeek.getPattern(name);
  }
}
