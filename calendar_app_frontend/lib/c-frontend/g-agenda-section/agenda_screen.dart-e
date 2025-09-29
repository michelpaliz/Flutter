import 'package:calendar_app_frontend/a-models/group_model/agenda/agenda_model.dart';
import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/c-frontend/g-agenda-section/sections/agenda_filters_section.dart';
import 'package:calendar_app_frontend/c-frontend/g-agenda-section/sections/agenda_header_section.dart';
import 'package:calendar_app_frontend/c-frontend/g-agenda-section/sections/agenda_list_section.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
import 'package:calendar_app_frontend/e-drawer-style-menu/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AgendaScreen extends StatefulWidget {
  final String? groupId;

  const AgendaScreen({super.key, this.groupId});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  bool _loading = true;
  String? _error;
  List<AgendaItem> _items = [];
  int _daysRange = 14;

  /// Category filter token:
  /// - 'all'
  /// - 'cat:<categoryId>'
  /// - 'sub:<subcategoryId>'
  String _category = 'all';

  /// Type filter token from chips: 'all' | 'simple' | 'work_service'
  /// (Backend may use 'work_visit'; we normalize below.)
  String _type = 'all';

  /// Show category filter UI only if type is "simple"
  bool get _showCategories => _type == 'simple';

  /// Normalize/recognize "work" both as work_service (UI) and work_visit (DB)
  bool _isWorkToken(String v) {
    final t = v.toLowerCase();
    return t == 'work_service' || t == 'work_visit';
  }

  bool _isWorkEvent(AgendaItem it) => _isWorkToken(it.event.type);

  @override
  void initState() {
    super.initState();
    _loadAgenda();
  }

  /// Loads events from backend
  Future<void> _loadAgenda() async {
    try {
      final userMgmt = context.read<UserManagement>();
      final List<Event> events =
          await userMgmt.fetchAgendaUpcoming(days: _daysRange, limit: 300);

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

  /// Applies group, type, and category filters to agenda items
  List<AgendaItem> _applyAllFilters(List<AgendaItem> all) {
    Iterable<AgendaItem> out = all;

    // 1) Optional group filter
    if (widget.groupId?.isNotEmpty ?? false) {
      out = out.where((it) => it.event.groupId == widget.groupId);
    }

    // 2) Category filter — ONLY applied when type == 'simple'
    if (_type == 'simple') {
      final token = _category.toLowerCase();
      if (token != 'all') {
        if (token.startsWith('cat:')) {
          final id = token.substring(4);
          out = out.where(
            (it) => (it.event.categoryId ?? '').toLowerCase() == id,
          );
        } else if (token.startsWith('sub:')) {
          final id = token.substring(4);
          out = out.where(
            (it) => (it.event.subcategoryId ?? '').toLowerCase() == id,
          );
        } else {
          out = const <AgendaItem>[];
        }
      }
    }

    // 3) Type filter — accept both 'work_service' (UI) and 'work_visit' (backend)
    if (_type == 'simple') {
      out = out.where((it) => it.event.type.toLowerCase() == 'simple');
    } else if (_isWorkToken(_type)) {
      out = out.where(_isWorkEvent);
    }

    return out.toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _applyAllFilters(_items);

    return MainScaffold(
      showAppBar: false,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _loadAgenda,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      /// HEADER SECTION (use filtered so it matches chips)
                      AgendaHeaderSection(
                        items: filtered,
                        daysRange: _daysRange,
                        onToggleDays: () {
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
                      ),

                      /// FILTERS SECTION
                      AgendaFiltersSection(
                        category: _category,
                        type: _type,
                        showCategories: _showCategories,
                        onCategoryChanged: (c) => setState(() => _category = c),
                        onTypeChanged: (t) => setState(() {
                          _type = t;
                          // Reset category when leaving "Simple"
                          if (_type != 'simple') _category = 'all';
                        }),
                      ),

                      /// LIST SECTION
                      AgendaListSection(filteredItems: filtered),
                    ],
                  ),
                ),
    );
  }
}
