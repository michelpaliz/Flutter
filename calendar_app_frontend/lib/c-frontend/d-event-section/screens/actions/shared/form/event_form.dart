import 'package:calendar_app_frontend/a-models/group_model/recurrenceRule/recurrence_rule/legacy_recurrence_rule.dart';
import 'package:calendar_app_frontend/b-backend/api/category/category_services.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/actions/add_screen/add_event/widgets/repetition_toggle_widget.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/actions/add_screen/utils/dialog/user_expandable_card.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/actions/add_screen/utils/form/color_picker_widget.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/actions/add_screen/utils/form/date_picker_widget.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/actions/add_screen/utils/form/description_input_widget.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/actions/add_screen/utils/form/location_input_widget.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/actions/add_screen/utils/form/note_input_widget.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/actions/add_screen/utils/form/reminder_options.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/actions/add_screen/utils/form/title_input_widget.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/actions/shared/base/base_event_logic.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/actions/shared/utils/category_picker.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

abstract class EventDialogs {
  Widget buildRepetitionDialog(BuildContext context);
  void showErrorDialog(BuildContext context);
  Future<List?> showRepetitionDialog(
    BuildContext context, {
    required DateTime selectedStartDate,
    required DateTime selectedEndDate,
    LegacyRecurrenceRule? initialRule,
  });
}

class EventForm extends StatefulWidget {
  final Future<void> Function() onSubmit;
  final BaseEventLogic logic;
  final bool isEditing;
  final EventDialogs? dialogs;
  final CategoryApi categoryApi;

  /// 👉 Add this if your logic doesn’t expose an owner id already.
  /// If your `BaseEventLogic` has `currentUserId` (or similar),
  /// you can remove this and read from `logic` instead.
  final String ownerUserId;

  const EventForm({
    Key? key,
    required this.logic,
    required this.onSubmit,
    required this.ownerUserId,
    required this.categoryApi,
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
  bool _notifyMe = true; // 👈 new toggle

  @override
  void initState() {
    super.initState();
    startDate = widget.logic.selectedStartDate;
    endDate = widget.logic.selectedEndDate;
    _reminder = widget.logic.reminderMinutes;

    // Initialize toggle from existing reminder
    _notifyMe = (_reminder ?? 0) > 0;
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
        CategoryPicker(
          api: widget.categoryApi,
          label: 'Category',
          initialCategoryId:
              widget.logic.categoryId, // keep in your BaseEventLogic
          initialSubcategoryId:
              widget.logic.subcategoryId, // keep in your BaseEventLogic
          onChanged: (sel) {
            widget.logic.categoryId = sel.categoryId;
            widget.logic.subcategoryId = sel.subcategoryId;
          },
        ),
        const SizedBox(height: 10),

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

        DescriptionInputWidget(
          descriptionController: widget.logic.descriptionController,
        ),

        const SizedBox(height: 10),

        NoteInputWidget(noteController: widget.logic.noteController),
        const SizedBox(height: 10),

        LocationInputWidget(
          locationController: widget.logic.locationController,
        ),
        const SizedBox(height: 15),

        DatePickersWidget(
          startDate: startDate,
          endDate: endDate,
          onStartDateTap: () => _handleDateSelection(true),
          onEndDateTap: () => _handleDateSelection(false),
        ),

        const SizedBox(height: 8),

        /// 🔔 Notify me toggle
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _notifyMe,
          title: Text(loc.notifyMe), // add key in ARB: "notifyMe": "Notify me"
          subtitle: Text(
            _notifyMe
                ? loc.notifyMeOnSubtitle // e.g. "You'll get a reminder"
                : loc.notifyMeOffSubtitle, // e.g. "No reminder will be sent"
          ),
          onChanged: (v) {
            setState(() {
              _notifyMe = v;
              if (!v) _reminder = 0; // reset/removes reminder
            });
          },
        ),

        /// Show reminder picker only when notifications are ON
        if (_notifyMe) ...[
          const SizedBox(height: 6),
          ReminderTimeDropdownField(
            initialValue: _reminder,
            onChanged: (val) => _reminder = val,
          ),
        ],

        const SizedBox(height: 10),

        /// Exclude owner from invite list here
        UserExpandableCard(
          usersAvailable: widget.logic.users,
          initiallySelected: widget.logic.selectedUsers,
          excludeUserId: widget.ownerUserId, // 👈 owner won’t be listed
          onSelectedUsersChanged: (selected) {
            widget.logic.setSelectedUsers(selected);
            setState(() {}); // refresh isFormValid, etc.
          },
        ),

        // in EventForm.build() — somewhere after Title/Date inputs

        const SizedBox(height: 10),

        RepetitionToggleWidget(
          key:
              ValueKey(widget.logic.isRepetitive), // 👈 force rebuild on change
          isRepetitive: widget.logic.isRepetitive, // 👈 read live value
          toggleWidth: widget.logic.toggleWidth,
          onTap: () async {
            final wasRepeated = widget.logic.isRepetitive;

            if (widget.dialogs == null) {
              setState(() {
                widget.logic.toggleRepetition(!wasRepeated,
                    wasRepeated ? null : widget.logic.recurrenceRule);
              });
              return;
            }

            final result = await widget.dialogs!.showRepetitionDialog(
              context,
              selectedStartDate: widget.logic.selectedStartDate,
              selectedEndDate: widget.logic.selectedEndDate,
              initialRule: widget.logic.recurrenceRule,
            );

            if (result == null || result.isEmpty) {
              setState(() {
                widget.logic.toggleRepetition(!wasRepeated,
                    wasRepeated ? null : widget.logic.recurrenceRule);
              });
              return;
            }

            final LegacyRecurrenceRule? rule =
                result[0] as LegacyRecurrenceRule?;
            final bool isRepeated =
                result.length > 1 ? result[1] as bool : true;

            setState(() {
              widget.logic.toggleRepetition(isRepeated, rule);
            });
          },
        ),

        const SizedBox(height: 25),

        Center(
          child: ValueListenableBuilder<bool>(
            valueListenable: widget.logic.canSubmit,
            builder: (context, canSubmit, _) {
              return ElevatedButton(
                onPressed: canSubmit
                    ? () async {
                        final minutes = _notifyMe
                            ? (_reminder ?? kDefaultReminderMinutes)
                            : 0;
                        widget.logic.setReminderMinutes(minutes);

                        // ✅ Call the provided submit callback
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
