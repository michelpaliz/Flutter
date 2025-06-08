import 'package:first_project/a-models/group_model/event_appointment/appointment/recurrence_rule.dart';
import 'package:first_project/c-frontend/c-event-section/screens/actions/add_screen/utils/dialog/user_expandable_card.dart';
import 'package:first_project/c-frontend/c-event-section/screens/actions/add_screen/utils/form/color_picker_widget.dart';
import 'package:first_project/c-frontend/c-event-section/screens/actions/add_screen/utils/form/date_picker_widget.dart';
import 'package:first_project/c-frontend/c-event-section/screens/actions/add_screen/utils/form/description_input_widget.dart';
import 'package:first_project/c-frontend/c-event-section/screens/actions/add_screen/utils/form/location_input_widget.dart';
import 'package:first_project/c-frontend/c-event-section/screens/actions/add_screen/utils/form/note_input_widget.dart';
import 'package:first_project/c-frontend/c-event-section/screens/actions/add_screen/utils/form/title_input_widget.dart';
import 'package:first_project/c-frontend/c-event-section/screens/actions/add_screen/utils/repetition_toggle_widget.dart';
import 'package:first_project/c-frontend/c-event-section/screens/actions/shared/base/base_event_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Optional dialogs interface (used only in Add flow)
abstract class EventDialogs {
  Widget buildRepetitionDialog(BuildContext context);

  void showErrorDialog(BuildContext context);

  /// Update this to match your new signature
  Future<List?> showRepetitionDialog(
    BuildContext context, {
    required DateTime selectedStartDate,
    required DateTime selectedEndDate,
    RecurrenceRule? initialRule,
  });
}

class EventForm extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Color Picker
        ColorPickerWidget(
          selectedEventColor: logic.selectedEventColor == null
              ? null
              : Color(logic.selectedEventColor!),
          onColorChanged: (color) {
            if (color != null) logic.setSelectedColor(color.value);
          },
          colorList: logic.colorList.map((c) => Color(c)).toList(),
        ),
        const SizedBox(height: 10),

        // Title
        TitleInputWidget(titleController: logic.titleController),
        const SizedBox(height: 10),

        // Date pickers
        DatePickersWidget(
          startDate: logic.selectedStartDate,
          endDate: logic.selectedEndDate,
          onStartDateTap: () => logic.selectDate(context, true),
          onEndDateTap: () => logic.selectDate(context, false),
        ),
        const SizedBox(height: 10),

        // Location
        LocationInputWidget(locationController: logic.locationController),
        const SizedBox(height: 10),

        // Description
        DescriptionInputWidget(
            descriptionController: logic.descriptionController),
        const SizedBox(height: 10),

        // Note
        NoteInputWidget(noteController: logic.noteController),
        const SizedBox(height: 10),

        // Repetition toggle
        RepetitionToggleWidget(
          isRepetitive: logic.isRepetitive,
          toggleWidth: logic.toggleWidth,
          onTap: () async {
            if (!isEditing && dialogs != null) {
              final result = await showDialog(
                context: context,
                builder: (context) => dialogs!.buildRepetitionDialog(context),
              );
              if (result != null && result.isNotEmpty) {
                logic.toggleRepetition(result[1], result[0]);
              }
            }
          },
        ),
        const SizedBox(height: 10),

        // User selection (only in add flow)
        // User selection (available in both add and edit)
        UserExpandableCard(
          usersAvailable: logic.users,
          initiallySelected: logic.selectedUsers,
          onSelectedUsersChanged: logic.setSelectedUsers,
        ),

        const SizedBox(height: 25),

        // Submit button
        Center(
          child: ElevatedButton(
            onPressed: () async {
              if (isEditing) {
                onSubmit(); // edit flow
              } else {
                await (logic as dynamic).addEvent(
                  // cast for dynamic safety
                  context,
                  () => Navigator.pop(context, true),
                  () => dialogs?.showErrorDialog(context),
                  () => dialogs?.showRepetitionDialog(
                    context,
                    selectedStartDate: logic.selectedStartDate,
                    selectedEndDate: logic.selectedEndDate,
                    initialRule: logic.recurrenceRule,
                  ),
                );
              }
            },
            child: Text(isEditing ? loc.save : loc.addEvent),
          ),
        ),
      ],
    );
  }
}
