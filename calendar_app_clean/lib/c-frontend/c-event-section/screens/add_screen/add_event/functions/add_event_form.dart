import 'package:first_project/c-frontend/c-event-section/screens/add_screen/utils/dialog/user_expandable_card.dart';
import 'package:first_project/c-frontend/c-event-section/screens/add_screen/utils/form/add_event_button_widget.dart';
import 'package:first_project/c-frontend/c-event-section/screens/add_screen/utils/form/color_picker_widget.dart';
import 'package:first_project/c-frontend/c-event-section/screens/add_screen/utils/form/date_picker_widget.dart';
import 'package:first_project/c-frontend/c-event-section/screens/add_screen/utils/form/description_input_widget.dart';
import 'package:first_project/c-frontend/c-event-section/screens/add_screen/utils/form/location_input_widget.dart';
import 'package:first_project/c-frontend/c-event-section/screens/add_screen/utils/form/note_input_widget.dart';
import 'package:first_project/c-frontend/c-event-section/screens/add_screen/utils/form/title_input_widget.dart';
import 'package:first_project/c-frontend/c-event-section/screens/add_screen/utils/repetition_toggle_widget.dart';
import 'package:flutter/material.dart';

import '../functions/add_event_dialogs.dart';
import '../functions/add_event_logic.dart';

class AddEventForm extends StatelessWidget {
  final AddEventLogic logic;
  final AddEventDialogs dialogs;

  const AddEventForm({
    Key? key,
    required this.logic,
    required this.dialogs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ColorPickerWidget(
          selectedEventColor: logic.selectedEventColor,
          onColorChanged: (color) {
            if (color != null) logic.setSelectedColor(color);
          },
          colorList: logic.colorList,
        ),
        const SizedBox(height: 10),
        TitleInputWidget(titleController: logic.titleController),
        const SizedBox(height: 10),
        DatePickersWidget(
          startDate: logic.selectedStartDate,
          endDate: logic.selectedEndDate,
          onStartDateTap: () => logic.selectDate(context, true),
          onEndDateTap: () => logic.selectDate(context, false),
        ),
        const SizedBox(height: 10),
        LocationInputWidget(locationController: logic.locationController),
        const SizedBox(height: 10),
        DescriptionInputWidget(
            descriptionController: logic.descriptionController),
        const SizedBox(height: 10),
        NoteInputWidget(noteController: logic.noteController),
        const SizedBox(height: 10),
        RepetitionToggleWidget(
          isRepetitive: logic.isRepetitive,
          toggleWidth: logic.toggleWidth,
          onTap: () async {
            final result = await showDialog(
              context: context,
              builder: (context) => dialogs.buildRepetitionDialog(context),
            );
            if (result != null && result.isNotEmpty) {
              logic.toggleRepetition(result[1], result[0]);
            }
          },
        ),
        const SizedBox(height: 10),
        UserExpandableCard(
          usersAvailable: logic.users,
          onSelectedUsersChanged: logic.setSelectedUsers,
        ),
        const SizedBox(height: 25),
        AddEventButtonWidget(
          onAddEvent: () async {
            await logic.addEvent(
              context,
              () {
                Navigator.pop(context, true); // ✅ success flag
              },
              () => dialogs.showErrorDialog(context),
              () => dialogs.showRepetitionDialog(context),
            );
          },
        ),
      ],
    );
  }
}
