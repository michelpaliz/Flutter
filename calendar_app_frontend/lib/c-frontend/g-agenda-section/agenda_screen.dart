// lib/c-frontend/b-calendar-section/screens/agenda/agenda_screen.dart
import 'package:calendar_app_frontend/a-models/group_model/agenda/agenda_model.dart';
import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/c-frontend/g-agenda-section/agenda_body.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
import 'package:calendar_app_frontend/e-drawer-style-menu/main_scaffold.dart';
import 'package:calendar_app_frontend/f-themes/themes/theme_colors.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  bool _loading = true;
  String? _error;
  List<AgendaItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadAgenda();
  }

  Future<void> _loadAgenda() async {
    try {
      final userMgmt = context.read<UserManagement>();
      final List<Event> events =
          await userMgmt.fetchAgendaUpcoming(days: 14, limit: 200);

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

  @override
  Widget build(BuildContext context) {
    final bg = ThemeColors.getLighterInputFillColor(context);
    final text = ThemeColors.getTextColor(context);
    final loc = AppLocalizations.of(context);

    return MainScaffold(
      // 👆 use MainScaffold so your drawer/menu appears
      title: loc?.agenda ?? 'Agenda',
      actions: [
        IconButton(
          tooltip: loc?.refresh ?? 'Refresh',
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () {
            setState(() => _loading = true);
            _loadAgenda();
          },
        ),
      ],
      body: Container(
        color: bg,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!, style: TextStyle(color: text)))
                : _items.isEmpty
                    ? Center(
                        child: Text(
                          loc?.noItems ?? 'Nothing upcoming',
                          style: TextStyle(color: text),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadAgenda,
                        child: AgendaBody(items: _items),
                      ),
      ),
    );
  }
}
