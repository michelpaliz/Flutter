// group_list_section.dart
import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/b-backend/group_mng_flow/group/domain/group_domain.dart';
import 'package:hexora/b-backend/auth_user/user/domain/user_domain.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/group/show-groups/group_card_widget/group_card_widget.dart';
import 'package:hexora/l10n/app_localizations.dart';
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
    final userDomain = context.watch<UserDomain>();
    final groupDomain = context.watch<GroupDomain>();
    final ValueNotifier<User?> currentUserNotifier =
        userDomain.currentUserNotifier;

    return ValueListenableBuilder<User?>(
      valueListenable: currentUserNotifier,
      builder: (context, user, _) {
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return StreamBuilder<List<Group>>(
          key: ValueKey('groups-${user.id}'), // forces rebuild on user change
          stream:
              groupDomain.watchGroupsForUser(user.id), // ⬅️ user-scoped stream
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
                      userDomain: userDomain,
                      groupDomain: groupDomain,
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
  final UserDomain userDomain;
  final GroupDomain groupDomain;
  final void Function(String?) updateRole;

  const _GroupListView({
    required this.groups,
    required this.axis,
    required this.currentUser,
    required this.userDomain,
    required this.groupDomain,
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
          userDomain,
          groupDomain,
          updateRole,
        );
      },
    );
  }
}
