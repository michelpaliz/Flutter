import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:first_project/c-frontend/c-event-section/screens/actions/edit_screen/functions/edit/edit_event_logic.dart';
import 'package:first_project/c-frontend/c-event-section/screens/actions/edit_screen/widgets/event/date_picker.dart';
import 'package:first_project/c-frontend/c-event-section/screens/actions/edit_screen/widgets/event/description_input.dart';
import 'package:first_project/c-frontend/c-event-section/screens/actions/edit_screen/widgets/event/event_color_dropdown.dart';
import 'package:first_project/c-frontend/c-event-section/screens/actions/edit_screen/widgets/event/location_input.dart';
import 'package:first_project/c-frontend/c-event-section/screens/actions/edit_screen/widgets/event/note_input.dart';
import 'package:first_project/c-frontend/c-event-section/screens/actions/edit_screen/widgets/event/repetition_toggle.dart';
import 'package:first_project/c-frontend/c-event-section/screens/actions/edit_screen/widgets/event/title_input.dart';
import 'package:first_project/c-frontend/c-event-section/utils/color_manager.dart';
import 'package:first_project/d-stateManagement/group/group_management.dart';
import 'package:first_project/d-stateManagement/user/user_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class EditEventScreen extends StatefulWidget {
  final Event event;
  const EditEventScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen>
    with EditEventLogic<EditEventScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initLogic(
      event: widget.event,
      gm: context.read<GroupManagement>(),
      um: context.read<UserManagement>(),
    );
  }

  @override
  void dispose() {
    disposeLogic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.event)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EventColorDropdown(
              selectedColor: selectedColor,
              colorList: ColorManager.eventColors,
              onColorSelected: setSelectedColor,
            ),
            const SizedBox(height: 10),
            TitleInput(controller: titleController),
            const SizedBox(height: 10),
            DatePickerRow(
              selectedStartDate: selectedStartDate,
              selectedEndDate: selectedEndDate,
              // wrap your helper to match the expected signature:
              selectDateFn: (ctx, isStart) => showDateTimePicker(
                ctx,
                isStart ? selectedStartDate : selectedEndDate,
              ),
              onDateSelected: (isStart, picked) {
                if (isStart)
                  setStartDate(picked);
                else
                  setEndDate(picked);
              },
            ),
            const SizedBox(height: 10),
            LocationInput(controller: locationController),
            const SizedBox(height: 10),
            DescriptionInput(controller: descriptionController),
            const SizedBox(height: 10),
            NoteInput(controller: noteController),
            const SizedBox(height: 20),
            RepetitionToggle(
              isRepetitive: recurrenceRule != null,
              initialRule: recurrenceRule,
              toggleWidth: toggleWidth,
              startDate: selectedStartDate,
              endDate: selectedEndDate,
              onToggleChanged: setRecurrenceRule,
            ),
            const SizedBox(height: 25),
            Center(
              child: ElevatedButton(
                onPressed: saveEditedEvent,
                child: Text(loc.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
