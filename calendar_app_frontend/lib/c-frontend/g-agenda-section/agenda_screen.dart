// lib/c-frontend/b-calendar-section/screens/agenda/agenda_screen.dart
import 'package:calendar_app_frontend/a-models/group_model/agenda/agenda_model.dart';
import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/c-frontend/g-agenda-section/widgets/agenda_sliver.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
import 'package:calendar_app_frontend/e-drawer-style-menu/main_scaffold.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/agenda_categories.dart';
import 'widgets/agenda_header.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});
  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  bool _loading = true;
  String? _error;
  List<AgendaItem> _items = [];
  int _daysRange = 14;

  /// Filter token:
  ///   - 'all'
  ///   - 'cat:<categoryId>'
  ///   - 'sub:<subcategoryId>'
  String _category = 'all';

  @override
  void initState() {
    super.initState();
    _loadAgenda();
  }

  Future<void> _loadAgenda() async {
    try {
      final userMgmt = context.read<UserManagement>();
      final List<Event> events =
          await userMgmt.fetchAgendaUpcoming(days: _daysRange, limit: 200);

      setState(() {
        _items = buildAgendaItems(events, Theme.of(context));
        _error = null;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<AgendaItem> _applyCategory(List<AgendaItem> all) {
    final token = _category.toLowerCase();
    if (token == 'all') return all;

    if (token.startsWith('cat:')) {
      final id = token.substring(4);
      return all
          .where((it) => (it.event.categoryId ?? '').toLowerCase() == id)
          .toList();
    }
    if (token.startsWith('sub:')) {
      final id = token.substring(4);
      return all
          .where((it) => (it.event.subcategoryId ?? '').toLowerCase() == id)
          .toList();
    }

    // unknown token → no items
    return const <AgendaItem>[];
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final filtered = _applyCategory(_items);

    return MainScaffold(
      showAppBar: false,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorMessage(_error!)
              : RefreshIndicator(
                  onRefresh: _loadAgenda,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 28),
                          child: AgendaHeader(
                            items: _items,
                            daysRange: _daysRange,
                            onExpandRange: () {
                              setState(() {
                                _daysRange = _daysRange >= 30 ? 14 : 30;
                                _loading = true;
                              });
                              _loadAgenda();
                            },
                            onRefresh: () {
                              setState(() => _loading = true);
                              _loadAgenda();
                            },
                            showGreeting: false,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 8)),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AgendaCategories(
                            selected: _category,
                            // must pass: 'all' | 'cat:<id>' | 'sub:<id>'
                            onSelected: (c) => setState(() => _category = c),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 8)),
                      if (filtered.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: _EmptyHint(
                              message: loc?.noItems ?? 'Nothing upcoming in this view',
                              sub: loc?.noUpcomingHint ??
                                  'Try another category or extend the range.',
                            ),
                          ),
                        )
                      else
                        AgendaListSliver(items: filtered),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                  ),
                ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final String error;
  const _ErrorMessage(this.error);

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface.withOpacity(.8);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(error, style: TextStyle(color: onSurface)),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String message;
  final String? sub;
  const _EmptyHint({required this.message, this.sub});

  @override
  Widget build(BuildContext context) {
    final onSurfaceVar = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      children: [
        const SizedBox(height: 24),
        Icon(Icons.event_busy_rounded,
            size: 48, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 12),
        Text(message, style: Theme.of(context).textTheme.titleMedium),
        if (sub != null) ...[
          const SizedBox(height: 6),
          Text(sub!, textAlign: TextAlign.center, style: TextStyle(color: onSurfaceVar)),
        ],
      ],
    );
  }
}
