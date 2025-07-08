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
  
  RecurrenceRuleService  get ruleService => _ruleService;

  Future<List<Event>> getEventsForGroup(Group group) async {
    // 1. return from cache if we already have it
    if (_cache.containsKey(group.id)) return _cache[group.id]!;

    // 2. fetch raw events (may contain only rule IDs)
    final rawEvents = await _eventService.getEventsByGroupId(group.id);

    // 3. collect unique rule-IDs that still need hydration
    final ids = {
      for (final e in rawEvents)
        if (e.recurrenceRule == null && e.rawRuleId != null) e.rawRuleId!
    }.toList();

    // 4. if there’s nothing to hydrate, cache & return immediately
    if (ids.isEmpty) {
      _cache[group.id] = rawEvents;
      return rawEvents;
    }

    // 5. bulk-fetch the full rule objects
    final rules = await _ruleService.getRulesByIds(ids);
    final ruleMap = {for (final r in rules) r.id: r};

    // 6. patch each event with its full recurrence rule
    final hydrated = rawEvents.map((e) {
      if (e.recurrenceRule == null &&
          e.rawRuleId != null &&
          ruleMap.containsKey(e.rawRuleId)) {
        return e.copyWith(recurrenceRule: ruleMap[e.rawRuleId]!);
      }
      return e;
    }).toList();

    // 👇 Expand recurring events here
    final now = DateTime.now();
    final DateTimeRange viewRange = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now.add(const Duration(days: 365)), // or your visible calendar range
    );
    final List<Event> expanded = hydrated.expand((e) {
      return expandRecurringEventForRange(e, viewRange);
    }).toList();

    // 7. cache & return
    _cache[group.id] = expanded;
    return expanded;
  }

  void clearGroup(String id) => _cache.remove(id); //  ← unchanged
  void clearAll() => _cache.clear(); //  ← unchanged
  void updateCache(String id, List<Event> list) =>
      _cache[id] = list; //  ← unchanged
}
