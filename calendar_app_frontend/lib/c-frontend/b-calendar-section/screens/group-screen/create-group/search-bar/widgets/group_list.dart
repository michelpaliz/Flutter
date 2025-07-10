import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/group-screen/create-group/search-bar/controllers/create_group_controller.dart';
import 'package:calendar_app_frontend/f-themes/shape/rounded/rounded_section_card.dart';
import 'package:flutter/material.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../../../../../a-models/user_model/user.dart';
import '../../../../../../../b-backend/api/user/user_services.dart';
import '../../../../../../../../../f-themes/themes/theme_colors.dart';
import '../../../../../../../../../f-themes/utilities/utilities.dart';

class GroupRoleList extends StatelessWidget {
  final GroupController? externalController;
  final void Function(String userName)? onRemoveUser;

  const GroupRoleList({Key? key, this.externalController, this.onRemoveUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupController>(
      builder: (context, controllerFromProvider, _) {
        final controller = externalController ?? controllerFromProvider;

        if (controller.userRoles.isEmpty) {
          return const Text("No user roles available");
        }

        return RoundedSectionCard(
          title: AppLocalizations.of(context)!.member, // e.g. "User Roles"
          child: Column(
            children: controller.userRoles.keys.map((userName) {
              final role = controller.userRoles[userName];
              final userService = UserService();

              return FutureBuilder<User?>(
                future: userService.getUserByUsername(userName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData) {
                    return Text(AppLocalizations.of(context)!.userNotFound);
                  }

                  final user = snapshot.data!;
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: ThemeColors.getListTileBackgroundColor(context),
                    elevation: 4,
                    shadowColor: ThemeColors.getCardShadowColor(context),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundImage: Utilities.buildProfileImage(
                          user.photoUrl ?? '',
                        ),
                      ),
                      title: Text(
                        userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: ThemeColors.getTextColor(context),
                        ),
                      ),
                      subtitle: Text(
                        role ?? '',
                        style: TextStyle(
                          color: ThemeColors.getTextColor(
                            context,
                          ).withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                      trailing: role != "Administrator"
                          ? IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                if (onRemoveUser != null) {
                                  onRemoveUser!(userName);
                                } else {
                                  controller.removeUser(userName);
                                }
                              },
                            )
                          : const Icon(
                              Icons.verified_user,
                              color: Colors.green,
                            ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
