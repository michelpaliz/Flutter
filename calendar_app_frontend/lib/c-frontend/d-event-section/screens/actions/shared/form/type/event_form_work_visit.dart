// event_form_work_visit.dart
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/actions/add_screen/utils/dialog/user_expandable_card.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/actions/add_screen/utils/form/color_picker_widget.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/actions/add_screen/utils/form/date_picker_widget.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/actions/add_screen/utils/form/description_input_widget.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/actions/add_screen/utils/form/reminder_options.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/actions/shared/base/base_event_logic.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class EventFormWorkVisit extends StatefulWidget {
  final BaseEventLogic logic;
  final Future<void> Function() onSubmit;
  final String ownerUserId;
  final bool isEditing;

  const EventFormWorkVisit({
    super.key,
    required this.logic,
    required this.onSubmit,
    required this.ownerUserId,
    this.isEditing = false,
  });

  @override
  State<EventFormWorkVisit> createState() => _EventFormWorkVisitState();
}

class _EventFormWorkVisitState extends State<EventFormWorkVisit> {
  late DateTime startDate;
  late DateTime endDate;
  int? _reminder;
  bool _notifyMe = true;

  String? _clientId;
  String? _primaryServiceId;

  @override
  void initState() {
    super.initState();
    startDate = widget.logic.selectedStartDate;
    endDate = widget.logic.selectedEndDate;
    _reminder = widget.logic.reminderMinutes;
    _notifyMe = (_reminder ?? 0) > 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.logic.setEventType?.call('work_visit');
    });

    // Preselect if logic already has values
    _clientId = widget.logic.clientId;
    _primaryServiceId = widget.logic.primaryServiceId;
  }

  Future<void> _handleDateSelection(bool isStart) async {
    await widget.logic.selectDate(context, isStart);
    setState(() {
      startDate = widget.logic.selectedStartDate;
      endDate = widget.logic.selectedEndDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final clients = widget.logic.clients;
    final services = widget.logic.services;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CLIENT
        DropdownButtonFormField<String>(
          value: _clientId,
          items: clients
              .map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.displayName ?? c.name ?? 'Client'),
                  ))
              .toList(),
          onChanged: (v) {
            setState(() => _clientId = v);
            widget.logic.setClientId?.call(v);
          },
          decoration: InputDecoration(
            labelText: loc.client, // add "client" in ARB
          ),
        ),
        const SizedBox(height: 10),

        // PRIMARY SERVICE
        DropdownButtonFormField<String>(
          value: _primaryServiceId,
          items: services
              .map((s) => DropdownMenuItem(
                    value: s.id,
                    child: Text(s.name ?? 'Service'),
                  ))
              .toList(),
          onChanged: (v) {
            setState(() => _primaryServiceId = v);
            widget.logic.setPrimaryServiceId?.call(v);
          },
          decoration: InputDecoration(
            labelText: loc.primaryService, // add "primaryService" in ARB
          ),
        ),
        const SizedBox(height: 12),

        // Optional: visit services editor can be added later
        // (e.g., list of VisitService rows with planned minutes)

        ColorPickerWidget(
          selectedEventColor: widget.logic.selectedEventColor == null
              ? null
              : Color(widget.logic.selectedEventColor!),
          onColorChanged: (color) {
            if (color != null) widget.logic.setSelectedColor(color.value);
          },
          colorList: widget.logic.colorList.map((c) => Color(c)).toList(),
        ),
        const SizedBox(height: 10),

        // Title can be auto-generated later; keep a minimal description for now
        DescriptionInputWidget(
          descriptionController: widget.logic.descriptionController,
        ),
        const SizedBox(height: 12),

        DatePickersWidget(
          startDate: startDate,
          endDate: endDate,
          onStartDateTap: () => _handleDateSelection(true),
          onEndDateTap: () => _handleDateSelection(false),
        ),
        const SizedBox(height: 8),

        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _notifyMe,
          title: Text(loc.notifyMe),
          subtitle: Text(
            _notifyMe ? loc.notifyMeOnSubtitle : loc.notifyMeOffSubtitle,
          ),
          onChanged: (v) {
            setState(() {
              _notifyMe = v;
              if (!v) _reminder = 0;
            });
          },
        ),
        if (_notifyMe) ...[
          const SizedBox(height: 6),
          ReminderTimeDropdownField(
            initialValue: _reminder,
            onChanged: (val) => _reminder = val,
          ),
        ],

        const SizedBox(height: 10),
        UserExpandableCard(
          usersAvailable: widget.logic.users,
          initiallySelected: widget.logic.selectedUsers,
          excludeUserId: widget.ownerUserId,
          onSelectedUsersChanged: (selected) {
            widget.logic.setSelectedUsers(selected);
            setState(() {});
          },
        ),

        const SizedBox(height: 24),
        Center(
          child: ValueListenableBuilder<bool>(
            valueListenable: widget.logic.canSubmit,
            builder: (context, canSubmit, _) {
              return ElevatedButton(
                onPressed: canSubmit
                    ? () async {
                        widget.logic.setReminderMinutes(
                          _notifyMe
                              ? (_reminder ?? kDefaultReminderMinutes)
                              : 0,
                        );
                        await widget.onSubmit();
                      }
                    : null,
                child: Text(widget.isEditing ? loc.save : loc.addEvent),
              );
            },
          ),
        ),
      ],
    );
  }
}
