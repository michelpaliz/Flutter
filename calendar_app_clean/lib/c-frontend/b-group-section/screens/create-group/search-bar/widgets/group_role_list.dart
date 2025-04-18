import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../../a-models/user_model/user.dart';
import '../../../../../../b-backend/auth/node_services/user_services.dart';
import '../../../../../../utilities/utilities.dart';
import '../controllers/create_group_controller.dart';

class GroupRoleList extends StatelessWidget {
  const GroupRoleList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupController>(
      builder: (context, controller, _) {
        if (controller.userRoles.isEmpty) {
          return const Text("No user roles available");
        }

        return Column(
          children: controller.userRoles.keys.map((userName) {
            final role = controller.userRoles[userName];
            final userService = UserService();

            return FutureBuilder<User?>(
              future: userService.getUserByUsername(userName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData) {
                  return Text(AppLocalizations.of(context)!.userNotFound);
                }

                final user = snapshot.data!;
                return ListTile(
                  title: Text(userName),
                  subtitle: Text(role ?? ''),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        Utilities.buildProfileImage(user.photoUrl ?? ''),
                  ),
                  trailing: role != "Administrator"
                      ? GestureDetector(
                          onTap: () {
                            controller.removeUser(userName);
                          },
                          child: const Icon(Icons.clear, color: Colors.red),
                        )
                      : null,
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
