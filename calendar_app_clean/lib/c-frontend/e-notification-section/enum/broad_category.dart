import 'package:first_project/a-models/notification_model/notification_user.dart';

enum BroadCategory {
  group,
  user,
  system,
  other,
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
    Category.message: BroadCategory.user,
    Category.systemAlert: BroadCategory.system,
    Category.systemUpdate: BroadCategory.system,
    Category.errorReport: BroadCategory.system,
    // Everything else goes to "other"
    Category.eventReminder: BroadCategory.other,
    Category.taskUpdate: BroadCategory.other,
    Category.achievement: BroadCategory.other,
    Category.billing: BroadCategory.other,
    Category.actionRequired: BroadCategory.other,
    Category.feedbackRequest: BroadCategory.other,
  };

  BroadCategory? get selectedCategory => _selectedCategory;

  void filterNotifications(BroadCategory? category) {
    _selectedCategory = category;
  }
}
