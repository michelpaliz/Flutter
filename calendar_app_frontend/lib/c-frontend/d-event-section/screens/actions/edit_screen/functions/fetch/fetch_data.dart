import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/b-backend/api/user/user_services.dart';

Future<void> fetchUserData(
  context,
  Group group,
  UserService userService,
  List<String> recipientIds,
  List<User> users,
  Function(User) onUserFound,
) async {
  if (group.userIds.isNotEmpty) {
    for (var userId in group.userIds) {
      User user = await userService.getUserById(userId);
      users.add(user);
      if (recipientIds.contains(user.id)) {
        onUserFound(user);
      }
    }
  }
}
