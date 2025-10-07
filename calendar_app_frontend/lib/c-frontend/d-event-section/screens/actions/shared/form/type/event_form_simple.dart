// event_form_simple.dart
import 'package:hexora/a-models/group_model/recurrenceRule/recurrence_rule/legacy_recurrence_rule.dart';
import 'package:hexora/b-backend/core/category/category_api_client.dart';
import 'package:hexora/c-frontend/d-event-section/screens/actions/add_screen/add_event/widgets/repetition_toggle_widget.dart';
import 'package:hexora/c-frontend/d-event-section/screens/actions/add_screen/utils/dialog/user_expandable_card.dart';
import 'package:hexora/c-frontend/d-event-section/screens/actions/add_screen/utils/form/color_picker_widget.dart';
import 'package:hexora/c-frontend/d-event-section/screens/actions/add_screen/utils/form/date_picker_widget.dart';
import 'package:hexora/c-frontend/d-event-section/screens/actions/add_screen/utils/form/description_input_widget.dart';
import 'package:hexora/c-frontend/d-event-section/screens/actions/add_screen/utils/form/location_input_widget.dart';
import 'package:hexora/c-frontend/d-event-section/screens/actions/add_screen/utils/form/note_input_widget.dart';
import 'package:hexora/c-frontend/d-event-section/screens/actions/add_screen/utils/form/reminder_options.dart';
import 'package:hexora/c-frontend/d-event-section/screens/actions/add_screen/utils/form/title_input_widget.dart';
import 'package:hexora/c-frontend/d-event-section/screens/actions/shared/base/base_event_logic.dart';
import 'package:hexora/c-frontend/d-event-section/screens/actions/shared/form/event_dialogs.dart';
import 'package:hexora/c-frontend/d-event-section/screens/actions/shared/utils/category_picker.dart';
import 'package:hexora/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class EventFormSimple extends StatefulWidget {
  final Future<void> Function() onSubmit;
  final BaseEventLogic logic;
  final bool isEditing;
  final CategoryApi categoryApi;
  final String ownerUserId;

  /// Optional: let the parent/router provide the repetition dialog implementation.
  final EventDialogs? dialogs;

  const EventFormSimple({
    super.key,
    required this.logic,
    required this.onSubmit,
    required this.ownerUserId,
    required this.categoryApi,
    this.isEditing = false,
    this.dialogs,
  });

  @override
  State<EventFormSimple> createState() => _EventFormSimpleState();
}

class _EventFormSimpleState extends State<EventFormSimple> {
  late DateTime startDate;
  late DateTime endDate;
  int? _reminder;
  bool _notifyMe = true;

  @override
  void initState() {
    super.initState();
    startDate = widget.logic.selectedStartDate;
    endDate = widget.logic.selectedEndDate;
    _reminder = widget.logic.reminderMinutes;
    _notifyMe = (_reminder ?? 0) > 0;

    // Defer to after first frame to avoid setState-in-build issues.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      widget.logic.setEventType?.call('simple');

      // If a dialog provider is passed and the logic hook isn't wired yet, wire it.
      if (widget.dialogs != null &&
          widget.logic.onShowRepetitionDialog == null) {
        widget.logic.onShowRepetitionDialog = (
          BuildContext _, {
          required DateTime selectedStartDate,
          required DateTime selectedEndDate,
          LegacyRecurrenceRule? initialRule,
        }) {
          return widget.dialogs!.showRepetitionDialog(
            context,
            selectedStartDate: selectedStartDate,
            selectedEndDate: selectedEndDate,
            initialRule: initialRule,
          );
        };
      }
    });
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
          initialCategoryId: widget.logic.categoryId,
          initialSubcategoryId: widget.logic.subcategoryId,
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
        const SizedBox(height: 10),
        RepetitionToggleWidget(
          key: ValueKey(widget.logic.isRepetitive),
          isRepetitive: widget.logic.isRepetitive,
          toggleWidth: widget.logic.toggleWidth,
          onTap: () async {
            final wasRepeated = widget.logic.isRepetitive;

            // If no hook is provided, just toggle without dialog.
            if (widget.logic.onShowRepetitionDialog == null) {
              setState(() => widget.logic
                  .toggleRepetition(!wasRepeated, widget.logic.recurrenceRule));
              return;
            }

            final result = await widget.logic.onShowRepetitionDialog!(
              context,
              selectedStartDate: widget.logic.selectedStartDate,
              selectedEndDate: widget.logic.selectedEndDate,
              initialRule: widget.logic.recurrenceRule,
            );

            if (result == null || result.isEmpty) {
              setState(() => widget.logic.toggleRepetition(!wasRepeated, null));
              return;
            }

            final LegacyRecurrenceRule? rule =
                result[0] as LegacyRecurrenceRule?;
            final bool isRepeated =
                result.length > 1 ? result[1] as bool : true;

            setState(() => widget.logic.toggleRepetition(isRepeated, rule));
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
