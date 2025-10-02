import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/event/event.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/b-backend/api/client/client_api.dart';
import 'package:hexora/b-backend/api/service/service_api.dart';
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

  Map<String, String> _clientNames = {};
  Map<String, String> _serviceNames = {};

  // Only “Clientes / Servicios” for this screen
  Dimension _dimension = Dimension.clients;

  List<Event> _events = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Map<String, int> _applyLabels(Map<String, int> minutesById) {
    if (_dimension == Dimension.clients) {
      return {
        for (final e in minutesById.entries)
          (_clientNames[e.key] ?? e.key): e.value,
      };
    } else {
      return {
        for (final e in minutesById.entries)
          (_serviceNames[e.key] ?? e.key): e.value,
      };
    }
  }

  // Future<void> _load() async {
  //   setState(() {
  //     _loading = true;
  //     _error = null;
  //   });

  //   try {
  //     final userMgmt = context.read<UserManagement>();
  //     final range = _resolveRange(DateTime.now());

  //     // 1) Fetch events from the new agenda endpoint
  //     final eventsFuture = userMgmt.fetchWorkInRange(
  //       groupId: widget.group.id,
  //       from: range.start,
  //       to: range.end,
  //       types: const ['work_visit', 'work_service'],
  //     );

  //     // 2) In parallel, fetch catalogs for names (nice labels)
  //     final clientsApi = ClientsApi();
  //     final servicesApi = ServiceApi();
  //     final clientsFuture =
  //         clientsApi.list(groupId: widget.group.id, active: null);
  //     final servicesFuture =
  //         servicesApi.list(groupId: widget.group.id, active: null);

  //     final results =
  //         await Future.wait([eventsFuture, clientsFuture, servicesFuture]);

  //     final events = results[0] as List<Event>;
  //     final clients = results[1] as List<dynamic>; // Client
  //     final services = results[2] as List<dynamic>; // Service

  //     // (Optional) guard if backend ever returns other groups by mistake
  //     final onlyThisGroup =
  //         events.where((e) => e.groupId == widget.group.id).toList();

  //     // Build ID → name maps
  //     final clientNames = <String, String>{
  //       for (final c in clients)
  //         c.id: (c.name?.trim().isNotEmpty == true ? c.name!.trim() : c.id),
  //     };
  //     final serviceNames = <String, String>{
  //       for (final s in services)
  //         s.id: (s.name?.trim().isNotEmpty == true ? s.name!.trim() : s.id),
  //     };

  //     setState(() {
  //       _events = onlyThisGroup;
  //       _clientNames = clientNames;
  //       _serviceNames = serviceNames;
  //       _loading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _error = e.toString();
  //       _loading = false;
  //     });
  //   }
  // }

  DateTime _endExclusive(DateTime d) =>
      DateTime(d.year, d.month, d.day).add(const Duration(days: 1));

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final userMgmt = context.read<UserManagement>();
      final range = _resolveRange(DateTime.now());

      // ⚠️ Use end-exclusive to include the whole last day in the backend query
      final endExclusive = _endExclusive(range.end);

      // 1) Fetch events from the unified agenda endpoint
      final eventsFuture = userMgmt.fetchWorkItems(
        groupId: widget.group.id,
        from: range.start,
        to: endExclusive, // ← end-exclusive
        types: const ['work_visit', 'work_service'],
      );

      // 2) In parallel, fetch catalogs for names (nice labels)
      final clientsApi = ClientsApi();
      final servicesApi = ServiceApi();
      final clientsFuture =
          clientsApi.list(groupId: widget.group.id, active: null);
      final servicesFuture =
          servicesApi.list(groupId: widget.group.id, active: null);

      final results =
          await Future.wait([eventsFuture, clientsFuture, servicesFuture]);

      final events = results[0] as List<Event>;
      final clients = results[1] as List<dynamic>;
      final services = results[2] as List<dynamic>;

      // (Optional) guard if backend ever returns other groups by mistake
      final onlyThisGroup =
          events.where((e) => e.groupId == widget.group.id).toList();

      // Build ID → name maps
      final clientNames = <String, String>{
        for (final c in clients)
          c.id: (c.name?.trim().isNotEmpty == true ? c.name!.trim() : c.id),
      };
      final serviceNames = <String, String>{
        for (final s in services)
          s.id: (s.name?.trim().isNotEmpty == true ? s.name!.trim() : s.id),
      };

      setState(() {
        _events = onlyThisGroup;
        _clientNames = clientNames;
        _serviceNames = serviceNames;
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
      final end = (e.endDate).toLocal();

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

  Map<String, int> _sortDesc(Map<String, int> m) {
    final entries = m.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {for (final e in entries) e.key: e.value};
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final range = _resolveRange(DateTime.now());
    final minutesById = _aggregateMinutes(_dimension, range);
    final minutesLabeled = _sortDesc(_applyLabels(minutesById));
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
                      minutesByKey:
                          minutesLabeled, // 👈 human-readable names now
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
