// lib/b-backend/core/event/domain/event_domain.dart
import 'dart:async';
import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
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

  String get groupId => _group.id; // add this

  final ValueNotifier<List<Event>> eventsNotifier =
      ValueNotifier<List<Event>>([]);

  void Function()? onExternalEventUpdate;

  bool _disposed = false;

  // ── refresh/loader guards ────────────────────────────────────────────────
  bool _isRefreshing = false;
  bool _isLoading = false; // if you bind this to UI elsewhere
  bool get isLoading => _isLoading;
  void _setLoading(bool v) {
    if (_isLoading == v) return;
    _isLoading = v;
    // If this class ever extends ChangeNotifier, call notifyListeners() here.
  }

  EventDomain(
    List<Event> initialEvents, {
    required BuildContext context,
    required Group group,
    required IEventRepository repository,
    required GroupDomain groupDomain,
  })  : _group = group,
        _repo = repository {
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

    // Internal bootstrap refresh — don't ping external hook
    await _recomputeVisibleWindow(/*notifyExternal:*/ false);
  }

  // Add this field to your EventDomain class (top with other fields)
  int? _lastExpandedSig;

// Paste this helper anywhere inside EventDomain (e.g., below _dedupe)
  int _computeSignature(List<Event> list) {
    // Stable “meaningful change” hash (order-insensitive)
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

// Replace your _recomputeVisibleWindow with this version
  Future<void> _recomputeVisibleWindow([bool notifyExternal = false]) async {
    if (_disposed) return;

    final t0 = DateTime.now();
    devtools
        .log('[EventDomain] ▸ recompute start notifyExternal=$notifyExternal');

    final now = DateTime.now();
    final range = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now.add(const Duration(days: 365)),
    );

    // 1) Pull base events
    final base = await _repo.getEventsByGroupId(_group.id);
    devtools.log('[EventDomain]   base=${base.length}');

    // 2) Expand recurrences for visible window
    final expanded = <Event>[];
    for (final e in base) {
      final hasStringRule = e.rule != null && e.rule!.isNotEmpty;
      final hasObjRule = e.recurrenceRule != null;

      if (!hasStringRule && !hasObjRule) {
        if (_overlapsRange(e.startDate, e.endDate, range)) expanded.add(e);
      } else {
        final ex = expandRecurringEventForRange(
          e,
          range,
          maxOccurrences: 1000,
        );
        expanded.addAll(ex);
      }
    }

    // 3) Dedupe + compute signature to avoid no-op emits
    final deduped = _dedupe(expanded);
    final sig = _computeSignature(deduped);
    final changed = _lastExpandedSig != sig;

    devtools.log('[EventDomain]   expanded=${expanded.length} '
        'deduped=${deduped.length} changed=$changed '
        'elapsed=${DateTime.now().difference(t0).inMilliseconds}ms');

    if (!changed) {
      devtools.log('[EventDomain] ◂ recompute NO-OP (same signature)');
      return;
    }
    _lastExpandedSig = sig;

    // 4) Push to notifier (this is what UI listens to)
    eventsNotifier.value = deduped;
    devtools.log('[EventDomain]   notifier <- ${deduped.length} events');

    // 5) (Optional) Update currentGroup — WARNING: this can trigger rebuild storms.
    //    Keep disabled during debugging; re-enable only if absolutely needed.
    // void setCurrentGroup() => _groupDomain.currentGroup = _group;
    // final phase = SchedulerBinding.instance.schedulerPhase;
    // final inBuild = phase == SchedulerPhase.transientCallbacks ||
    //     phase == SchedulerPhase.persistentCallbacks ||
    //     phase == SchedulerPhase.postFrameCallbacks;
    // if (inBuild) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) => setCurrentGroup());
    // } else {
    //   setCurrentGroup();
    // }

    // 6) Only notify external listeners when triggered by sockets
    if (notifyExternal) {
      devtools.log('[EventDomain]   notifyExternal hook');
      onExternalEventUpdate?.call();
    }

    devtools.log('[EventDomain] ◂ recompute done '
        'total=${deduped.length} '
        'elapsed=${DateTime.now().difference(t0).inMilliseconds}ms');
  }

  void _setupSocketForwarding() {
    final socket = SocketManager();

    socket.on(SocketEvents.created, (data) {
      if (_disposed) return;
      _repo.onSocketCreated(_group.id, data);
      // External origin → notify external listeners
      _recomputeVisibleWindow(true);
    });
    socket.on(SocketEvents.updated, (data) {
      if (_disposed) return;
      _repo.onSocketUpdated(_group.id, data);
      _recomputeVisibleWindow(true);
    });
    socket.on(SocketEvents.deleted, (data) {
      if (_disposed) return;
      _repo.onSocketDeleted(_group.id, data);
      _recomputeVisibleWindow(true);
    });
  }

  Stream<List<Event>> watchEvents() => _repo.events$(_group.id);

  /// Idempotent manual refresh; won’t re-enter and always clears loading.
  Future<void> manualRefresh(BuildContext context,
      {bool silent = false}) async {
    if (_isRefreshing) {
      devtools.log('↻ [EventDomain] manualRefresh already running — skip');
      return;
    }
    _isRefreshing = true;
    if (!silent) _setLoading(true);
    try {
      await _repo.refreshGroup(_group.id);
      await _recomputeVisibleWindow(/*notifyExternal:*/ false);
    } catch (e, st) {
      devtools.log('💥 [EventDomain] manualRefresh error: $e\n$st');
    } finally {
      if (!silent) _setLoading(false);
      _isRefreshing = false;
    }
  }

  Future<Event> createEvent(BuildContext context, Event event) async {
    final created = await _repo.createEvent(event);
    try {
      await syncReminderFor(context, created);
    } catch (_) {}
    // Local mutation — don't notify external
    await _recomputeVisibleWindow(false);
    return created;
  }

  Future<Event> updateEvent(BuildContext context, Event event) async {
    final updated = await _repo.updateEvent(event);
    try {
      await syncReminderFor(context, updated);
    } catch (_) {}
    await _recomputeVisibleWindow(false);
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
    await _recomputeVisibleWindow(false);
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
