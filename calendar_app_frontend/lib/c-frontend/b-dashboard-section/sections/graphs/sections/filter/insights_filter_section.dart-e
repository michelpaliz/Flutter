import 'package:calendar_app_frontend/c-frontend/b-dashboard-section/sections/graphs/enum/insights_types.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class InsightsFiltersSection extends StatelessWidget {
  final RangePreset preset;
  final ValueChanged<RangePreset> onPresetChanged;
  final VoidCallback onPickCustom;
  final Dimension dimension;
  final ValueChanged<Dimension> onDimensionChanged;

  // Optional type segment (default hidden)
  final bool showTypeFilter;
  final EventTypeFilter? type;
  final ValueChanged<EventTypeFilter>? onTypeChanged;

  final String rangeText;

  const InsightsFiltersSection({
    super.key,
    required this.preset,
    required this.onPresetChanged,
    required this.onPickCustom,
    required this.dimension,
    required this.onDimensionChanged,
    this.showTypeFilter = false,
    this.type,
    this.onTypeChanged,
    required this.rangeText,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    String labelForPreset(RangePreset p) {
      switch (p) {
        case RangePreset.d7:  return l.dateRange7d;
        case RangePreset.d30: return l.dateRange30d;
        case RangePreset.m3:  return l.dateRange3m;
        case RangePreset.m4:  return l.dateRange4m;
        case RangePreset.m6:  return l.dateRange6m;
        case RangePreset.y1:  return l.dateRange1y;
        case RangePreset.ytd: return l.dateRangeYTD;
        case RangePreset.custom: return l.dateRangeCustom;
      }
    }

    Widget chip(RangePreset p) => ChoiceChip(
          label: Text(labelForPreset(p)),
          selected: preset == p,
          onSelected: (_) => onPresetChanged(p),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date presets
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            chip(RangePreset.d7),
            chip(RangePreset.d30),
            chip(RangePreset.m3),
            chip(RangePreset.m4),
            chip(RangePreset.m6),
            chip(RangePreset.y1),
            chip(RangePreset.ytd),
            ActionChip(label: Text(l.dateRangeCustom), onPressed: onPickCustom),
          ],
        ),
        const SizedBox(height: 12),

        // Scrollable row to avoid overflow
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            children: [
              SegmentedButton<Dimension>(
                segments: [
                  ButtonSegment(
                    value: Dimension.clients,
                    label: Text(l.filterDimensionClients),
                    icon: const Icon(Icons.person_outline),
                  ),
                  ButtonSegment(
                    value: Dimension.services,
                    label: Text(l.filterDimensionServices),
                    icon: const Icon(Icons.design_services_outlined),
                  ),
                ],
                selected: {dimension},
                onSelectionChanged: (s) => onDimensionChanged(s.first),
              ),

              if (showTypeFilter) ...[
                const SizedBox(width: 12),
                SegmentedButton<EventTypeFilter>(
                  segments: [
                    ButtonSegment(value: EventTypeFilter.all,    label: Text(l.filterTypeAll)),
                    ButtonSegment(value: EventTypeFilter.simple, label: Text(l.filterTypeSimple)),
                    ButtonSegment(value: EventTypeFilter.work,   label: Text(l.filterTypeWork)),
                  ],
                  selected: {type!},
                  onSelectionChanged: (s) => onTypeChanged?.call(s.first),
                ),
              ],

              const SizedBox(width: 12),

              // Range label pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  rangeText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ],
    );
  }
}