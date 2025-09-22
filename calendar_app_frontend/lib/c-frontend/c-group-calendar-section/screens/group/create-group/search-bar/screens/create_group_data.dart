import 'package:calendar_app_frontend/c-frontend/c-group-calendar-section/screens/group/create-group/search-bar/controllers/group_controller.dart';
import 'package:calendar_app_frontend/c-frontend/c-group-calendar-section/screens/group/create-group/search-bar/screens/page_group_role_list.dart';
import 'package:calendar_app_frontend/c-frontend/c-group-calendar-section/screens/group/create-group/search-bar/widgets/save_group_button.dart';
import 'package:calendar_app_frontend/c-frontend/c-group-calendar-section/utils/shared/add_user_button.dart';
import 'package:calendar_app_frontend/f-themes/shape/solid/solid_header.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../../../../d-stateManagement/group/group_management.dart';
import '../../../../../../../d-stateManagement/notification/notification_management.dart';
import '../../../../../../../d-stateManagement/user/user_management.dart';
import '../widgets/group_image_picker.dart';
import '../widgets/group_text_fields.dart';

class CreateGroupData extends StatefulWidget {
  const CreateGroupData({super.key});

  @override
  State<CreateGroupData> createState() => _CreateGroupDataState();
}

class _CreateGroupDataState extends State<CreateGroupData> {
  final ImagePicker _imagePicker = ImagePicker();
  final GroupController _controller = GroupController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final userManagement = Provider.of<UserManagement>(context, listen: false);
    final groupManagement =
        Provider.of<GroupManagement>(context, listen: false);
    final notificationManagement =
        Provider.of<NotificationManagement>(context, listen: false);
    final currentUser = userManagement.user;

    if (currentUser != null) {
      _controller.initialize(
        user: currentUser,
        userManagement: userManagement,
        groupManagement: groupManagement,
        notificationManagement: notificationManagement,
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupController>.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.groupData)),
        body: Stack(
          children: [
            const SolidHeader(height: 180),
            SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  GroupImagePicker(),
                  GroupTextFields(controller: _controller),
                  const SizedBox(height: 10),

                  // ⬇️ Pass onUserAdded and update the controller
                  // in CreateGroupData build()
                  Align(
                    alignment: Alignment.centerRight,
                    child: AddUserButtonDialog(
                      currentUser: _controller.currentUser,
                      group: null,
                      controller: _controller,
                      onUserAdded: (picked) => _controller.addMember(picked),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ⬇️ Rebuild this section when the controller notifies
                  Consumer<GroupController>(
                    builder: (_, ctrl, __) => PagedGroupRoleList(
                      userRoles: ctrl.userRoles,
                      membersByUsername: ctrl
                          .membersByUsername, // fill this when adding members
                      assignableRoles: ctrl.assignableRoles,
                      canEditRole: ctrl.canEditRole,
                      setRole: ctrl.setRole,
                      onRemoveUser: ctrl.removeUser,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        // in Scaffold
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: SaveGroupButton(controller: _controller),
        ),
      ),
    );
  }
}
