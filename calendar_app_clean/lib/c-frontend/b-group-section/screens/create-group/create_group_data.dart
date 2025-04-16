import 'package:first_project/c-frontend/b-group-section/screens/create-group/group_add_user_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../d-stateManagement/group_management.dart';
import '../../../../d-stateManagement/notification_management.dart';
import '../../../../d-stateManagement/user_management.dart';
import 'group_controller.dart';
import 'group_image_picker.dart';
import 'group_role_list.dart';
import 'group_text_fields.dart';

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
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.groupData),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              GroupImagePicker(controller: _controller),
              GroupTextFields(controller: _controller),
              const SizedBox(height: 10),
              GroupAddUserButton(controller: _controller),
              const SizedBox(height: 10),
              GroupRoleList(controller: _controller),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextButton(
            onPressed: _controller.saveGroup,
            style: Theme.of(context).textButtonTheme.style,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.group_add_rounded),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.saveGroup,
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
