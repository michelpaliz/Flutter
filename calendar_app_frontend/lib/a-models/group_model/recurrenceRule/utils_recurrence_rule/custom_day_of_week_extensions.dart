import 'package:hexora/a-models/group_model/recurrenceRule/utils_recurrence_rule/custom_day_week.dart';

extension CustomDayOfWeekRRuleExtension on CustomDayOfWeek {
  String toRRuleDay() {
    return CustomDayOfWeek.getPattern(name);
  }
}
