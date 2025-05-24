import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:first_project/l10n/AppLocalitationMethod.dart';
import 'package:flutter/material.dart';

class EventTimeRow extends StatelessWidget {
  final Event event;
  final Color textColor;

  const EventTimeRow({
    Key? key,
    required this.event,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        children: [
          Text(
            AppLocalizationsMethods.of(context)!.formatHours(event.startDate),
            style: TextStyle(fontSize: 14, color: textColor),
          ),
          const Text(" – "),
          Text(
            AppLocalizationsMethods.of(context)!.formatHours(event.endDate),
            style: TextStyle(fontSize: 14, color: textColor),
          ),
        ],
      ),
    );
  }
}
