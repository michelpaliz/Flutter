import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/c-frontend/c-group-calendar-section/screens/group-screen/invited-user/group_role_extension.dart';
import 'package:calendar_app_frontend/d-stateManagement/group/group_management.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';

// Fetching groups
// Checking permissions
// Leaving or deleting groups
class GroupController {
  static Future<void> fetchGroups(
    User? user,
    GroupManagement groupManager,
  ) async {
    if (user == null) {
      print('⚠️ GroupController.fetchGroups: user is null, aborting.');
      return;
    }

    print(
      '📥 GroupController.fetchGroups: Fetching groups for user: ${user.userName} (${user.id})',
    );
    print('📦 User group IDs: ${user.groupIds}');

    try {
      await groupManager.fetchAndInitializeGroups(user.groupIds);
      print('✅ GroupController.fetchGroups: Group fetch complete.');
    } catch (e) {
      print('❌ GroupController.fetchGroups: Failed to fetch groups: $e');
    }
  }

  static String getRole(User currentUser, Map<String, String> userRoles) {
    return userRoles[currentUser.userName] ?? 'No Role Found';
  }

  static bool hasPermissions(User user, Group group) {
    final role = group.getRoleForUser(user);
    return ['Administrator', 'Co-Administrator', 'Owner'].contains(role);
  }

  static Future<bool> removeGroup({
    required Group group,
    required UserManagement userManagement,
    required GroupManagement groupManagement,
  }) async {
    return await groupManagement.removeGroup(group, userManagement);
  }

  static Future<void> leaveGroup({
    required Group group,
    required User user,
    required GroupManagement groupManagement,
  }) async {
    await groupManagement.groupService.removeUserInGroup(user.id, group.id);
  }
}
