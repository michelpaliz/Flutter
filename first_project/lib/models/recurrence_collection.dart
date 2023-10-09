import 'package:first_project/models/recurrence_rule.dart';

class RecurrenceCollection {
  final RecurrenceRule rule;
  final DateTime dtstart;

  RecurrenceCollection({
    required this.rule,
    required this.dtstart,
  });
}
