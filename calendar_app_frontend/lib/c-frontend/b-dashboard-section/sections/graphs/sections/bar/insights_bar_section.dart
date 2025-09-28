import 'dart:math' as math;
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class InsightsBarsCard extends StatelessWidget {
  final String title;
  final Map<String, int> minutesByKey; // key = clientId/serviceId (or name)

  const InsightsBarsCard({
    super.key,
    required this.title,
    required this.minutesByKey,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final entries = minutesByKey.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(10).toList();
    final maxVal = top.isEmpty ? 0 : top.map((e) => e.value).reduce(math.max);

    String fmt(int minutes) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      if (h == 0) return '${m}m';
      if (m == 0) return '${h}h';
      return '${h}h ${m}m';
    }

    return Card(
      elevation: 0,
      color: cs.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            if (top.isEmpty)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(l.noDataRange,
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
              )
            else
              ...top.map((e) {
                final label = e.key; // map IDs to human names upstream if desired
                final minutes = e.value;
                final factor = maxVal == 0 ? 0.0 : minutes / maxVal;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              height: 28,
                              decoration: BoxDecoration(
                                color: cs.onSurface.withOpacity(.06),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: factor.clamp(0.0, 1.0),
                              child: Container(
                                height: 28,
                                decoration: BoxDecoration(
                                  color: cs.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: tt.bodyMedium?.copyWith(
                                      color: cs.onPrimary.withOpacity(.95),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 64,
                        child: Text(
                          fmt(minutes),
                          textAlign: TextAlign.right,
                          style: tt.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
