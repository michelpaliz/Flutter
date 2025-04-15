import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:first_project/c-frontend/b-group-section/screens/group_calendar-view/3-event/ui/c-event_actions_manager.dart';
import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'event_content_builder.dart';

//  Primary Purpose

//     EventDisplayManager:
//         This class is focused on managing the UI-related logic for displaying and interacting with events in the app. It handles how event details are presented to the user, the interaction for editing or deleting events (e.g., showing confirmation dialogs), and the user permissions for these actions.
//         It interacts with the UI layer by building widgets and dealing with user gestures like taps, swipes, and dismiss actions.


// 2. Responsibilities

//     EventDisplayManager:
//         Builds the UI components for displaying event details (buildEventDetails, buildFutureEventContent).
//         Manages user interactions, such as tapping an event to edit it, swiping to delete it, and confirming event deletions (_showRemoveConfirmationDialog, _editEvent).
//         Deals with UI permission logic (checking user roles to allow editing or deleting).
//         Uses EventDataManager and EventActionManager to interact with the backend or perform actions but doesn’t handle the backend communication directly.


// 3. Interfacing with Other Components

//     EventDisplayManager:
//         Relies on EventDataManager to handle the actual data operations. For example, when a user confirms event removal, it calls removeGroupEvents from EventDataManager to handle the deletion of the event from the backend and local storage.
//         Interfaces with the UI framework by building widgets and responding to user input.
//         Calls methods like _editEvent to navigate to other parts of the app (e.g., the event editing screen).


class EventDisplayManager {
  final EventContentBuilder _contentBuilder;
  final EventActionManager _eventActionManager;

  EventDisplayManager(this._eventActionManager, 
      {required EventContentBuilder contentBuilder})
      : _contentBuilder = contentBuilder;

  // Builds the event details for user interaction (editing, deleting)
  Widget buildEventDetails(Event event, BuildContext context, Color textColor,
      dynamic appointment, String userRole) {
    return GestureDetector(
      onTap: () {
        // Allow only Administrator or Co-Administrator to edit the event
        if (userRole == 'Administrator' || userRole == 'Co-Administrator') {
          _eventActionManager.editEvent(event, context); // Use EventActionManager to edit
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
          // Allow only Administrator or Co-Administrator to delete the event
          if (userRole == 'Administrator' || userRole == 'Co-Administrator') {
            final bool confirm =
                await _eventActionManager.removeEvent(event, true); // Use EventActionManager for removal
            return confirm;
          } else {
            _showPermissionDeniedDialog(context);
            return false;
          }
        },
        onDismissed: (direction) {
          // Event was dismissed, no further action needed since EventActionManager handled removal
        },
        child: _contentBuilder.buildEventContent(event, textColor),
      ),
    );
  }

  // Fetch and display future events asynchronously
  Widget buildFutureEventContent(String eventId, Color textColor,
      BuildContext context, dynamic appointment) {
    return FutureBuilder<Event?>(
      future: _eventActionManager.eventDataManager.fetchEvent(eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator.adaptive();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final Event? event = snapshot.data;
          if (event != null) {
            return buildEventDetails(event, context, textColor, appointment,
                ''); // Pass appropriate userRole if available
          } else {
            return Container(
              child: Text(
                AppLocalizations.of(context)!.noEventsFoundForDate,
                style: TextStyle(fontSize: 16, color: textColor),
              ),
            );
          }
        }
      },
    );
  }

  // Builds non-month-view event details (for timeline views)
  Widget buildNonMonthViewEvent(Event event, CalendarAppointmentDetails details,
      Color textColor, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle event editing if necessary
        _eventActionManager.editEvent(event, context);
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
            // Display event time and title
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
            // Display event description if available
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

  

  // Show permission denied dialog
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
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
