import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/c-frontend/b-dashboard-section/sections/graphs/enum/insights_types.dart';
import 'package:calendar_app_frontend/c-frontend/b-dashboard-section/sections/graphs/sections/bar/insights_bar_section.dart';
import 'package:calendar_app_frontend/c-frontend/b-dashboard-section/sections/graphs/sections/filter/insights_filter_section.dart';
import 'package:calendar_app_frontend/c-frontend/b-dashboard-section/sections/graphs/sections/past_hint/insights_past_hint.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GroupInsightsScreen extends StatefulWidget {
  final Group group;
  const GroupInsightsScreen({super.key, required this.group});

  @override
  State<GroupInsightsScreen> createState() => _GroupInsightsScreenState();
}

class _GroupInsightsScreenState extends State<GroupInsightsScreen> {
  bool _loading = true;
  String? _error;

  RangePreset _preset = RangePreset.m3;
  DateTimeRange? _customRange;

  // Only keep Clients/Services dimension; no type toggle here.
  Dimension _dimension = Dimension.clients;

  List<Event> _events = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final userMgmt = context.read<UserManagement>();
      final range = _resolveRange(DateTime.now());

      // TODO: replace with server-side range query (start..end)
      final upcoming =
          await userMgmt.fetchAgendaUpcoming(days: 365, limit: 5000);

      final filtered = upcoming.where((e) {
        if (e.groupId != widget.group.id) return false;

        // Range overlap
        final s = e.startDate.toLocal();
        final en = (e.endDate ?? e.startDate).toLocal();
        final inRange = !en.isBefore(range.start) && !s.isAfter(range.end);
        if (!inRange) return false;

        // Hard filter to "work" types only
        final t = (e.type ?? '').toLowerCase();
        return t == 'work_service' || t == 'work_visit';
      }).toList();

      setState(() {
        _events = filtered;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  DateTimeRange _resolveRange(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    switch (_preset) {
      case RangePreset.d7:
        return DateTimeRange(
            start: today.subtract(const Duration(days: 6)), end: today);
      case RangePreset.d30:
        return DateTimeRange(
            start: today.subtract(const Duration(days: 29)), end: today);
      case RangePreset.m3:
        return DateTimeRange(
            start: DateTime(today.year, today.month - 3, today.day),
            end: today);
      case RangePreset.m4:
        return DateTimeRange(
            start: DateTime(today.year, today.month - 4, today.day),
            end: today);
      case RangePreset.m6:
        return DateTimeRange(
            start: DateTime(today.year, today.month - 6, today.day),
            end: today);
      case RangePreset.y1:
        return DateTimeRange(
            start: DateTime(today.year - 1, today.month, today.day),
            end: today);
      case RangePreset.ytd:
        return DateTimeRange(start: DateTime(today.year, 1, 1), end: today);
      case RangePreset.custom:
        return _customRange ??
            DateTimeRange(
                start: today.subtract(const Duration(days: 29)), end: today);
    }
  }

  Map<String, int> _aggregateMinutes(Dimension dim, DateTimeRange range) {
    final out = <String, int>{};
    for (final e in _events) {
      final start = e.startDate.toLocal();
      final end = (e.endDate ?? e.startDate).toLocal();

      final s = start.isBefore(range.start) ? range.start : start;
      final en = end.isAfter(range.end) ? range.end : end;

      if (!en.isAfter(s)) continue;

      final minutes = en.difference(s).inMinutes;
      final key = (dim == Dimension.clients)
          ? (e.clientId ?? 'unknown_client')
          : (e.primaryServiceId ?? 'unknown_service');

      out.update(key, (v) => v + minutes, ifAbsent: () => minutes);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final range = _resolveRange(DateTime.now());
    final minutesMap = _aggregateMinutes(_dimension, range);
    final df = DateFormat.yMMMd(l.localeName);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.insightsTitle),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l.refresh,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    InsightsFiltersSection(
                      preset: _preset,
                      onPresetChanged: (p) {
                        setState(() => _preset = p);
                        _load();
                      },
                      onPickCustom: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                          initialDateRange: _resolveRange(DateTime.now()),
                          helpText: l.dateRangeCustom,
                        );
                        if (picked != null) {
                          setState(() {
                            _preset = RangePreset.custom;
                            _customRange = picked;
                          });
                          _load();
                        }
                      },
                      dimension: _dimension,
                      onDimensionChanged: (d) => setState(() => _dimension = d),

                      // Hide type controls on group insights
                      showTypeFilter: false,
                      rangeText:
                          '${df.format(range.start)} – ${df.format(range.end)}',
                    ),
                    const SizedBox(height: 16),
                    InsightsBarsCard(
                      title: _dimension == Dimension.clients
                          ? l.timeByClient
                          : l.timeByService,
                      minutesByKey: minutesMap,
                    ),
                    const SizedBox(height: 24),
                    if (_preset != RangePreset.custom &&
                        _resolveRange(DateTime.now())
                            .start
                            .isBefore(DateTime.now()) &&
                        _events.isEmpty)
                      const InsightsPastDataHint(),
                  ],
                ),
    );
  }
}
