import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:first_project/c-frontend/b-group-section/screens/group_calendar-view/3-event/ui/c-event_actions_manager.dart';
import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'event_content_builder.dart';

class EventDisplayManager {
  EventActionManager? _eventActionManager; // ✅ Made nullable and non-final
  final EventContentBuilder _contentBuilder;

  EventDisplayManager(
    EventActionManager? eventActionManager, {
    required EventContentBuilder contentBuilder,
  })  : _eventActionManager = eventActionManager,
        _contentBuilder = contentBuilder;

  // ✅ New setter method to inject the action manager later
  void setEventActionManager(EventActionManager manager) {
    _eventActionManager = manager;
  }

  Widget buildEventDetails(Event event, BuildContext context, Color textColor,
      dynamic appointment, String userRole) {
    return GestureDetector(
      onTap: () {
        if (_eventActionManager == null) return;
        if (userRole == 'Administrator' || userRole == 'Co-Administrator') {
          _eventActionManager!.editEvent(event, context);
        }
      },
      child: Dismissible(
        key: Key(appointment.id),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          if (_eventActionManager == null) return false;
          if (userRole == 'Administrator' || userRole == 'Co-Administrator') {
            final bool confirm =
                await _eventActionManager!.removeEvent(event, true);
            return confirm;
          } else {
            _showPermissionDeniedDialog(context);
            return false;
          }
        },
        child: _contentBuilder.buildEventContent(event, textColor),
      ),
    );
  }

  Widget buildFutureEventContent(String eventId, Color textColor,
      BuildContext context, dynamic appointment) {
    if (_eventActionManager == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<Event?>(
      future: _eventActionManager!.eventDataManager.fetchEvent(eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator.adaptive();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final Event? event = snapshot.data;
          if (event != null) {
            return buildEventDetails(
                event, context, textColor, appointment, '');
          } else {
            return Text(
              AppLocalizations.of(context)!.noEventsFoundForDate,
              style: TextStyle(fontSize: 16, color: textColor),
            );
          }
        }
      },
    );
  }

  Widget buildNonMonthViewEvent(Event event, CalendarAppointmentDetails details,
      Color textColor, BuildContext context) {
    return GestureDetector(
      onTap: () {
        _eventActionManager?.editEvent(event, context);
      },
      child: Container(
        width: details.bounds.width,
        height: details.bounds.height,
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: _contentBuilder.colorManager.getColor(event.eventColorIndex),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(2),
              child: Row(
                children: [
                  Text(
                    '${DateFormat.jm().format(event.startDate)} -',
                    style: TextStyle(fontSize: 12, color: textColor),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${DateFormat.jm().format(event.endDate)}',
                    style: TextStyle(fontSize: 12, color: textColor),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.event_available_rounded,
                  size: 15,
                  color: _contentBuilder.colorManager
                      .getColor(event.eventColorIndex),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    event.title,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textColor),
                  ),
                ),
              ],
            ),
            if (event.description != null && event.description!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  event.description!,
                  style: TextStyle(
                      fontSize: 13,
                      color: textColor,
                      overflow: TextOverflow.ellipsis),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.permissionDenied),
          content: Text(AppLocalizations.of(context)!.permissionDeniedInf),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
