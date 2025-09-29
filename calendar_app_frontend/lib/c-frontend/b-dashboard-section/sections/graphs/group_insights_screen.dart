import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/event/event.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/graphs/enum/insights_types.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/graphs/sections/bar/insights_bar_section.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/graphs/sections/filter/insights_filter_section.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/graphs/sections/past_hint/insights_past_hint.dart';
import 'package:hexora/d-stateManagement/user/user_management.dart';
import 'package:hexora/l10n/app_localizations.dart';
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

  // Only “Clientes / Servicios” for this screen
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
      final upcoming = await userMgmt.fetchAgendaUpcoming(days: 365, limit: 5000);

      final filtered = upcoming.where((e) {
        if (e.groupId != widget.group.id) return false;

        final s = e.startDate.toLocal();
        final en = (e.endDate ?? e.startDate).toLocal();
        final inRange = !en.isBefore(range.start) && !s.isAfter(range.end);
        if (!inRange) return false;

        // Hard filter to “work” types for group insights
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
        return DateTimeRange(start: today.subtract(const Duration(days: 6)), end: today);
      case RangePreset.d30:
        return DateTimeRange(start: today.subtract(const Duration(days: 29)), end: today);
      case RangePreset.m3:
        return DateTimeRange(start: DateTime(today.year, today.month - 3, today.day), end: today);
      case RangePreset.m4:
        return DateTimeRange(start: DateTime(today.year, today.month - 4, today.day), end: today);
      case RangePreset.m6:
        return DateTimeRange(start: DateTime(today.year, today.month - 6, today.day), end: today);
      case RangePreset.y1:
        return DateTimeRange(start: DateTime(today.year - 1, today.month, today.day), end: today);
      case RangePreset.ytd:
        return DateTimeRange(start: DateTime(today.year, 1, 1), end: today);
      case RangePreset.custom:
        return _customRange ??
            DateTimeRange(start: today.subtract(const Duration(days: 29)), end: today);
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

  Future<void> _pickCustomRange(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final range = _resolveRange(DateTime.now());
    final minutesMap = _aggregateMinutes(_dimension, range);
    final df = DateFormat.yMMMd(l.localeName);
    final rangeText = '${df.format(range.start)} – ${df.format(range.end)}';

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
                    // BIG TABS (Clientes / Servicios)
                    _DimensionTabs(
                      value: _dimension,
                      onChanged: (d) => setState(() => _dimension = d),
                    ),
                    const SizedBox(height: 12),

                    // PERIOD CARD (chips + date)
                    InsightsFiltersSection(
                      preset: _preset,
                      onPresetChanged: (p) {
                        setState(() => _preset = p);
                        _load();
                      },
                      onPickCustom: () => _pickCustomRange(context),
                      rangeText: rangeText,
                    ),

                    const SizedBox(height: 16),

                    // BARS
                    InsightsBarsCard(
                      title: _dimension == Dimension.clients
                          ? l.timeByClient
                          : l.timeByService,
                      minutesByKey: minutesMap,
                    ),

                    const SizedBox(height: 24),

                    if (_preset != RangePreset.custom &&
                        _resolveRange(DateTime.now()).start.isBefore(DateTime.now()) &&
                        _events.isEmpty)
                      const InsightsPastDataHint(),
                  ],
                ),
    );
  }
}

/// Large, rounded tabs for Clientes / Servicios
class _DimensionTabs extends StatelessWidget {
  final Dimension value;
  final ValueChanged<Dimension> onChanged;
  const _DimensionTabs({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    Widget tab(String text, bool selected, VoidCallback onTap) {
      return Expanded(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 44,
          decoration: BoxDecoration(
            color: selected ? cs.primary : cs.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        tab(l.filterDimensionClients, value == Dimension.clients,
            () => onChanged(Dimension.clients)),
        const SizedBox(width: 10),
        tab(l.filterDimensionServices, value == Dimension.services,
            () => onChanged(Dimension.services)),
      ],
    );
  }
}
