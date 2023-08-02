import '../models/event.dart';
import '../models/notification_user.dart';
import '../models/user.dart';

class ConcreteUser extends User {
  List<NotificationUser>? _notifications;

  ConcreteUser(String id, String name, String email, List<Event>? events,
      {List<String>? groupIds, String? photoUrl})
      : super(id, name, email, events, groupIds: groupIds, photoUrl: photoUrl);

  @override
  void addNotification(NotificationUser notification) {
    _notifications ??= [];
    _notifications!.add(notification);
  }

  get notifications => _notifications;
  set notifications(notifications) {
    _notifications = notifications;
  }
}
