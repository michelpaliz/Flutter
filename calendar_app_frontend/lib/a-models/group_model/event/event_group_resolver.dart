import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/b-backend/api/event/event_services.dart';
import 'package:calendar_app_frontend/b-backend/api/recurrenceRule/recurrence_rule_services.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/repetition_dialog/utils/show_recurrence.dart';
import 'package:flutter/material.dart';

class GroupEventResolver {
  final EventService _eventService = EventService();
  final RecurrenceRuleService _ruleService = RecurrenceRuleService();

  final Map<String, List<Event>> _cache = {}; //  ← same cache

  RecurrenceRuleService get ruleService => _ruleService;

  Future<List<Event>> getEventsForGroup(Group group) async {
    if (_cache.containsKey(group.id)) return _cache[group.id]!;

    final rawEvents = await _eventService.getEventsByGroupId(group.id);

    final ids = {
      for (final e in rawEvents)
        if (e.recurrenceRule == null && e.rawRuleId != null) e.rawRuleId!
    }.toList();

    if (ids.isEmpty) {
      _cache[group.id] = rawEvents;
      return rawEvents;
    }

    final rules = await _ruleService.getRulesByIds(ids);
    final ruleMap = {for (final r in rules) r.id: r};

    final hydrated = rawEvents.map((e) {
      if (e.recurrenceRule == null && e.rawRuleId != null) {
        final hydratedRule = ruleMap[e.rawRuleId];
        if (hydratedRule != null) {
          return e.copyWith(recurrenceRule: hydratedRule);
        } else {
          debugPrint(
            '⚠️ Could NOT hydrate recurrence rule for event "${e.title}", rawRuleId=${e.rawRuleId}',
          );
        }
      }
      return e;
    }).toList();

    final now = DateTime.now();
    final viewRange = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now.add(const Duration(days: 365)),
    );

    final expanded = hydrated.expand((e) {
      return expandRecurringEventForRange(e, viewRange);
    }).toList();

    _cache[group.id] = expanded;
    return expanded;
  }

  void clearGroup(String id) => _cache.remove(id); //  ← unchanged
  void clearAll() => _cache.clear(); //  ← unchanged
  void updateCache(String id, List<Event> list) =>
      _cache[id] = list; //  ← unchanged
}
