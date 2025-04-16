import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/user_management.dart';

// Fetching groups
// Checking permissions
// Leaving or deleting groups
class GroupController {
  static Future<void> fetchGroups(
      User? user, GroupManagement groupManager) async {
    if (user != null) {
      await groupManager.fetchAndInitializeGroups(user.groupIds);
    }
  }

  static String getRole(User currentUser, Map<String, String> userRoles) {
    return userRoles[currentUser.userName] ?? 'No Role Found';
  }

  static bool hasPermissions(User user, Group group) {
    final role = getRole(user, group.userRoles);
    return role == "Administrator" || role == "Co-Administrator";
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
