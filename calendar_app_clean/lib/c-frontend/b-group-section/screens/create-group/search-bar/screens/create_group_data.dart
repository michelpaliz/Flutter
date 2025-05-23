import 'package:first_project/c-frontend/b-group-section/screens/create-group/search-bar/widgets/group_list.dart';
import 'package:first_project/c-frontend/b-group-section/screens/create-group/search-bar/widgets/save_group_button.dart';
import 'package:first_project/c-frontend/b-group-section/utils/shared/add_user_button.dart';
import 'package:first_project/f-themes/shape/solid/solid_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../../../d-stateManagement/group/group_management.dart';
import '../../../../../../d-stateManagement/notification/notification_management.dart';
import '../../../../../../d-stateManagement/user/user_management.dart';
import '../controllers/create_group_controller.dart';
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
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.groupData),
        ),
        body: Stack(
          children: [
            const SolidHeader(height: 180), // ⬅️ background curved header

            SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
              child: Column(
                children: [
                  const SizedBox(height: 20), // space below header curve
                  GroupImagePicker(controller: _controller),
                  GroupTextFields(controller: _controller),
                  const SizedBox(height: 10),
                  AddUserButtonDialog(
                    currentUser: _controller.currentUser,
                    group: null,
                    controller: _controller,
                  ),
                  const SizedBox(height: 10),
                  GroupRoleList(
                    externalController: _controller,
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SaveGroupButton(controller: _controller),
      ),
    );
  }
}
