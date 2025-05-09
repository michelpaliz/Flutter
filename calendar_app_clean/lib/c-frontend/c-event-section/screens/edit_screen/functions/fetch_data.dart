import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/b-backend/api/user/user_services.dart';

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
