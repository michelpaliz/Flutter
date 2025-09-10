// group_list_section.dart
import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/c-frontend/c-calendar-section/screens/group-screen/show-groups/group_card_widget/group_card_widget.dart';
import 'package:calendar_app_frontend/d-stateManagement/group/group_management.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupListSection extends StatefulWidget {
  GroupListSection({Key? key}) : super(key: key);

  /// quick-and-lightweight way to control axis from HomePage toggle
  static final ValueNotifier<Axis> axisOverride = ValueNotifier(Axis.vertical);

  @override
  State<GroupListSection> createState() => _GroupListSectionState();
}

class _GroupListSectionState extends State<GroupListSection> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final userMgmt = context.watch<UserManagement>();
    final groupMgmt = context.watch<GroupManagement>();
    final ValueNotifier<User?> currentUserNotifier =
        userMgmt.currentUserNotifier;

    return ValueListenableBuilder<User?>(
      valueListenable: currentUserNotifier,
      builder: (context, user, _) {
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return StreamBuilder<List<Group>>(
          stream: groupMgmt.groupStream,
          builder: (context, snapshot) {
            // devtools.log('StreamBuilder state: ${snapshot.connectionState}');
            // devtools.log('StreamBuilder data: ${snapshot.data}');
            // devtools.log('StreamBuilder error: ${snapshot.error}');

            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return _ErrorText('Error: ${snapshot.error}');
            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
              return _NoGroupsText(loc.noGroupsAvailable);
            } else if (snapshot.hasData) {
              final groups = snapshot.data!;
              return ValueListenableBuilder<Axis>(
                valueListenable: GroupListSection.axisOverride,
                builder: (context, axis, __) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _GroupListView(
                      groups: groups,
                      axis: axis,
                      currentUser: user,
                      userManagement: userMgmt,
                      groupManagement: groupMgmt,
                      updateRole: (String? role) {},
                    ),
                  );
                },
              );
            } else {
              return _NoGroupsText(loc.noGroupsAvailable);
            }
          },
        );
      },
    );
  }
}

class _NoGroupsText extends StatelessWidget {
  final String text;
  const _NoGroupsText(this.text);

  @override
  Widget build(BuildContext context) => Center(
      child:
          Text(text, style: const TextStyle(fontSize: 16, color: Colors.grey)));
}

class _ErrorText extends StatelessWidget {
  final String text;
  const _ErrorText(this.text);

  @override
  Widget build(BuildContext context) => Center(
      child:
          Text(text, style: const TextStyle(fontSize: 16, color: Colors.red)));
}

class _GroupListView extends StatelessWidget {
  final List<Group> groups;
  final Axis axis;
  final User currentUser;
  final UserManagement userManagement;
  final GroupManagement groupManagement;
  final void Function(String?) updateRole;

  const _GroupListView({
    required this.groups,
    required this.axis,
    required this.currentUser,
    required this.userManagement,
    required this.groupManagement,
    required this.updateRole,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      scrollDirection: axis,
      itemCount: groups.length,
      itemBuilder: (_, index) {
        return buildGroupCard(
          context,
          groups[index],
          currentUser,
          userManagement,
          groupManagement,
          updateRole,
        );
      },
    );
  }
}
