import 'package:first_project/a-models/model/user_data/notification_user.dart';

enum BroadCategory {
  group,
  user,
  event,
  task,
  message,
  system,
  action,
  achievement,
  billing,
  feedback,
  error,
}

class BroadCategoryManager {
  BroadCategory? _selectedCategory;

  // Define broader categories

  // Map existing categories to broader categories
  final Map<Category, BroadCategory> categoryMapping = {
    Category.groupCreation: BroadCategory.group,
    Category.groupUpdate: BroadCategory.group,
    Category.groupInvitation: BroadCategory.group,
    Category.userRemoval: BroadCategory.user,
    Category.userInvitation: BroadCategory.user,
    Category.eventReminder: BroadCategory.event,
    Category.taskUpdate: BroadCategory.task,
    Category.message: BroadCategory.message,
    Category.systemAlert: BroadCategory.system,
    Category.actionRequired: BroadCategory.action,
    Category.achievement: BroadCategory.achievement,
    Category.billing: BroadCategory.billing,
    Category.systemUpdate: BroadCategory.system,
    Category.feedbackRequest: BroadCategory.feedback,
    Category.errorReport: BroadCategory.error,
  };

  BroadCategory? get selectedCategory => _selectedCategory;

  void filterNotifications(BroadCategory? category) {
    _selectedCategory = category;
  }
}
