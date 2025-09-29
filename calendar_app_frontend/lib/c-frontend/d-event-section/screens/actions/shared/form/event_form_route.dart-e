// event_form_router.dart
import 'package:calendar_app_frontend/b-backend/api/category/category_services.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/actions/shared/base/base_event_logic.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/actions/shared/form/event_dialogs.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/actions/shared/form/type/event_form_simple.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/actions/shared/form/type/event_form_work_visit.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class EventFormRouter extends StatefulWidget {
  final BaseEventLogic logic;
  final Future<void> Function() onSubmit;
  final String ownerUserId;
  final CategoryApi categoryApi;
  final bool isEditing;

  /// 👇 NEW: lets parent pass the dialog implementation (e.g., `this`)
  final EventDialogs dialogs;

  const EventFormRouter({
    super.key,
    required this.logic,
    required this.onSubmit,
    required this.ownerUserId,
    required this.categoryApi,
    required this.dialogs,
    this.isEditing = false,
  });

  @override
  State<EventFormRouter> createState() => _EventFormRouterState();
}

class _EventFormRouterState extends State<EventFormRouter> {
  late String _type; // 'simple' | 'work_visit'

  @override
  void initState() {
    super.initState();
    _type = widget.logic.eventType.toLowerCase() == 'simple'
        ? 'simple'
        : 'work_visit'; // default to work_visit
  }

  void _setType(String t) {
    setState(() => _type = t); // local UI can update immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.logic.setEventType?.call(t);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Small segmented type switcher
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Work visit'),
                selected: _type == 'work_visit',
                onSelected: (_) => _setType('work_visit'),
              ),
              ChoiceChip(
                label: const Text('Simple'),
                selected: _type == 'simple',
                onSelected: (_) => _setType('simple'),
              ),
            ],
          ),
        ),

        if (_type == 'simple')
          EventFormSimple(
            logic: widget.logic,
            onSubmit: widget.onSubmit,
            ownerUserId: widget.ownerUserId,
            categoryApi: widget.categoryApi,
            isEditing: widget.isEditing,
            dialogs: widget.dialogs, // 👈 forwarded
          )
        else
          EventFormWorkVisit(
            logic: widget.logic,
            onSubmit: widget.onSubmit,
            ownerUserId: widget.ownerUserId,
            isEditing: widget.isEditing,
            dialogs: widget.dialogs, // 👈 forwarded (optional use)
          ),
      ],
    );
  }
}
