import 'package:calendar_app_frontend/e-drawer-style-menu/main_scaffold.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../a-models/user_model/user.dart';
import '../../../../../d-stateManagement/group/group_management.dart';
import '../../../../../d-stateManagement/notification/notification_management.dart';
import '../../../../../d-stateManagement/user/user_management.dart';
import '../../../../routes/appRoutes.dart';
import 'controller/list_group_controller.dart';
import 'group_body_builder/group_body_builder.dart';
import 'utils/notification_icon.dart';

/// The `ShowGroups` screen displays a list of groups that the current user belongs to.
///
/// 📌 Features:
/// - Fetches and displays user’s groups (using `GroupController`)
/// - Allows toggling between vertical and horizontal scroll layouts
/// - Provides a Floating Action Button (FAB) to create a new group
/// - Includes a refresh button to manually reload group data
/// - Shows a notification icon in the app bar
///
/// Note:
/// - Navigation to group details or calendar view likely happens within the `buildBody()`
/// - Edit group functionality is not directly handled here

class ShowGroups extends StatefulWidget {
  const ShowGroups({super.key});

  @override
  State<ShowGroups> createState() => _ShowGroupsState();
}

class _ShowGroupsState extends State<ShowGroups> {
  Axis _scrollDirection = Axis.vertical;
  bool _hasFetchedGroups = false;
  bool _initialized = false;

  late UserManagement _userManagement;
  late GroupManagement _groupManagement;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize only once when dependencies become available
    if (_initialized) return;
    _initialized = true;

    _userManagement = Provider.of<UserManagement>(context, listen: false);
    _groupManagement = Provider.of<GroupManagement>(context, listen: false);
  }

  /// Navigates to the Create Group screen
  void _createGroup() {
    Navigator.pushNamed(context, AppRoutes.createGroupData); // ✅ FAB target
  }

  /// Toggles list scroll direction (vertical/horizontal)
  void _toggleScrollDirection() {
    setState(() {
      _scrollDirection =
          _scrollDirection == Axis.vertical ? Axis.horizontal : Axis.vertical;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserNotifier = Provider.of<UserManagement>(
      context,
    ).currentUserNotifier;

    return ValueListenableBuilder<User?>(
      valueListenable: currentUserNotifier,
      builder: (context, user, _) {
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // ✅ Fetch group data once after first frame
        if (!_hasFetchedGroups) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            GroupController.fetchGroups(user, _groupManagement);
          });
          _hasFetchedGroups = true;
        }

        return MainScaffold(
          title: AppLocalizations.of(context)!.groups,
          actions: [
            // 🔄 Refresh button to manually refetch groups
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: AppLocalizations.of(context)!.refresh,
              onPressed: () {
                GroupController.fetchGroups(user, _groupManagement);
                setState(() {}); // Trigger UI refresh
              },
            ),

            // 🔔 Notification bell icon
            buildNotificationIcon(
              context: context,
              userManagement: _userManagement,
              notificationManagement: Provider.of<NotificationManagement>(
                context,
                listen: false,
              ),
            ),
          ],

          // 🧱 Main body: Displays group list (cards or tiles likely)
          // Might contain navigation to calendar when a group is tapped
          body: buildBody(
            context,
            _scrollDirection,
            _toggleScrollDirection,
            user,
            _userManagement,
            _groupManagement,
            (String? role) {}, // Optional role update callback
          ),

          // ➕ Floating Action Button to create a new group
          fab: FloatingActionButton(
            onPressed: _createGroup,
            child: const Icon(Icons.group_add_rounded), // ✅ Create group
          ),
        );
      },
    );
  }
}
