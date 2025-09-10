import 'dart:convert';
import 'dart:io';

import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/a-models/notification_model/userInvitation_status.dart';
import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/b-backend/api/auth/auth_database/auth_provider.dart';
import 'package:calendar_app_frontend/b-backend/api/blobUploader/blob_uploader.dart';
import 'package:calendar_app_frontend/b-backend/api/config/api_constants.dart';
import 'package:calendar_app_frontend/c-frontend/c-calendar-section/screens/group-screen/edit-group/controllers/group_update_controller.dart';
import 'package:calendar_app_frontend/c-frontend/c-calendar-section/screens/group-screen/edit-group/controllers/image_picker_controller.dart';
import 'package:calendar_app_frontend/c-frontend/c-calendar-section/screens/group-screen/edit-group/services/group_init_service.dart';
import 'package:calendar_app_frontend/c-frontend/c-calendar-section/screens/group-screen/edit-group/widgets/edit_group_body/functions/edit_group_bottom_nav.dart';
import 'package:calendar_app_frontend/c-frontend/c-calendar-section/screens/group-screen/edit-group/widgets/edit_group_body/functions/edit_group_header.dart';
import 'package:calendar_app_frontend/c-frontend/c-calendar-section/screens/group-screen/edit-group/widgets/edit_group_body/functions/edit_group_ppl.dart';
import 'package:calendar_app_frontend/d-stateManagement/group/group_management.dart';
import 'package:calendar_app_frontend/d-stateManagement/notification/notification_management.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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
  bool _isUploading = false;
  String? _photoBlobName;

  final GlobalKey<EditGroupPeopleState> _peopleKey =
      GlobalKey<EditGroupPeopleState>();

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
    if (pickedImage == null) return;

    setState(() {
      _selectedImage = pickedImage;
      _isUploading = true;
    });

    try {
      final auth = context.read<AuthProvider>();
      final token = auth.lastToken;
      if (token == null) throw Exception('Not authenticated');

      final result = await uploadImageToAzure(
        scope: 'groups',
        resourceId: widget.group.id,
        file: File(pickedImage.path),
        accessToken: token,
      );

      final resp = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/groups/${widget.group.id}/photo'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'blobName': result.blobName}),
      );
      if (resp.statusCode != 200) {
        throw Exception(
            'Commit group photo failed: ${resp.statusCode} ${resp.body}');
      }

      if (!mounted) return;
      setState(() {
        _imageURL = result.photoUrl;
        _photoBlobName = result.blobName;
      });

      widget.groupManagement.updateGroupPhoto(
        groupId: widget.group.id,
        photoUrl: _imageURL,
        photoBlobName: result.blobName,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload group photo: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isUploading = false);
    }
  }

  Future<void> _handleUpdate() async {
    final peopleState = _peopleKey.currentState;
    if (peopleState == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait, people list not ready.')),
      );
      return;
    }

    final Map<String, String> finalRoles = peopleState.getFinalRoles();
    final Map<String, UserInviteStatus> finalInvites =
        peopleState.getFinalInvites();

    final controller = GroupUpdateController(
      context: context,
      originalGroup: widget.group,
      groupName: _groupName,
      groupDescription: _descriptionController.text,
      imageUrl: _imageURL,
      currentUser: _currentUser!,
      userRoles: finalRoles,
      usersInvitations: finalInvites,
      // removed: usersInvitationAtFirst / addingNewUser / notificationManagement
      userManagement: widget.userManagement,
      groupManagement: widget.groupManagement,
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
            Stack(
              alignment: Alignment.center,
              children: [
                EditGroupHeader(
                  imageURL: _imageURL,
                  selectedImage: _selectedImage,
                  onPickImage: _pickImage,
                  groupName: _groupName,
                  onNameChange: _onNameChanged,
                  descriptionController: _descriptionController,
                ),
                if (_isUploading)
                  const Positioned.fill(
                    child: IgnorePointer(
                      ignoring: true,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            EditGroupPeople(
              key: _peopleKey,
              group: widget.group,
              initialUsers: widget.users,
              userManagement: widget.userManagement,
              groupManagement: widget.groupManagement,
              notificationManagement: widget.notificationManagement,
            ),
          ],
        ),
      ),
      bottomNavigationBar: EditGroupBottomNav(onUpdate: _handleUpdate),
    );
  }
}
