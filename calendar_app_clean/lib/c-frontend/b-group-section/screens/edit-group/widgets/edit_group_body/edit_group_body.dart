import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/c-frontend/b-group-section/screens/edit-group/controllers/group_update_controller.dart';
import 'package:first_project/c-frontend/b-group-section/screens/edit-group/controllers/image_picker_controller.dart';
import 'package:first_project/c-frontend/b-group-section/screens/edit-group/services/group_init_service.dart';
import 'package:first_project/c-frontend/b-group-section/screens/edit-group/widgets/edit_group_body/edit_group_bottom_nav.dart';
import 'package:first_project/c-frontend/b-group-section/screens/edit-group/widgets/edit_group_body/edit_group_header.dart';
import 'package:first_project/c-frontend/b-group-section/screens/edit-group/widgets/edit_group_body/edit_group_ppl.dart';
import 'package:first_project/d-stateManagement/group/group_management.dart';
import 'package:first_project/d-stateManagement/notification/notification_management.dart';
import 'package:first_project/d-stateManagement/user/user_management.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  _EditGroupBodyState createState() => _EditGroupBodyState();
}

class _EditGroupBodyState extends State<EditGroupBody> {
  late String _groupName;
  late TextEditingController _descriptionController;
  late String _imageURL;
  late User? _currentUser;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();

    _currentUser = widget.userManagement.user;

    final initService = GroupInitializationService(
      group: widget.group,
      descriptionController: TextEditingController(),
    );

    _groupName = initService.groupName;
    _descriptionController = initService.descriptionController;
    _imageURL = initService.imageURL;
  }

  void _onNameChanged(String name) {
    setState(() => _groupName = name);
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

  void _handleUpdate() async {
    final controller = GroupUpdateController(
      context: context,
      originalGroup: widget.group,
      groupName: _groupName,
      groupDescription: _descriptionController.text,
      imageUrl: _imageURL,
      currentUser: _currentUser!,
      userRoles: {}, // You can pass updated roles here if needed
      usersInvitations: {}, // Same for invitations
      usersInvitationAtFirst: {},
      addingNewUser: false,
      userManagement: widget.userManagement,
      groupManagement: widget.groupManagement,
      notificationManagement: widget.notificationManagement,
    );

    await controller.performGroupUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Group')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            EditGroupHeader(
              imageURL: _imageURL,
              selectedImage: _selectedImage,
              onPickImage: _pickImage,
              groupName: _groupName,
              onNameChange: _onNameChanged,
              descriptionController: _descriptionController,
            ),
            const SizedBox(height: 16),
            EditGroupPeople(
              group: widget.group,
              initialUsers: widget.users,
              userManagement: widget.userManagement,
              groupManagement: widget.groupManagement,
              notificationManagement: widget.notificationManagement,
            ),
          ],
        ),
      ),
      bottomNavigationBar: EditGroupBottomNav(
        onUpdate: _handleUpdate,
      ),
    );
  }
}
