import 'package:first_project/c-frontend/c-event-section/screens/event_screen/event_detail.dart';
import 'package:first_project/l10n/AppLocalitationMethod.dart';
import 'package:flutter/material.dart';
import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:first_project/c-frontend/c-event-section/utils/color_manager.dart';

class EventContentBuilder {
  final ColorManager colorManager;

  EventContentBuilder({required this.colorManager});

  // Builds the default content for an event
  Widget buildDefaultEventContent(Event event, Color textColor, BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            width: 10,
            color: colorManager.getColor(event.eventColorIndex),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildEventDateRow(event, textColor, context),
          SizedBox(height: 3),
          buildEventTimeRow(event, textColor, context),
          SizedBox(height: 8),
          buildEventTitleRow(event, textColor, context),
        ],
      ),
    );
  }

  // Builds the event's date row
  Widget buildEventDateRow(Event event, Color textColor, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16),
      child: Row(
        children: [
          Text(
            AppLocalizationsMethods.of(context)?.formatDate(event.startDate) ?? '',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
          ),
          Text("  -  "),
          Text(
            AppLocalizationsMethods.of(context)?.formatDate(event.endDate) ?? '',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
          ),
        ],
      ),
    );
  }

  // Builds the event's time row
  Widget buildEventTimeRow(Event event, Color textColor, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16),
      child: Row(
        children: [
          Text(
            AppLocalizationsMethods.of(context)!.formatHours(event.startDate) + "   - ",
            style: TextStyle(fontSize: 15, color: textColor),
          ),
          SizedBox(width: 8),
          Text(
            AppLocalizationsMethods.of(context)!.formatHours(event.endDate),
            style: TextStyle(fontSize: 15, color: textColor),
          ),
        ],
      ),
    );
  }

  // Builds the event's title row
  Widget buildEventTitleRow(Event event, Color textColor, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16),
      child: Row(
        children: [
          Icon(Icons.event, size: 20, color: colorManager.getColor(event.eventColorIndex)),
          SizedBox(width: 7),
          Text(event.title, style: TextStyle(fontSize: 15, color: textColor)),
          SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return EventDetail(event: event);
              }));
            },
            child: Icon(Icons.more_rounded, size: 20, color: colorManager.getColor(event.eventColorIndex)),
          ),
        ],
      ),
    );
  }

  // Builds basic event content
  Widget buildEventContent(Event event, Color textColor) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorManager.getColor(event.eventColorIndex),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: TextStyle(
              color: textColor,
              fontSize: 9,
              overflow: TextOverflow.ellipsis,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
