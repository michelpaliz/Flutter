import 'package:rrule/rrule.dart' as rrule;

void main() {
  final rule = rrule.RecurrenceRule.fromString(
    'FREQ=DAILY;INTERVAL=1',
    dtStart: DateTime.utc(2025, 1, 1),
  );

  final dates = rule.getInstances(
    start: DateTime.utc(2025, 1, 1),
    before: DateTime.utc(2025, 1, 5),
  );

  print(dates.toList());
}

