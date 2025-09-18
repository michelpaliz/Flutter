import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
import 'package:calendar_app_frontend/c-frontend/routes/appRoutes.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class GroupUpcomingEventsCard extends StatefulWidget {
  final String groupId;
  final int daysRange;
  final int limit;

  const GroupUpcomingEventsCard({
    super.key,
    required this.groupId,
    this.daysRange = 14,   // same default window as agenda
    this.limit = 5,        // show top N concise items
  });

  @override
  State<GroupUpcomingEventsCard> createState() => _GroupUpcomingEventsCardState();
}

class _GroupUpcomingEventsCardState extends State<GroupUpcomingEventsCard> {
  late Future<List<Event>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Event>> _load() async {
    final userMgmt = context.read<UserManagement>();
    final events = await userMgmt.fetchAgendaUpcoming(
      days: widget.daysRange,
      limit: 200, // fetch a buffer, we'll filter down
    );

    final now = DateTime.now();
    final filtered = events
        .where((e) =>
            (e.groupId == widget.groupId) &&
            e.startDate.isAfter(now.subtract(const Duration(minutes: 1))))
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    return filtered.take(widget.limit).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurfaceVar = theme.colorScheme.onSurfaceVariant;

    return FutureBuilder<List<Event>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const SizedBox(
                      width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 12),
                  Text('Loading upcoming…', style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                snapshot.error.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
              ),
            ),
          );
        }

        final items = snapshot.data ?? const <Event>[];
        if (items.isEmpty) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.event_busy_rounded),
              title: const Text('No upcoming events'),
              subtitle: Text('Nothing scheduled soon for this group.',
                  style: TextStyle(color: onSurfaceVar)),
              trailing: const SizedBox.shrink(),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.upcoming_rounded),
                  title: const Text('Next up'),
                  subtitle: Text('Upcoming events for this group',
                      style: TextStyle(color: onSurfaceVar)),
                  trailing: TextButton(
                    onPressed: () {
                      // “See all” → go to group calendar
                      Navigator.pushNamed(context, AppRoutes.groupCalendar,
                          arguments: _GroupStub(groupId: widget.groupId));
                    },
                    child: const Text('See all'),
                  ),
                ),
                const Divider(height: 1),
                ...items.map((e) => _EventRow(event: e)).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Minimal stub so we can jump to the group calendar without the full Group object.
// If you already have the Group in scope at call-site, pass it in the route instead.
class _GroupStub {
  final String id;
  _GroupStub({required String groupId}) : id = groupId;
}

class _EventRow extends StatelessWidget {
  final Event event;
  const _EventRow({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ml = MaterialLocalizations.of(context);
    final dateStr = ml.formatMediumDate(event.startDate);
    final timeStr =
        '${ml.formatTimeOfDay(TimeOfDay.fromDateTime(event.startDate))} – ${ml.formatTimeOfDay(TimeOfDay.fromDateTime(event.endDate))}';

    return ListTile(
      leading: const Icon(Icons.event_note_outlined),
      title: Text(
        event.title.isEmpty ? '(untitled)' : event.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text('$dateStr · $timeStr', maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.eventDetail, arguments: event);
      },
    );
  }
}
