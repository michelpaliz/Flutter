import 'package:calendar_app_frontend/a-models/group_model/recurrenceRule/recurrence_rule/legacy_recurrence_rule.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/actions/add_screen/add_event/functions/helper/add_event_helpers.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/actions/add_screen/add_event/widgets/repetition_toggle_widget.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/actions/add_screen/utils/dialog/user_expandable_card.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/actions/add_screen/utils/form/color_picker_widget.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/actions/add_screen/utils/form/date_picker_widget.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/actions/add_screen/utils/form/description_input_widget.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/actions/add_screen/utils/form/location_input_widget.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/actions/add_screen/utils/form/note_input_widget.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/actions/add_screen/utils/form/repetition_toggle_widget.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/actions/add_screen/utils/form/title_input_widget.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/actions/shared/base/base_event_logic.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Optional dialogs interface (used only in Add flow)
abstract class EventDialogs {
  Widget buildRepetitionDialog(BuildContext context);

  void showErrorDialog(BuildContext context);

  /// Update this to match your new signature
  Future<List?> showRepetitionDialog(
    BuildContext context, {
    required DateTime selectedStartDate,
    required DateTime selectedEndDate,
    LegacyRecurrenceRule? initialRule,
  });
}

/// ─────────────────────────────────────────────────────────────────────────────
///  EventForm
/// ─────────────────────────────────────────────────────────────────────────────
class EventForm extends StatefulWidget {
  /// 🔹 CHANGE:  make `onSubmit` await-able
  final Future<void> Function() onSubmit;

  final BaseEventLogic logic;
  final bool isEditing;
  final EventDialogs? dialogs;

  const EventForm({
    Key? key,
    required this.logic,
    required this.onSubmit, // ← now Future<void>
    this.dialogs,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  late DateTime startDate;
  late DateTime endDate;
  int? _reminder;

  @override
  void initState() {
    super.initState();
    startDate = widget.logic.selectedStartDate;
    endDate = widget.logic.selectedEndDate;
    _reminder = widget.logic.reminderMinutes;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── input widgets (unchanged) ───────────────────────────────────────
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

        TitleInputWidget(titleController: widget.logic.titleController),
        const SizedBox(height: 10),

        DatePickersWidget(
          startDate: startDate,
          endDate: endDate,
          onStartDateTap: () => _handleDateSelection(true),
          onEndDateTap: () => _handleDateSelection(false),
        ),

        const SizedBox(height: 10),

        ReminderTimeDropdownField(
          initialValue: _reminder,
          onChanged: (val) => _reminder = val,
        ),

        const SizedBox(height: 10),

        LocationInputWidget(
            locationController: widget.logic.locationController),
        const SizedBox(height: 10),

        DescriptionInputWidget(
            descriptionController: widget.logic.descriptionController),
        const SizedBox(height: 10),

        NoteInputWidget(noteController: widget.logic.noteController),
        const SizedBox(height: 10),

        // repetition toggle (unchanged) …
        RepetitionToggleWidget(
          isRepetitive: widget.logic.isRepetitive,
          toggleWidth: widget.logic.toggleWidth,
          onTap: () async {
            if (widget.dialogs == null) return;

            final result = await widget.dialogs!.showRepetitionDialog(
              context,
              selectedStartDate: widget.logic.selectedStartDate,
              selectedEndDate: widget.logic.selectedEndDate,
              initialRule: widget.logic.recurrenceRule,
            );

            if (result == null) return; // User canceled

            final LegacyRecurrenceRule? rule =
                result[0] as LegacyRecurrenceRule?;
            final bool isRepeated =
                result.length > 1 ? result[1] as bool : false;

            widget.logic.toggleRepetition(isRepeated, rule);
          },
        ),

        const SizedBox(height: 10),

        UserExpandableCard(
          usersAvailable: widget.logic.users,
          initiallySelected: widget.logic.selectedUsers,
          onSelectedUsersChanged: widget.logic.setSelectedUsers,
        ),
        const SizedBox(height: 25),

        /// ── SUBMIT BUTTON ──────────────────────────────────────────────────
        Center(
          child: ElevatedButton(
              child: Text(widget.isEditing ? loc.save : loc.addEvent),
              onPressed: () async {
                if (widget.isEditing) {
                  widget.logic.setReminderMinutes(
                      _reminder ?? kDefaultReminderMinutes); // ← add this line
                  await withLoadingDialog(
                    context,
                    widget.onSubmit,
                    message: loc.saveChangesMessage,
                  );
                } else {
                  widget.logic.setReminderMinutes(
                      _reminder ?? kDefaultReminderMinutes); // ← also here
                  final ok = await withLoadingDialog(
                    context,
                    () => widget.logic.addEvent(context),
                    message: loc.createEventMessage,
                  );
                  if (ok == true) {
                    Navigator.pop(context, true);
                  } else {
                    widget.dialogs?.showErrorDialog(context);
                  }
                }
              }),
        ),
      ],
    );
  }
}
