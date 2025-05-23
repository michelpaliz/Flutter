import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:first_project/c-frontend/c-event-section/screens/event_screen/event_detail.dart';
import 'package:first_project/c-frontend/c-event-section/utils/color_manager.dart';
import 'package:first_project/l10n/AppLocalitationMethod.dart';
import 'package:flutter/material.dart';

class EventContentBuilder {
  final ColorManager colorManager;

  EventContentBuilder({required this.colorManager});

  /// Builds the detailed event content used in full views
  Widget buildDefaultEventContent(
      Event event, Color textColor, BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            width: 6,
            color: colorManager.getColor(event.eventColorIndex),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(2, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildEventDateRow(event, textColor, context),
          const SizedBox(height: 5),
          buildEventTimeRow(event, textColor, context),
          const SizedBox(height: 8),
          buildEventTitleRow(event, textColor, context),
          if (event.description != null && event.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 16),
              child: Text(
                event.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(fontSize: 13, color: textColor.withOpacity(0.8)),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildEventDateRow(Event event, Color textColor, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      child: Row(
        children: [
          Text(
            AppLocalizationsMethods.of(context)?.formatDate(event.startDate) ??
                '',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
          ),
          const Text("  -  "),
          Text(
            AppLocalizationsMethods.of(context)?.formatDate(event.endDate) ??
                '',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget buildEventTimeRow(Event event, Color textColor, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      child: Row(
        children: [
          Text(
            AppLocalizationsMethods.of(context)!.formatHours(event.startDate) +
                " - ",
            style: TextStyle(fontSize: 14, color: textColor),
          ),
          const SizedBox(width: 6),
          Text(
            AppLocalizationsMethods.of(context)!.formatHours(event.endDate),
            style: TextStyle(fontSize: 14, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget buildEventTitleRow(
      Event event, Color textColor, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      child: Row(
        children: [
          Icon(Icons.event,
              size: 18, color: colorManager.getColor(event.eventColorIndex)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              event.title,
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => EventDetail(event: event)));
            },
            child: Icon(Icons.more_vert,
                size: 20, color: colorManager.getColor(event.eventColorIndex)),
          ),
        ],
      ),
    );
  }

  /// Used in the calendar tiles (small version)
  Widget buildEventContent(Event event, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorManager.getColor(event.eventColorIndex).withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        event.title,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          overflow: TextOverflow.ellipsis,
        ),
        maxLines: 1,
      ),
    );
  }
}
