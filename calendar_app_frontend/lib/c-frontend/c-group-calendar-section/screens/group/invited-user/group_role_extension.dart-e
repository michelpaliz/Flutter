import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/a-models/user_model/user.dart';

extension GroupRoleExtension on Group {
  String getRoleForUser(User user) {
    if (ownerId == user.id) return 'Owner';

    final directRole = userRoles[user.userName];
    if (directRole != null) return directRole;

    final invite = invitedUsers?[user.userName];
    if (invite != null) {
      final accepted = invite.invitationAnswer == true ||
          invite.informationStatus == 'Accepted';
      if (accepted && invite.role.isNotEmpty) {
        return invite.role;
      }
    }

    return 'Member';
  }
}

// ✅ Utility class for group-related permissions
class GroupPermissionHelper {
  static bool hasPermissions(User user, Group group) {
    final role = group.getRoleForUser(user);
    return ['Administrator', 'Co-Administrator', 'Owner'].contains(role);
  }
}
