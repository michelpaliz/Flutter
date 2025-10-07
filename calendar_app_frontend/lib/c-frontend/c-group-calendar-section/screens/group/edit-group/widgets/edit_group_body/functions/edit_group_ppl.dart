// lib/.../edit-group/widgets/edit_group_body/functions/edit_group_ppl.dart
import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/a-models/notification_model/userInvitation_status.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/b-backend/core/group/domain/group_domain.dart';
import 'package:hexora/b-backend/core/group/view_model/group_view_model.dart';
import 'package:hexora/b-backend/login_user/user/domain/user_domain.dart';
import 'package:hexora/b-backend/notification/domain/notification_domain.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/group/edit-group/widgets/edit_group_body/functions/admin_filter_sections.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/utils/shared/add_user_button.dart';
import 'package:hexora/l10n/app_localizations.dart';

import '../../user_list_section.dart';

/// Stable keys for the filter chips. AdminWithFiltersSection can later emit these directly.
/// For now we also adapt from localized String labels → enum in _resolveFilter().
enum InviteFilter { accepted, pending, notAccepted, newUsers, expired }

class EditGroupPeople extends StatefulWidget {
  final Group group;
  final List<User> initialUsers; // incoming snapshot
  final UserDomain userDomain;
  final GroupDomain groupDomain;
  final NotificationDomain notificationDomain;

  const EditGroupPeople({
    Key? key,
    required this.group,
    required this.initialUsers,
    required this.userDomain,
    required this.groupDomain,
    required this.notificationDomain,
  }) : super(key: key);

  @override
  EditGroupPeopleState createState() => EditGroupPeopleState();
}

class EditGroupPeopleState extends State<EditGroupPeople> {
  // Controller only for AddUser dialog search/flow
  late GroupViewModel _controller;

  // Local, temporary state (NOT persisted until Save)
  late List<User> _localUsers; // working members
  late Map<String, String> _localRoles; // username -> role
  late Map<String, UserInviteStatus> _localInvitedUsers; // working invites
  final Map<String, User> _newUsers = {}; // added in this session

  // Filters
  bool showAccepted = true;
  bool showPending = true;
  bool showNotWantedToJoin = true;
  bool showNewUsers = true;
  bool showExpired = true;

  late User? _currentUser;
  late String _currentUserRoleValue;

  @override
  void initState() {
    super.initState();
    _controller = GroupViewModel();

    _currentUser = widget.userDomain.user;

    // Clone incoming data into local working copies
    _localUsers = List<User>.from(widget.initialUsers);
    _localRoles = Map<String, String>.from(widget.group.userRoles);
    _localInvitedUsers =
        Map<String, UserInviteStatus>.from(widget.group.invitedUsers ?? {});

    _controller.initialize(
      user: _currentUser!,
      userDomain: widget.userDomain,
      groupDomain: widget.groupDomain,
      notificationDomain: widget.notificationDomain,
      context: context,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loc = AppLocalizations.of(context)!;
    _currentUserRoleValue = _currentUser!.id == widget.group.ownerId
        ? loc.administrator
        : widget.group.userRoles[_currentUser!.userName] ?? loc.member;
  }

  // Called by AddUser dialog
  void _onNewUserAdded(User user) {
    setState(() {
      final uname = user.userName;
      final existsInMembers = _localUsers.any((u) => u.userName == uname);
      final existsInInvites = _localInvitedUsers.containsKey(uname);
      if (existsInMembers || existsInInvites) return;

      // Generate a stable local id. Use your backend id if you have one.
      final inviteId =
          'grp:${widget.group.id}|user:$uname|ts:${DateTime.now().millisecondsSinceEpoch}';

      _localInvitedUsers[uname] = UserInviteStatus(
        id: inviteId,
        invitationAnswer: null, // no answer yet
        role: 'Member',
        sendingDate: DateTime.now(), // must be DateTime
        informationStatus: 'pending', // normalized for filtering
        attempts: 0, // first attempt
        status: 'Unresolved', // initial business status
      );

      // Optional: if you also want a “New users” chip/card, uncomment:
      // _newUsers[uname] = user;

      // Do NOT add to _localUsers — not a member until accepted.
      // Do NOT touch _localRoles here.
    });
  }

  Map<String, User> get _filteredNewUsers => showNewUsers ? _newUsers : {};

  // ✅ Expose final values to parent (EditGroupBody reads these on Save)
  List<User> getFinalUsers() => List<User>.from(_localUsers);
  Map<String, String> getFinalRoles() => Map<String, String>.from(_localRoles);
  Map<String, UserInviteStatus> getFinalInvites() =>
      Map<String, UserInviteStatus>.from(_localInvitedUsers);

  /// Accept either an InviteFilter enum OR a localized label String and resolve to the enum.
  InviteFilter? _resolveFilter(dynamic filter) {
    if (filter is InviteFilter) return filter;
    if (filter is! String) return null;

    final loc = AppLocalizations.of(context)!;
    String norm(String s) =>
        s.trim().toLowerCase().replaceAll(RegExp(r'[\s_\-]'), '');

    final f = norm(filter);

    if (f == norm(loc.accepted) || f == 'accepted')
      return InviteFilter.accepted;
    if (f == norm(loc.pending) || f == 'pending') return InviteFilter.pending;
    if (f == norm(loc.notAccepted) || f == 'notaccepted' || f == 'declined') {
      return InviteFilter.notAccepted;
    }
    if (f == norm(loc.newUsers) || f == 'newusers')
      return InviteFilter.newUsers;
    if (f == norm(loc.expired) || f == 'expired') return InviteFilter.expired;

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isAdmin = _currentUser!.id == widget.group.ownerId ||
        _currentUserRoleValue == loc.administrator;

    return Column(
      children: [
        AddUserButtonDialog(
          currentUser: widget.userDomain.user,
          group: widget.group,
          controller: _controller,
          onUserAdded: _onNewUserAdded,
        ),
        const SizedBox(height: 12),

        if (isAdmin)
          AdminWithFiltersSection(
            currentUser: _currentUser!,
            showAccepted: showAccepted,
            showPending: showPending,
            showNotWantedToJoin: showNotWantedToJoin,
            showNewUsers: showNewUsers,
            showExpired: showExpired,
            // Accepts either InviteFilter (preferred) or String label (legacy)
            onFilterChange: (filter, isSelected) {
              final resolved = _resolveFilter(filter);
              if (resolved == null) {
                // print('⚠️ Unknown filter: $filter');
                return;
              }
              setState(() {
                switch (resolved) {
                  case InviteFilter.accepted:
                    showAccepted = isSelected;
                    break;
                  case InviteFilter.pending:
                    showPending = isSelected;
                    break;
                  case InviteFilter.notAccepted:
                    showNotWantedToJoin = isSelected;
                    break;
                  case InviteFilter.newUsers:
                    showNewUsers = isSelected;
                    break;
                  case InviteFilter.expired:
                    showExpired = isSelected;
                    break;
                }
              });
              // Debug:
              // print('🎛 Filters → A:$showAccepted P:$showPending D:$showNotWantedToJoin N:$showNewUsers X:$showExpired');
            },
          ),

        const SizedBox(height: 12),

        // Render from LOCAL working copies
        UserListSection(
          newUsers: _filteredNewUsers,
          usersRoles: _localRoles,
          usersInvitations: _localInvitedUsers,
          usersInvitationAtFirst: widget.group.invitedUsers ?? {},
          group: widget.group,
          usersInGroup: _localUsers,
          userDomain: widget.userDomain,
          groupDomain: widget.groupDomain,
          notificationDomain: widget.notificationDomain,
          showPending: showPending,
          showAccepted: showAccepted,
          showNotWantedToJoin: showNotWantedToJoin,
          showNewUsers: showNewUsers,
          showExpired: showExpired,
          onChangeRole: (userName, newRole) {
            setState(() => _localRoles[userName] = newRole);
          },
          onUserRemoved: (userName) {
            setState(() {
              _newUsers.remove(userName);
              _localUsers.removeWhere((u) => u.userName == userName);
              _localRoles.remove(userName);
              _localInvitedUsers.remove(userName);
            });
          },
        ),
      ],
    );
  }
}
