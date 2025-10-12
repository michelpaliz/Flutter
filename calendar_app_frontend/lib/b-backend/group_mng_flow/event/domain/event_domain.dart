// lib/b-backend/core/event/domain/event_domain.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hexora/a-models/group_model/event/model/event.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/b-backend/group_mng_flow/event/repository/i_event_repository.dart';
import 'package:hexora/b-backend/group_mng_flow/event/socket/socket_events.dart';
import 'package:hexora/b-backend/group_mng_flow/event/socket/socket_manager.dart';
import 'package:hexora/b-backend/group_mng_flow/group/domain/group_domain.dart';
// ⬇️ keep using your top-level expander
import 'package:hexora/c-frontend/d-event-section/screens/repetition_dialog/utils/show_recurrence.dart';
import 'package:hexora/c-frontend/f-notification-section/event_notification_helper.dart';

class EventDomain {
  final Group _group;
  final IEventRepository _repo;
  final GroupDomain _groupDomain;

  final ValueNotifier<List<Event>> eventsNotifier =
      ValueNotifier<List<Event>>([]);

  void Function()? onExternalEventUpdate;
  bool _disposed = false;

  EventDomain(
    List<Event> initialEvents, {
    required BuildContext context,
    required Group group,
    required IEventRepository repository,
    required GroupDomain groupDomain,
  })  : _group = group,
        _repo = repository,
        _groupDomain = groupDomain {
    _bootstrap(context, initialEvents);
    _setupSocketForwarding();
  }

  Future<void> _bootstrap(BuildContext context, List<Event> initial) async {
    if (initial.isNotEmpty) {
      for (final e in initial) {
        _repo.onSocketCreated(_group.id, e.toJson());
      }
    }

    await _repo.refreshGroup(_group.id);

    final current = await _repo.getEventsByGroupId(_group.id);
    await Future.wait(current.map((e) async {
      try {
        await syncReminderFor(context, e);
      } catch (_) {}
    }));

    _recomputeVisibleWindow();
  }

  void _recomputeVisibleWindow() async {
    if (_disposed) return;

    final now = DateTime.now();
    final range = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now.add(const Duration(days: 365)),
    );

    final base = await _repo.getEventsByGroupId(_group.id);

    final expanded = <Event>[];
    for (final e in base) {
      final hasStringRule = e.rule != null && e.rule!.isNotEmpty;
      final hasObjRule = e.recurrenceRule != null;

      if (!hasStringRule && !hasObjRule) {
        if (_overlapsRange(e.startDate, e.endDate, range)) expanded.add(e);
      } else {
        expanded.addAll(
            expandRecurringEventForRange(e, range, maxOccurrences: 1000));
      }
    }

    eventsNotifier.value = _dedupe(expanded);

    void setCurrentGroup() => _groupDomain.currentGroup = _group;
    final phase = SchedulerBinding.instance.schedulerPhase;
    final inBuild = phase == SchedulerPhase.transientCallbacks ||
        phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.postFrameCallbacks;
    if (inBuild) {
      WidgetsBinding.instance.addPostFrameCallback((_) => setCurrentGroup());
    } else {
      setCurrentGroup();
    }

    onExternalEventUpdate?.call();
  }

  void _setupSocketForwarding() {
    final socket = SocketManager();
    socket.on(SocketEvents.created, (data) {
      if (_disposed) return;
      _repo.onSocketCreated(_group.id, data);
      _recomputeVisibleWindow();
    });
    socket.on(SocketEvents.updated, (data) {
      if (_disposed) return;
      _repo.onSocketUpdated(_group.id, data);
      _recomputeVisibleWindow();
    });
    socket.on(SocketEvents.deleted, (data) {
      if (_disposed) return;
      _repo.onSocketDeleted(_group.id, data);
      _recomputeVisibleWindow();
    });
  }

  Stream<List<Event>> watchEvents() => _repo.events$(_group.id);

  Future<void> manualRefresh(BuildContext context) async {
    await _repo.refreshGroup(_group.id);
    _recomputeVisibleWindow();
  }

  Future<Event> createEvent(BuildContext context, Event event) async {
    final created = await _repo.createEvent(event);
    try {
      await syncReminderFor(context, created);
    } catch (_) {}
    _recomputeVisibleWindow();
    return created;
  }

  Future<Event> updateEvent(BuildContext context, Event event) async {
    final updated = await _repo.updateEvent(event);
    try {
      await syncReminderFor(context, updated);
    } catch (_) {}
    _recomputeVisibleWindow();
    return updated;
  }

  Future<void> deleteEvent(String id) async {
    await _repo.deleteEvent(id);
    final base = await _repo.getEventsByGroupId(_group.id);
    for (final e in base) {
      if (e.id == id || e.rawRuleId == id) {
        try {
          await cancelReminderFor(e);
        } catch (_) {}
      }
    }
    _recomputeVisibleWindow();
  }

  Future<Event?> fetchEvent(String id, {String? fallbackId}) async {
    try {
      return await _repo.getEventById(id);
    } catch (_) {
      if (fallbackId != null) return await _repo.getEventById(fallbackId);
      rethrow;
    }
  }

  List<Event> _dedupe(List<Event> list) =>
      {for (final e in list) e.id: e}.values.toList();

  bool _overlapsRange(DateTime start, DateTime end, DateTimeRange range) =>
      start.isBefore(range.end) && end.isAfter(range.start);

  void dispose() {
    _disposed = true;
    eventsNotifier.dispose();
    final socket = SocketManager();
    socket.off(SocketEvents.created);
    socket.off(SocketEvents.updated);
    socket.off(SocketEvents.deleted);
  }
}
