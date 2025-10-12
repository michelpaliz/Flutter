// lib/.../calendar/main_calendar_view.dart
import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/b-backend/group_mng_flow/group/domain/group_domain.dart';
import 'package:hexora/b-backend/auth_user/user/domain/user_domain.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/calendar/calendar_main_view/logic/calendar_screen_controller.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/calendar/calendar_main_view/utils/add_event_cta.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/calendar/calendar_main_view/utils/group_permissions_helper.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/calendar/calendar_main_view/utils/presence_status_strip.dart';
import 'package:provider/provider.dart';

class MainCalendarView extends StatefulWidget {
  final Group? group;
  const MainCalendarView({super.key, this.group});

  @override
  State<MainCalendarView> createState() => _MainCalendarViewState();
}

class _MainCalendarViewState extends State<MainCalendarView> {
  late final CalendarScreenController _c;

  @override
  void initState() {
    super.initState();
    _c = CalendarScreenController(context: context);

    // Defer heavy work; when done, force a rebuild so the spinner disappears.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    try {
      await _c.initSockets();
      await _c.loadData(initialGroup: widget.group);
    } finally {
      if (mounted) setState(() {}); // <-- trigger rebuild when loading is done
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupDomain = context.watch<GroupDomain>();
    final userDomain = context.watch<UserDomain>();
    final currentUser = userDomain.user;
    final currentGroup = groupDomain.currentGroup;

    if (_c.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (currentUser == null || currentGroup == null) {
      return const Scaffold(body: Center(child: Text('No group available')));
    }

    final canAddEvents =
        GroupPermissionHelper.canAddEvents(currentUser, currentGroup);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(currentGroup.name)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              PresenceStatusStrip(group: currentGroup, controller: _c),
              const SizedBox(height: 10),
              Expanded(
                child:
                    _c.calendarUI?.buildCalendar(context) ?? const SizedBox(),
              ),
              if (canAddEvents)
                AddEventCta(
                  onPressed: () =>
                      _c.handleAddEventPressed(context, currentGroup),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }
}
