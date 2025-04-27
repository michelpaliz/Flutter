import 'package:first_project/f-themes/themes/theme_colors.dart';
import 'package:first_project/f-themes/utilities/utilities.dart';
import 'package:flutter/material.dart';

class GroupUserCard extends StatelessWidget {
  final String userName;
  final String role;
  final String? photoUrl;
  final VoidCallback? onRemove;
  final bool isAdmin;

  const GroupUserCard({
    Key? key,
    required this.userName,
    required this.role,
    this.photoUrl,
    this.onRemove,
    this.isAdmin = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: ThemeColors.getListTileBackgroundColor(context),
      elevation: 4,
      shadowColor: ThemeColors.getCardShadowColor(context),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 16,
        ),
        leading: CircleAvatar(
          radius: 26,
          backgroundImage: Utilities.buildProfileImage(photoUrl ?? ''),
        ),
        title: Text(
          userName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: ThemeColors.getTextColor(context),
          ),
        ),
        subtitle: Text(
          role,
          style: TextStyle(
            color: ThemeColors.getTextColor(context).withOpacity(0.7),
            fontSize: 13,
          ),
        ),
        trailing: isAdmin
            ? const Icon(Icons.verified_user, color: Colors.green)
            : (onRemove != null
                ? IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent),
                    onPressed: onRemove,
                  )
                : null),
      ),
    );
  }
}
