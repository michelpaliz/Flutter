import 'package:first_project/d-stateManagement/user/presence_manager.dart';
import 'package:flutter/material.dart';

class UserStatusRow extends StatelessWidget {
  final List<UserPresence> userList;

  const UserStatusRow({
    super.key,
    required this.userList,
  });

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
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: user.photoUrl.isNotEmpty
                        ? NetworkImage(user.photoUrl)
                        : const AssetImage("assets/images/default_profile.png")
                            as ImageProvider,
                  ),
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
                ],
              ),
              const SizedBox(height: 4),
              // Text(
              //   user.userName,
              //   style: const TextStyle(fontSize: 10),
              //   overflow: TextOverflow.ellipsis,
              // ),
              Tooltip(
                message: user.userName,
                child: Text(
                  user.userName,
                  style: const TextStyle(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
      ),
    );
  }
}
