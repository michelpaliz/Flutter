import 'package:flutter/material.dart';
import 'package:hexora/f-themes/app_colors/tools_colors/theme_colors.dart';
import 'package:hexora/f-themes/app_utilities/image/avatar_utils.dart';
import 'package:hexora/f-themes/app_utilities/app_utils.dart';

class GroupUserCard extends StatelessWidget {
  final String userName;
  final String role;
  final String? photoUrl;
  final VoidCallback? onRemove;
  final bool isAdmin;
  final String? status;
  final DateTime? sendingDate;

  const GroupUserCard({
    Key? key,
    required this.userName,
    required this.role,
    this.photoUrl,
    this.onRemove,
    this.isAdmin = false,
    this.status,
    this.sendingDate,
  }) : super(key: key);

  IconData _getStatusIcon() {
    switch (status) {
      case 'Accepted':
        return Icons.check_circle_outline;
      case 'Pending':
        return Icons.hourglass_empty;
      case 'NotAccepted':
        return Icons.cancel_outlined;
      case 'Expired':
        return Icons.schedule_outlined;
      default:
        return Icons.person_outline;
    }
  }

  Color _getStatusIconColor(BuildContext context) {
    switch (status) {
      case 'Accepted':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'NotAccepted':
      case 'Not Accepted':
        return Colors.redAccent;
      case 'Expired':
        return ThemeColors.getTextColor(context).withOpacity(0.6);
      default:
        return ThemeColors.getTextColor(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 20,
      ), // More left/right space
      color: ThemeColors.getListTileBackgroundColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: ThemeColors.getCardShadowColor(context).withOpacity(0.15),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        leading: // group
            AvatarUtils.groupAvatar(context, photoUrl, radius: 30),
        title: Row(
          children: [
            Expanded(
              child: Text(
                userName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: ThemeColors.getTextColor(context),
                ),
              ),
            ),
            if (status != null)
              Icon(
                _getStatusIcon(),
                color: _getStatusIconColor(context),
                size: 18,
              ),
          ],
        ),
        subtitle: Row(
          children: [
            Text(
              role,
              style: TextStyle(
                color: ThemeColors.getTextColor(context).withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            if (sendingDate != null) ...[
              const SizedBox(width: 10),
              Text(
                '• ${AppUtils.formatDate(sendingDate!)}',
                style: TextStyle(
                  color: ThemeColors.getTextColor(context).withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
        trailing: isAdmin
            ? const Icon(Icons.verified_user, color: Colors.green, size: 18)
            : (onRemove != null
                ? IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    onPressed: onRemove,
                  )
                : null),
      ),
    );
  }
}
