import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/b-backend/auth_user/user/domain/user_domain.dart';
import 'package:hexora/b-backend/group_mng_flow/group/domain/group_domain.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/calendar/utils/add_event_cta.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/calendar/utils/group_permissions_helper.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/calendar/utils/presence_status_strip.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/calendar/presentation/coordinator/calendar_screen_coordinator.dart';
import 'package:hexora/c-frontend/d-event-section/screens/actions/add_screen/screen/add_event_screen.dart';
import 'package:provider/provider.dart';

class MainCalendarView extends StatefulWidget {
  final Group? group;
  const MainCalendarView({super.key, this.group});

  @override
  State<MainCalendarView> createState() => _MainCalendarViewState();
}

class _MainCalendarViewState extends State<MainCalendarView> {
  late final CalendarScreenCoordinator _c;

  // ✅ Guard to prevent re-bootstrap on hot reload or setState
  bool _isBootstrapped = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 [MainCalendarView] initState called');
    _c = CalendarScreenCoordinator(context: context);

    // Only bootstrap once
    if (!_isBootstrapped) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _bootstrap();
      });
    }
  }

  Future<void> _bootstrap() async {
    if (_isBootstrapped) {
      debugPrint('⚠️ [MainCalendarView] Already bootstrapped, skipping');
      return;
    }

    debugPrint('🔄 [MainCalendarView] Starting bootstrap...');
    try {
      await _c.initSockets();
      await _c.loadData(initialGroup: widget.group);
      _isBootstrapped = true; // ✅ Mark as completed
      debugPrint('✅ [MainCalendarView] Bootstrap complete');
    } catch (e, stack) {
      debugPrint('❌ [MainCalendarView] Bootstrap failed: $e\n$stack');
    } finally {
      if (mounted) setState(() {}); // trigger rebuild when loading is done
    }
  }

  @override
  void didUpdateWidget(MainCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('🔄 [MainCalendarView] didUpdateWidget called');

    // Only reload if the group actually changed
    if (oldWidget.group?.id != widget.group?.id) {
      debugPrint('🔄 [MainCalendarView] Group changed, reloading...');
      _isBootstrapped = false;
      _bootstrap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupDomain = context.watch<GroupDomain>();
    final userDomain = context.watch<UserDomain>();

    return ValueListenableBuilder<bool>(
      valueListenable: _c.loading,
      builder: (_, isLoading, __) {
        if (isLoading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final currentUser = userDomain.user;
        final currentGroup = groupDomain.currentGroup;

        if (currentUser == null || currentGroup == null) {
          return const Scaffold(
              body: Center(child: Text('No group available')));
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
                      child: _c.calendarUI?.buildCalendar(context) ??
                          const SizedBox()),
                  if (canAddEvents)
                    AddEventCta(
                      onPressed: () async {
                        final added = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                              builder: (_) =>
                                  AddEventScreen(group: currentGroup)),
                        );
                        if (added == true) {
                          _c.loadData(initialGroup: currentGroup);
                          // no setState needed; ValueNotifier will rebuild
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    debugPrint('🗑️ [MainCalendarView] dispose called');
    _c.dispose();
    super.dispose();
  }
}
