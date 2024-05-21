import 'package:first_project/models/group.dart';
import 'package:first_project/models/notification_user.dart';
import 'package:first_project/models/user.dart';

class NotificationFormats {
  late NotificationUser _notificationUser;

  // NotificationFormats(this._notificationUser);

  NotificationUser whenCreatingGroup(Group group, User user) {
    final congratulatoryTitle = 'Congratulations!';
    final congratulatoryMessage = 'You created the group: ${group.groupName}';
    _notificationUser = NotificationUser(
      id: group.id,
      ownerId: user.id,
      title: congratulatoryTitle,
      message: congratulatoryMessage,
      timestamp: DateTime.now(),
      hasQuestion: false,
      question: '',
    );
    return _notificationUser;
  }
}
