import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/l10n/app_localizations.dart'; // ⬅️
import 'package:flutter/material.dart';

class AnimatedUsersList extends StatelessWidget {
  final List<User> users;
  const AnimatedUsersList({Key? key, required this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // ⬅️

    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: users.isEmpty
          ? Center(child: Text(loc.noUsersSelected)) // ⬅️
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: users.length,
              itemBuilder: (_, i) => _buildUserItem(users[i]),
            ),
    );
  }

  Widget _buildUserItem(User u) => Container(
        width: 50,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: (u.photoUrl?.isNotEmpty ?? false)
                  ? NetworkImage(u.photoUrl!)
                  : const AssetImage('assets/images/default_profile.png')
                      as ImageProvider,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 8),
            Text(u.userName,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      );
}
