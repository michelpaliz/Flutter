import 'package:calendar_app_frontend/c-frontend/utils/user_avatar.dart';
import 'package:calendar_app_frontend/e-drawer-style-menu/main_scaffold.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../a-models/user_model/user.dart';
import '../../../../../d-stateManagement/group/group_management.dart';
import '../../../../../d-stateManagement/user/user_management.dart';
import '../../../../routes/appRoutes.dart';
import 'controller/list_group_controller.dart';
import 'group_body_builder/group_body_builder.dart';

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
    if (_initialized) return;
    _initialized = true;

    _userManagement = Provider.of<UserManagement>(context, listen: false);
    _groupManagement = Provider.of<GroupManagement>(context, listen: false);
  }

  void _toggleScrollDirection() {
    setState(() {
      _scrollDirection =
          _scrollDirection == Axis.vertical ? Axis.horizontal : Axis.vertical;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserNotifier =
        Provider.of<UserManagement>(context).currentUserNotifier;

    return ValueListenableBuilder<User?>(
      valueListenable: currentUserNotifier,
      builder: (context, user, _) {
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!_hasFetchedGroups) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            GroupController.fetchGroups(user, _groupManagement);
          });
          _hasFetchedGroups = true;
        }

        final loc = AppLocalizations.of(context)!;

        return MainScaffold(
          title: '',
          titleWidget: _AppBarUserTitle(user: user),
          actions: [
            // 🔄 Refresh
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: loc.refresh,
              onPressed: () {
                GroupController.fetchGroups(user, _groupManagement);
                setState(() {});
              },
            ),
            // ⚙️ Settings (moved here; removed duplicate notifications bell)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: loc.settings,
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.settings);
              },
            ),
          ],
          body: buildBody(
            context,
            _scrollDirection,
            _toggleScrollDirection,
            user,
            _userManagement,
            _groupManagement,
            (String? role) {},
          ),
          // No per-screen FAB: ContextualFab handles it globally
        );
      },
    );
  }
}

class _AppBarUserTitle extends StatelessWidget {
  final User user;
  const _AppBarUserTitle({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = (user.name.isNotEmpty ? user.name : user.userName);

    final nameStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: Theme.of(context).colorScheme.onSurface,
        );

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          UserAvatar(
            user: user,
            fetchReadSas: (_) async => null, // public avatars
            radius: 22,
          ),
          const SizedBox(width: 16),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.55,
            ),
            child: Text(
              name,
              style: nameStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
