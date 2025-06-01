import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:first_project/c-frontend/b-group-section/screens/group_calendar-view/3-event/actions/event_actions_manager.dart';
import 'package:first_project/c-frontend/b-group-section/screens/group_calendar-view/3-event/ui/event_list_ui/widgets/combined_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'event_content_builder.dart';
import 'event_title_row.dart';

class EventDisplayManager {
  EventActionManager? _actionManager;
  final EventContentBuilder _builder;

  EventDisplayManager(
    EventActionManager? actionMgr, {
    required EventContentBuilder builder,
  })  : _actionManager = actionMgr,
        _builder = builder;

  /// Injects the action manager once it's available.
  void setEventActionManager(EventActionManager mgr) {
    _actionManager = mgr;
  }

  /// Month‐cell / “detailed” pop-up version (with swipe-to-delete and tap-to-edit).
  Widget buildEventDetails(
    Event event,
    BuildContext context,
    Color textColor,
    dynamic appointment,
    String userRole,
  ) {
    final dateRow = EventDateTimeRow(event: event, textColor: textColor);

    final titleRow = EventTitleRow(
      event: event,
      textColor: textColor,
      colorManager: _builder.colorManager,
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Dismissible(
          key: Key(appointment.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (_) async {
            if (_actionManager == null ||
                !(userRole == 'Administrator' ||
                    userRole == 'Co-Administrator')) {
              return false;
            }
            return _actionManager!.removeEvent(event, true);
          },
          child: GestureDetector(
            onTap: () {
              if (_actionManager != null &&
                  (userRole == 'Administrator' ||
                      userRole == 'Co-Administrator')) {
                _actionManager!.editEvent(event, context);
              }
            },
            child: _builder.buildDefaultEventCard(
              dateRow: dateRow,
              titleRow: titleRow,
              description: event.description,
              cardColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// For “future” appointments where we only know the ID – loads & then renders details.
  Widget buildFutureEventContent(
    String eventId,
    Color textColor,
    BuildContext context,
    dynamic appointment,
  ) {
    if (_actionManager == null) return const SizedBox.shrink();

    return FutureBuilder<Event?>(
      future: _actionManager!.eventDataManager.fetchEvent(eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.data != null) {
          // pass empty userRole here or derive from context if you prefer
          return buildEventDetails(
            snapshot.data!,
            context,
            textColor,
            appointment,
            '',
          );
        } else {
          return Text(
            AppLocalizations.of(context)!.noEventsFoundForDate,
            style: TextStyle(fontSize: 16, color: textColor),
          );
        }
      },
    );
  }

  /// Agenda/day/week views (non‐month), simpler styling without swipe.
  Widget buildNonMonthViewEvent(
    Event event,
    CalendarAppointmentDetails details,
    Color textColor,
    BuildContext context,
  ) {
    // final dateRow = EventDateRow(event: event, textColor: textColor);
    // final timeRow = EventTimeRow(event: event, textColor: textColor);
    final dateRow = EventDateTimeRow(event: event, textColor: textColor);

    final titleRow = EventTitleRow(
      event: event,
      textColor: textColor,
      colorManager: _builder.colorManager,
    );

    return GestureDetector(
      onTap: () => _actionManager?.editEvent(event, context),
      child: Container(
        width: details.bounds.width,
        height: details.bounds.height,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(
            color: _builder.colorManager.getColor(event.eventColorIndex),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _builder.buildDefaultEventCard(
          dateRow: dateRow,
          // timeRow: timeRow,
          titleRow: titleRow,
          description: event.description,
          cardColor: Colors.white,
        ),
      ),
    );
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.permissionDenied),
        content: Text(AppLocalizations.of(context)!.permissionDeniedInf),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }
}
