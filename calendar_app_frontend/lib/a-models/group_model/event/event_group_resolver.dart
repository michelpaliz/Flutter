// group_event_resolver.dart
import 'package:hexora/a-models/group_model/event/event.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/b-backend/api/event/event_services.dart';
import 'package:hexora/b-backend/api/recurrenceRule/recurrence_rule_services.dart';
import 'package:flutter/material.dart';

class GroupEventResolver {
  final EventService _eventService;
  final RecurrenceRuleService _ruleService;

  GroupEventResolver({
    required EventService eventService,
    required RecurrenceRuleService ruleService,
  })  : _eventService = eventService,
        _ruleService = ruleService;

  final Map<String, List<Event>> _cache = {};

  RecurrenceRuleService get ruleService => _ruleService;

  Future<List<Event>> getEventsForGroup(Group group) async {
    final gid = group.id;
    if (_cache.containsKey(gid)) return _cache[gid]!;

    final rawEvents = await _eventService.getEventsByGroupId(gid);

    // unique rule ids we need to hydrate
    final ids = {
      for (final e in rawEvents)
        if (e.recurrenceRule == null && e.rawRuleId != null) e.rawRuleId!
    }.toList();

    if (ids.isEmpty) {
      _cache[gid] = rawEvents;
      return rawEvents;
    }

    final rules = await _ruleService.getRulesByIds(ids);
    final ruleMap = {for (final r in rules) r.id: r};

    final hydrated = rawEvents.map((e) {
      if (e.recurrenceRule == null && e.rawRuleId != null) {
        final r = ruleMap[e.rawRuleId];
        if (r != null) {
          return e.copyWith(recurrenceRule: r);
        } else {
          debugPrint(
              '⚠️ Could NOT hydrate recurrence rule for "${e.title}", rawRuleId=${e.rawRuleId}');
        }
      }
      return e;
    }).toList();

    _cache[gid] = hydrated;
    return hydrated;
  }

  void clearGroup(String id) => _cache.remove(id);
  void clearAll() => _cache.clear();
  void updateCache(String id, List<Event> list) => _cache[id] = list;
}
