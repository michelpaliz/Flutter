// lib/c-frontend/b-calendar-section/screens/agenda/widgets/agenda_header.dart
import 'package:calendar_app_frontend/a-models/group_model/agenda/agenda_model.dart';
import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/c-frontend/utils/user_avatar.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AgendaHeader extends StatelessWidget {
  final List<AgendaItem> items;
  final int daysRange;
  final VoidCallback onExpandRange;
  final VoidCallback onRefresh;
  final bool showGreeting;

  const AgendaHeader({
    super.key,
    required this.items,
    required this.daysRange,
    required this.onExpandRange,
    required this.onRefresh,
    this.showGreeting = false,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface.withOpacity(.7);
    final loc = AppLocalizations.of(context)!;

    final total = items.length;
    final done = items.where(_isDone).length;
    final donePct = total == 0 ? 0.0 : done / total;
    final bars = _barsLast7Days(items);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ValueListenableBuilder<User?>(
                valueListenable:
                    context.read<UserManagement>().currentUserNotifier,
                builder: (context, user, _) {
                  if (user == null) {
                    return CircleAvatar(
                      radius: 26,
                      child: Icon(Icons.person,
                          color: Theme.of(context).colorScheme.onPrimary),
                    );
                  }
                  return UserAvatar(
                    user: user,
                    fetchReadSas: (_) async => null,
                    radius: 26,
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showGreeting)
                      ValueListenableBuilder<User?>(
                        valueListenable:
                            context.read<UserManagement>().currentUserNotifier,
                        builder: (context, user, _) {
                          final greeting = (user == null || user.name.isEmpty)
                              ? loc.hi
                              : '${loc.hi}, ${user.name}';
                          return Text(
                            greeting,
                            style: Theme.of(context).textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    if (showGreeting) const SizedBox(height: 4),
                    Text(
                      loc.completedSummary(
                          done, total, (donePct * 100).round()),
                      style: TextStyle(color: onSurface, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Days toggle + Refresh side by side
              Wrap(
                spacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TextButton(
                    onPressed: onExpandRange,
                    child: Text(
                      daysRange >= 30
                          ? loc.showFourteenDays
                          : loc.showThirtyDays,
                    ),
                  ),
                  IconButton(
                    tooltip: loc.refresh,
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: onRefresh,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MiniBars(values: bars),
        ],
      ),
    );
  }

  bool _isDone(AgendaItem it) {
    final e = it.event;
    if (e.isDone == true) return true;
    if (e.completedAt != null) return true;
    final s = (e.status ?? '').toLowerCase();
    return s == 'done' || s == 'completed' || s == 'finished';
  }

  List<double> _barsLast7Days(List<AgendaItem> items) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));
    final buckets = List<int>.filled(7, 0);
    final totals = List<int>.filled(7, 0);

    for (final it in items) {
      final d = DateTime(
        it.event.startDate.year,
        it.event.startDate.month,
        it.event.startDate.day,
      );
      if (d.isBefore(start)) continue;
      final idx = d.difference(start).inDays.clamp(0, 6);
      totals[idx] += 1;
      if (_isDone(it)) buckets[idx] += 1;
    }
    return List<double>.generate(7, (i) {
      final t = totals[i];
      return t == 0 ? 0 : buckets[i] / t;
    });
  }
}

class _MiniBars extends StatelessWidget {
  final List<double> values;
  const _MiniBars({required this.values});

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surfaceVariant;
    final fill = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        height: 56,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(values.length, (i) {
            final h = (values[i].clamp(0.0, 1.0)) * 46 + 6;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  height: h,
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
