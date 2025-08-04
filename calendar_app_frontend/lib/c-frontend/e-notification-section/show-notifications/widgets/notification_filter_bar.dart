import 'package:calendar_app_frontend/a-models/notification_model/notification_user.dart';
import 'package:calendar_app_frontend/c-frontend/e-notification-section/enum/broad_category.dart';
import 'package:calendar_app_frontend/f-themes/themes/theme_colors.dart';
import 'package:flutter/material.dart';

class NotificationFilterBar extends StatefulWidget {
  final List<NotificationUser> notifications;
  final BroadCategory? selectedCategory;
  final ValueChanged<BroadCategory?> onCategorySelected;

  const NotificationFilterBar({
    super.key,
    required this.notifications,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  State<NotificationFilterBar> createState() => _NotificationFilterBarState();
}

class _NotificationFilterBarState extends State<NotificationFilterBar> {
  final BroadCategoryManager _categoryManager = BroadCategoryManager();

  @override
  Widget build(BuildContext context) {
    final usedCats = widget.notifications
        .map((ntf) => _categoryManager.categoryMapping[ntf.category])
        .whereType<BroadCategory>()
        .toSet();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: usedCats.map((cat) {
          final selected = widget.selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selected
                      ? ThemeColors.getButtonBackgroundColor(context)
                      : ThemeColors.getButtonBackgroundColor(context)
                          .withOpacity(0.5),
                  foregroundColor: ThemeColors.getButtonTextColor(context),
                ),
                onPressed: () {
                  widget.onCategorySelected(
                    selected ? null : cat,
                  );
                },
                child: Text(cat.localizedName(context))),
          );
        }).toList(),
      ),
    );
  }
}
