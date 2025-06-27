import 'package:calendar_app_frontend/a-models/group_model/event_appointment/appointment/legacy_recurrence_rule.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/actions/add_screen/utils/dialog/user_expandable_card.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/actions/add_screen/utils/form/color_picker_widget.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/actions/add_screen/utils/form/date_picker_widget.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/actions/add_screen/utils/form/description_input_widget.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/actions/add_screen/utils/form/location_input_widget.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/actions/add_screen/utils/form/note_input_widget.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/actions/add_screen/utils/form/title_input_widget.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/actions/add_screen/utils/repetition_toggle_widget.dart';
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

class EventForm extends StatefulWidget {
  final BaseEventLogic logic;
  final VoidCallback onSubmit;
  final bool isEditing;
  final EventDialogs? dialogs;

  const EventForm({
    Key? key,
    required this.logic,
    required this.onSubmit,
    this.dialogs,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();
    startDate = widget.logic.selectedStartDate;
    endDate = widget.logic.selectedEndDate;
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

        // ✅ Updated: dynamic & rebuilds after selection
        DatePickersWidget(
          startDate: startDate,
          endDate: endDate,
          onStartDateTap: () => _handleDateSelection(true),
          onEndDateTap: () => _handleDateSelection(false),
        ),
        const SizedBox(height: 10),

        LocationInputWidget(
          locationController: widget.logic.locationController,
        ),
        const SizedBox(height: 10),

        DescriptionInputWidget(
          descriptionController: widget.logic.descriptionController,
        ),
        const SizedBox(height: 10),

        NoteInputWidget(noteController: widget.logic.noteController),
        const SizedBox(height: 10),

        // RepetitionToggleWidget(
        //   isRepetitive: widget.logic.isRepetitive,
        //   toggleWidth: widget.logic.toggleWidth,
        //   onTap: () async {
        //     if (!widget.isEditing && widget.dialogs != null) {
        //       final result = await showDialog(
        //         context: context,
        //         builder: (context) =>
        //             widget.dialogs!.buildRepetitionDialog(context),
        //       );
        //       if (result != null && result.isNotEmpty) {
        //         widget.logic.toggleRepetition(result[1], result[0]);
        //       }
        //     }
        //   },
        // ),
        RepetitionToggleWidget(
          isRepetitive: widget.logic.isRepetitive,
          toggleWidth: widget.logic.toggleWidth,
          onTap: () async {
            // Allow tapping even in edit mode, if a dialog is supplied
            if (widget.dialogs != null) {
              final result = await widget.dialogs!.showRepetitionDialog(
                context,
                selectedStartDate: widget.logic.selectedStartDate,
                selectedEndDate: widget.logic.selectedEndDate,
                initialRule: widget.logic.recurrenceRule,
              );
              if (result != null && result.isNotEmpty) {
                // widget.logic.toggleRepetition(result[1], result[0]);
                if (result.first is LegacyRecurrenceRule) {
                  widget.logic.toggleRepetition(
                      true, result.first as LegacyRecurrenceRule);
                }
              }
            } else {
              debugPrint("⚠️ Repetition dialog not available in this context.");
            }
          },
        ),

        const SizedBox(height: 10),

        UserExpandableCard(
          usersAvailable: widget.logic.users,
          initiallySelected: widget.logic.selectedUsers,
          onSelectedUsersChanged: widget.logic.setSelectedUsers,
        ),
        const SizedBox(height: 25),

        Center(
          child: ElevatedButton(
            onPressed: () async {
              if (widget.isEditing) {
                widget.onSubmit();
              } else {
                await (widget.logic as dynamic).addEvent(
                  context,
                  () => Navigator.pop(context, true),
                  () => widget.dialogs?.showErrorDialog(context),
                  () => widget.dialogs?.showRepetitionDialog(
                    context,
                    selectedStartDate: widget.logic.selectedStartDate,
                    selectedEndDate: widget.logic.selectedEndDate,
                    initialRule: widget.logic.recurrenceRule,
                  ),
                );
              }
            },
            child: Text(widget.isEditing ? loc.save : loc.addEvent),
          ),
        ),
      ],
    );
  }
}
