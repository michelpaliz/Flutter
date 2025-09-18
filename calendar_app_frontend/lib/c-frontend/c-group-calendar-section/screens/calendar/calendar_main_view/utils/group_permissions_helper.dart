import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/a-models/user_model/user.dart';

/// Extension to resolve the user's role in a group
extension GroupRoleExtension on Group {
  String getRoleForUser(User user) {
    if (ownerId == user.id) return 'Owner';

    final directRole = userRoles[user.userName];
    if (directRole != null) return directRole;

    final invite = invitedUsers?[user.userName];
    if (invite != null &&
        (invite.invitationAnswer == true ||
            invite.informationStatus == 'Accepted') &&
        invite.role.isNotEmpty) {
      return invite.role;
    }

    return 'Member';
  }
}

/// Helper class for permission checks
class GroupPermissionHelper {
  static bool canAddEvents(User user, Group group) {
    final role = group.getRoleForUser(user);
    return _hasEditRights(role);
  }

  static bool canEditGroup(User user, Group group) {
    final role = group.getRoleForUser(user);
    return _hasEditRights(role);
  }

  static bool isOwner(User user, Group group) {
    return group.getRoleForUser(user) == 'Owner';
  }

  static bool _hasEditRights(String role) {
    return ['Administrator', 'Co-Administrator', 'Owner'].contains(role);
  }
}
