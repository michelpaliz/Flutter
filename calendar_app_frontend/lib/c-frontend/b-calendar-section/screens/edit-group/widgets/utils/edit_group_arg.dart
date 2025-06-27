import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/a-models/user_model/user.dart';

class EditGroupArguments {
  final Group group;
  final List<User> users;

  EditGroupArguments({required this.group, required this.users});
}
