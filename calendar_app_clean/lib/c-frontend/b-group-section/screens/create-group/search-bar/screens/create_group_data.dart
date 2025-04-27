import 'package:first_project/c-frontend/b-group-section/screens/create-group/search-bar/widgets/group_list.dart';
import 'package:first_project/c-frontend/b-group-section/utils/shared/add_user_button.dart';
import 'package:first_project/f-themes/themes/theme_colors.dart';
import 'package:first_project/f-themes/utilities/view-item-styles/button/button_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../../../d-stateManagement/group_management.dart';
import '../../../../../../d-stateManagement/notification_management.dart';
import '../../../../../../d-stateManagement/user_management.dart';
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              GroupImagePicker(controller: _controller),
              GroupTextFields(controller: _controller),
              const SizedBox(height: 10),
              // GroupAddUserButton(controller: _controller),
              AddUserButtonDialog(
                currentUser: _controller.currentUser,
                group: null, // Because you're creating a new group
                controller: _controller,
              ),
              const SizedBox(height: 10),
              // GroupRoleList(controller: _controller),
              GroupRoleList(
                externalController: _controller,
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ButtonStyles.buttonWithIcon(
            iconData: Icons.group_add_rounded,
            label: AppLocalizations.of(context)!.saveGroup,
            style: ButtonStyles.saucyButtonStyle(
              defaultBackgroundColor:
                  ThemeColors.getButtonBackgroundColor(context),
              pressedBackgroundColor:
                  ThemeColors.getContainerBackgroundColor(context),
              textColor: ThemeColors.getButtonTextColor(context),
              borderColor: ThemeColors.getTextColor(context),
              borderRadius: 12.0,
              padding: 14.0, // slightly bigger padding for bottom button
              fontSize: 17.0,
              fontWeight: FontWeight.bold,
            ),
            onPressed: _controller.submitGroupFromUI,
          ),
        ),
      ),
    );
  }
}
