import 'package:first_project/f-themes/themes/theme_colors.dart';
import 'package:first_project/f-themes/utilities/utilities.dart';
import 'package:flutter/material.dart';

class GroupUserCard extends StatelessWidget {
  final String userName;
  final String role;
  final String? photoUrl;
  final VoidCallback? onRemove;
  final bool isAdmin;
  final String? status; // 👈 Status like 'Pending', 'Accepted', etc.
  final DateTime? sendingDate; // 👈 Invite sending date

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
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: ThemeColors.getListTileBackgroundColor(context),
      elevation: 4,
      shadowColor: ThemeColors.getCardShadowColor(context),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        leading: CircleAvatar(
          radius: 26,
          backgroundImage: Utilities.buildProfileImage(photoUrl ?? ''),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                userName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: ThemeColors.getTextColor(context),
                ),
              ),
            ),
            if (status != null)
              Icon(
                _getStatusIcon(),
                color: _getStatusIconColor(context),
                size: 20,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              role,
              style: TextStyle(
                color: ThemeColors.getTextColor(context).withOpacity(0.7),
                fontSize: 13,
              ),
            ),
            if (sendingDate != null)
              Text(
                'Invited: ${Utilities.formatDate(sendingDate!)}',
                style: TextStyle(
                  color: ThemeColors.getTextColor(context).withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
          ],
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
