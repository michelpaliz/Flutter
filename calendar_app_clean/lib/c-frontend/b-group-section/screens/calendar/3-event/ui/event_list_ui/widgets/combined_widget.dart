import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:first_project/l10n/AppLocalitationMethod.dart';
import 'package:flutter/material.dart';

class EventDateTimeRow extends StatelessWidget {
  final Event event;
  final Color textColor;

  const EventDateTimeRow({
    Key? key,
    required this.event,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizationsMethods.of(context)!;
    final startDate = loc.formatDate(event.startDate);
    final startTime = loc.formatHours(event.startDate);
    final endDate = loc.formatDate(event.endDate);
    final endTime = loc.formatHours(event.endDate);

    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
      ),
      child: Text(
        '$startDate ( $startTime ) / $endDate ( $endTime )',
        style: TextStyle(fontSize: 8, color: textColor),
        maxLines: 2, // ← only one line
        overflow: TextOverflow.ellipsis, // ← show “…” if it overflows
        softWrap: false, // ← don’t wrap at all
      ),
    );
  }
}
