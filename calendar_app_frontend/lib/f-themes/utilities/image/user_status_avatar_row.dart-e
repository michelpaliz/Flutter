import 'package:calendar_app_frontend/d-stateManagement/user/presence_manager.dart';
import 'package:flutter/material.dart';

class UserStatusRow extends StatelessWidget {
  final List<UserPresence> userList;

  const UserStatusRow({super.key, required this.userList});

  /// Get role icon
  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.workspace_premium; // crown-like
      case UserRole.coAdmin:
        return Icons.shield;
      case UserRole.member:
        return Icons.person;
    }
  }

  /// Get role icon background color (optional for badge)
  Color _getRoleIconColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.orange;
      case UserRole.coAdmin:
        return Colors.blueAccent;
      case UserRole.member:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: userList.length,
        itemBuilder: (context, index) {
          final user = userList[index];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: user.photoUrl.isNotEmpty
                        ? NetworkImage(user.photoUrl)
                        : const AssetImage("assets/images/default_profile.png")
                              as ImageProvider,
                  ),

                  // Online/offline dot (bottom right)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: user.isOnline ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),

                  // Role icon badge (top left)
                  Positioned(
                    left: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getRoleIcon(user.role),
                        size: 12,
                        color: _getRoleIconColor(user.role),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Tooltip(
                message: user.userName,
                child: Text(
                  user.userName,
                  style: const TextStyle(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
      ),
    );
  }
}
