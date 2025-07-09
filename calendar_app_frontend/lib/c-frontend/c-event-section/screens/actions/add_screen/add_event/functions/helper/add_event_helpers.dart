import 'dart:developer' as devtools show log;

import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/a-models/group_model/event_appointment/recurrence_rule/legacy_recurrence_rule.dart';
import 'package:calendar_app_frontend/a-models/group_model/event_appointment/utils_recurrence_rule/recurrence_rule_utils.dart';
import 'package:calendar_app_frontend/d-stateManagement/group/group_management.dart';
import 'package:flutter/material.dart';

bool validateTitle(
    BuildContext context, TextEditingController titleController) {
  final title = titleController.text.trim();
  if (title.isEmpty) {
    devtools.log("⚠️ [addEvent] Title is empty — showing snackbar");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a title for the event.')),
    );
    return false;
  }
  return true;
}

bool validateRecurrence({
  required dynamic recurrenceRule,
  required DateTime selectedStartDate,
  required VoidCallback onRepetitionError,
}) {
  if (recurrenceRule != null) {
    devtools.log(
        "🔁 [addEvent] RecurrenceRule (raw): ${recurrenceRule.toString()}");

    try {
      // final rrule = recurrenceRule.toRRuleString(selectedStartDate);
      final rrule = toRRuleStringUtils(recurrenceRule, selectedStartDate);

      devtools.log("📅 [addEvent] RecurrenceRule (RRULE): $rrule");

      if (recurrenceRule.recurrenceType.toString().contains('Weekly') &&
          (recurrenceRule.daysOfWeek?.isEmpty ?? true)) {
        devtools.log("❌ [addEvent] Weekly recurrence is missing daysOfWeek.");
        onRepetitionError();
        return false;
      }
    } catch (e) {
      devtools.log("❌ [addEvent] Error parsing recurrence rule: $e");
      onRepetitionError();
      return false;
    }
  } else {
    devtools.log("⚠️ [addEvent] No recurrenceRule set");
  }
  return true;
}

Event buildNewEvent({
  required String id,
  required DateTime startDate,
  required DateTime endDate,
  required String title,
  required String groupId,
  required String calendarId,
  required dynamic recurrenceRule,
  required String location,
  required String description,
  required int eventColorIndex,
  required List<String> recipients,
  required String ownerId,
}) {
  return Event(
    id: id,
    startDate: startDate,
    endDate: endDate,
    title: title,
    groupId: groupId,
    calendarId: calendarId,
    recurrenceRule: recurrenceRule,
    localization: location,
    allDay: false,
    description: description,
    eventColorIndex: eventColorIndex,
    recipients: recipients,
    ownerId: ownerId,
    isDone: false,
    completedAt: null,
  );
}

Future<LegacyRecurrenceRule?> hydrateRecurrenceRuleIfNeeded({
  required GroupManagement groupManagement,
  required String? rawRuleId,
}) async {
  if (rawRuleId == null) return null;

  const maxRetries = 5;
  int retries = 0;

  while (retries < maxRetries) {
    try {
      // final rule = await groupManagement.groupEventResolver.ruleService
      //     .getRuleById(rawRuleId);
      final rule = await groupManagement.groupEventResolver.ruleService
          .getRuleById(rawRuleId);

      devtools.log("✅ Recurrence rule hydrated after $retries retries");
      return rule;
    } catch (_) {
      retries++;
      devtools.log("⏳ Retry $retries: Recurrence rule not ready...");
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  devtools.log("❌ Recurrence rule not found after $maxRetries retries");
  return null;
}
