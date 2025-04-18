import 'dart:async';

import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/a-models/notification_model/userInvitation_status.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/c-frontend/b-group-section/screens/edit-group/controllers/group_update_controller.dart';
import 'package:first_project/c-frontend/b-group-section/screens/edit-group/controllers/image_picker_controller.dart';
import 'package:first_project/c-frontend/b-group-section/screens/edit-group/services/group_init_service.dart';
import 'package:first_project/c-frontend/b-group-section/screens/edit-group/widgets/add_people_section.dart';
import 'package:first_project/c-frontend/c-event-section/screens/edit_screen/widgets/group/bottom_nav.dart';
import 'package:first_project/c-frontend/c-event-section/screens/edit_screen/widgets/group/group_description_field.dart';
import 'package:first_project/c-frontend/c-event-section/screens/edit_screen/widgets/group/group_image_field.dart';
import 'package:first_project/c-frontend/c-event-section/screens/edit_screen/widgets/group/group_name_field.dart';
import 'package:first_project/c-frontend/c-event-section/screens/edit_screen/widgets/selected_users/admin_info_card.dart';
import 'package:first_project/c-frontend/c-event-section/screens/edit_screen/widgets/selected_users/user_filter_service.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/notification_management.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'filter_chips_section.dart';
import 'user_list_section.dart';

class EditGroupBody extends StatefulWidget {
  final Group group;
  final List<User> users;
  final UserManagement userManagement;
  final GroupManagement groupManagement;
  final NotificationManagement notificationManagement;

  const EditGroupBody({
    Key? key,
    required this.group,
    required this.users,
    required this.userManagement,
    required this.groupManagement,
    required this.notificationManagement,
  }) : super(key: key);

  @override
  State<EditGroupBody> createState() => _EditGroupBodyState();
}

class _EditGroupBodyState extends State<EditGroupBody> {
  late Group _group;
  late User? _currentUser;
  late Map<String, String> _usersRoles;
  late Map<String, UserInviteStatus> _usersInvitations;
  Map<String, String> _userRolesAtFirst = {};
  Map<String, UserInviteStatus> _usersInvitationAtFirst = {};

  String _groupName = '';
  String _groupDescription = '';
  String _imageURL = '';
  XFile? _selectedImage;
  List<User> _usersInGroup = [];
  List<String> _uniqueNewKeysList = [];
  TextEditingController _descriptionController = TextEditingController();
  bool _showAccepted = true;
  bool _showPending = true;
  bool _showNotWantedToJoin = true;
  bool _addingNewUser = false;
  String _currentUserRoleValue = '';

  @override
  void initState() {
    super.initState();
    _group = widget.group;
    _currentUser = widget.userManagement.user;

    final initService = GroupInitializationService(
      group: _group,
      descriptionController: _descriptionController,
    );

    _groupName = initService.groupName;
    _groupDescription = initService.groupDescription;
    _imageURL = initService.imageURL;
    _usersRoles = initService.usersRoles;
    _usersInvitationAtFirst = initService.usersInvitationAtFirst;
    _usersInvitations = initService.usersInvitations;

    _currentUserRoleValue = _currentUser!.id == _group.ownerId
        ? 'Administrator'
        : _usersInvitations[_currentUser!.userName]?.role ?? 'Member';

    widget.groupManagement.usersInGroupStream.listen((users) {
      setState(() {
        _usersInGroup = users;
      });
    });

    widget.groupManagement.userRolesStream.listen((roles) {
      setState(() {
        _userRolesAtFirst = roles;
      });
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePickerController();
    final pickedImage = await picker.pickImageFromGallery();

    if (pickedImage != null) {
      setState(() {
        _selectedImage = pickedImage;
      });
    }
  }

  void _onDataChanged(
      List<User> updatedUsers, Map<String, String> updatedRoles) {
    final updatedInvitations = {
      for (var user in updatedUsers)
        user.userName: UserInviteStatus(
          id: user.id,
          invitationAnswer: null,
          role: updatedRoles[user.userName] ?? 'Member',
          sendingDate: DateTime.now(),
        )
    };

    final newKeys = updatedInvitations.keys
        .toSet()
        .difference(_usersInvitations.keys.toSet());
    _uniqueNewKeysList = newKeys.toList();

    setState(() {
      _usersRoles = updatedRoles;
      _usersInGroup = updatedUsers;
      _usersInvitations = updatedInvitations;
    });
  }

  void _handleGroupUpdate() async {
    final controller = GroupUpdateController(
      context: context,
      originalGroup: _group,
      groupName: _groupName,
      groupDescription: _groupDescription,
      imageUrl: _imageURL,
      currentUser: _currentUser!,
      userRoles: _usersRoles,
      usersInvitations: _usersInvitations,
      usersInvitationAtFirst: _usersInvitationAtFirst,
      addingNewUser: _addingNewUser,
      userManagement: widget.userManagement,
      groupManagement: widget.groupManagement,
      notificationManagement: widget.notificationManagement,
    );

    await controller.performGroupUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final filteredUserNames = UserFilterService.filterUsers(
      _currentUserRoleValue,
      _currentUser,
      _usersInvitations,
      _showAccepted,
      _showPending,
      _showNotWantedToJoin,
    ).keys;

    final filteredUsers = {
      for (var user in _usersInGroup)
        if (filteredUserNames.contains(user.userName)) user.userName: user
    };

    return Scaffold(
      appBar: AppBar(title: Text('Group Data')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            GroupImageSection(
              imageURL: _imageURL,
              selectedImage: _selectedImage,
              onPickImage: _pickImage,
            ),
            SizedBox(height: 10),
            GroupNameField(
              groupName: _groupName,
              onNameChange: (val) => setState(() {
                if (val.length <= 25) _groupName = val;
              }),
            ),
            SizedBox(height: 10),
            GroupDescriptionField(
                descriptionController: _descriptionController),
            if (_currentUserRoleValue == 'Administrator') ...[
              SizedBox(height: 10),
              AdminInfoCard(currentUser: _currentUser!),
            ],
            SizedBox(height: 10),
            AddPeopleSection(
              currentUser: _currentUser,
              group: _group,
              onDataChanged: _onDataChanged,
            ),
            SizedBox(height: 10),
            FilterChipsSection(
              showAccepted: _showAccepted,
              showPending: _showPending,
              showNotWantedToJoin: _showNotWantedToJoin,
              onFilterChange: (filter, isSelected) {
                setState(() {
                  switch (filter) {
                    case 'Accepted':
                      _showAccepted = isSelected;
                      break;
                    case 'Pending':
                      _showPending = isSelected;
                      break;
                    case 'NotAccepted':
                      _showNotWantedToJoin = isSelected;
                      break;
                  }
                });
              },
            ),
            SizedBox(height: 10),
            UserListSection(
              filteredUsers: filteredUsers,
              usersRoles: _usersRoles,
              usersInvitations: _usersInvitations,
              usersInvitationAtFirst: _usersInvitationAtFirst,
              group: _group,
              usersInGroup: _usersInGroup,
              userManagement: widget.userManagement,
              groupManagement: widget.groupManagement,
              notificationManagement: widget.notificationManagement,
              onChangeRole: (userName, newRole) {
                setState(() {
                  _usersRoles[userName] = newRole;
                });
              },
              onUserRemoved: (userName) {
                setState(() {
                  _usersInvitations.remove(userName);
                  _usersRoles.remove(userName);
                });
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationSection(
        onGroupUpdate: _handleGroupUpdate,
      ),
    );
  }
}
