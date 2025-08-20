// agenda_screen.dart
import 'package:calendar_app_frontend/a-models/group_model/agenda/agenda.dart';
import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/b-backend/api/auth/auth_database/auth_provider.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
import 'package:calendar_app_frontend/f-themes/themes/theme_colors.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  late final ApiAgendaRepository _repo;
  List<AgendaItem> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Expect a provided http.Client higher in the tree; if not, you can pass a new http.Client().
    _repo = ApiAgendaRepository(Provider.of(context, listen: false));
    _loadAgenda();
  }

Future<void> _loadAgenda() async {
  try {
    final auth = context.read<AuthProvider>();
    final userMgmt = context.read<UserManagement>();
    final User? user = userMgmt.user; // allow null

    if (user == null) {
      setState(() {
        _loading = false;
        _error = 'No user loaded';
      });
      return;
    }

    final token = auth.lastToken;
    if (token == null) {
      setState(() {
        _loading = false;
        _error = 'Not authenticated';
      });
      return;
    }

    final events = await _repo.fetchEventsByIds(
      ids: user.events,
      accessToken: token,
    );

    final items = buildAgendaItems(events, Theme.of(context));

    setState(() {
      _items = items;
      _loading = false;
      _error = null;
    });
  } catch (e) {
    setState(() {
      _loading = false;
      _error = e.toString();
    });
  }
}


  @override
  Widget build(BuildContext context) {
    final bg = ThemeColors.getLighterInputFillColor(context);
    final text = ThemeColors.getTextColor(context);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.agenda ?? 'Agenda'),
        actions: [
          IconButton(
            tooltip: loc?.refresh ?? 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() => _loading = true);
              _loadAgenda();
            },
          )
        ],
      ),
      backgroundColor: bg,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: text)))
              : _items.isEmpty
                  ? Center(child: Text(loc?.noItems ?? 'Nothing upcoming', style: TextStyle(color: text)))
                  : RefreshIndicator(
                      onRefresh: _loadAgenda,
                      child: _AgendaList(items: _items),
                    ),
    );
  }
}

class _AgendaList extends StatelessWidget {
  final List<AgendaItem> items;
  const _AgendaList({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final curr = items[i];
        final showHeader = (i == 0) ||
            !_sameDay(items[i - 1].event.startDate, curr.event.startDate);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showHeader) _DateHeader(date: curr.event.startDate),
            _AgendaTile(item: curr),
          ],
        );
      },
    );
  }
}

class _AgendaTile extends StatelessWidget {
  final AgendaItem item;
  const _AgendaTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final e = item.event;
    final start = e.startDate.toLocal();
    final end = e.endDate.toLocal();

    final timeStr = _formatTimeRange(context, start, e.allDay ? null : end);
    final secondary = [
      if (item.groupName != null) item.groupName!,
      if (e.localization?.isNotEmpty == true) e.localization!,
    ].join(' • ').replaceFirst(RegExp(r'^ • '), '');

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.color,
          child: const Icon(Icons.event_rounded, color: Colors.white),
        ),
        title: Text(e.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          secondary.isEmpty ? timeStr : '$timeStr • $secondary',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          // TODO: deep-link to event or its group calendar
        },
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final DateTime date;
  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final dLocal = date.toLocal();
    final now = DateTime.now();
    final isToday = _sameDay(dLocal, now);
    final isTomorrow = _sameDay(dLocal, now.add(const Duration(days: 1)));

    final label = isToday
        ? (loc?.today ?? 'Today')
        : isTomorrow
            ? (loc?.tomorrow ?? 'Tomorrow')
            : DateFormat.yMMMMEEEEd().format(dLocal);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Text(label, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

// helpers
bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _formatTimeRange(BuildContext context, DateTime start, DateTime? end) {
  final ml = MaterialLocalizations.of(context);
  final s = ml.formatTimeOfDay(TimeOfDay.fromDateTime(start), alwaysUse24HourFormat: true);
  if (end == null) return s;
  final e = ml.formatTimeOfDay(TimeOfDay.fromDateTime(end), alwaysUse24HourFormat: true);
  return '$s – $e';
}
