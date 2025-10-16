// calendar_state.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/calendar/presentation/view_adapater/adapter_flow/event_data_source/event_data_source.dart';
import 'package:hexora/a-models/group_model/event/model/event.dart';

class CalendarState {
  // UI notifiers
  final ValueNotifier<int> calendarRefreshKey = ValueNotifier(0);
  final ValueNotifier<List<Event>> dailyEvents = ValueNotifier([]);
  final ValueNotifier<List<Event>> allEvents = ValueNotifier([]);
  final ValueNotifier<EventDataSource> dataSource =
      ValueNotifier(EventDataSource(const []));

  // snapshot + signature
  List<Event> _last = const [];
  int? _sig;
  DateTime? selectedDate;

  // debounce
  Timer? _refreshDebounce;

  void dispose() {
    _refreshDebounce?.cancel();
    dailyEvents.dispose();
    allEvents.dispose();
    dataSource.dispose();
    calendarRefreshKey.dispose();
  }

  bool applyEvents(List<Event> events) {
    final s = _signature(events);
    if (_sig == s) return false;

    _sig = s;
    _last = List<Event>.from(events);

    allEvents.value = _last;
    dataSource.value = EventDataSource(_last);

    if (selectedDate != null) {
      dailyEvents.value = eventsForDate(selectedDate!, _last);
    }
    return true;
  }

  List<Event> eventsForDate(DateTime date, List<Event> source) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return source
        .where((e) => e.startDate.isBefore(end) && e.endDate.isAfter(start))
        .toList();
  }

  void requestDebouncedRefresh(void Function() bumpKey) {
    _refreshDebounce?.cancel();
    _refreshDebounce = Timer(const Duration(milliseconds: 120), bumpKey);
  }

  int _signature(List<Event> list) {
    final parts = list.map((e) => Object.hash(
          e.id,
          e.rawRuleId,
          e.startDate.millisecondsSinceEpoch,
          e.endDate.millisecondsSinceEpoch,
          e.title.hashCode,
          e.recurrenceRule?.hashCode ?? e.rule?.hashCode ?? 0,
          e.eventColorIndex,
          e.allDay ? 1 : 0,
        ));
    return Object.hashAllUnordered(parts);
  }
}
