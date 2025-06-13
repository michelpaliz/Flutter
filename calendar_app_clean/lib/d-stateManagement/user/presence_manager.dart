import 'package:first_project/a-models/user_model/user.dart';
import 'package:flutter/material.dart';

class UserPresence {
  final String userId;
  final String userName;
  final String photoUrl;
  final bool isOnline;

  UserPresence({
    required this.userId,
    required this.userName,
    required this.photoUrl,
    required this.isOnline,
  });
}

class PresenceManager extends ChangeNotifier {
  final Map<String, UserPresence> _onlineUsers = {}; // userId -> UserPresence
  final Map<String, User> _knownUsers = {}; // from DB

  void updatePresenceList(List<dynamic> data) {
    debugPrint("📥 updatePresenceList called with: ${data.length} users");
    _onlineUsers.clear();

    for (final user in data) {
      final rawId = user['userId'];
      final id = rawId.toString().trim(); // normalize

      final presence = UserPresence(
        userId: id,
        userName: user['userName'],
        photoUrl: user['photoUrl'],
        isOnline: true,
      );

      _onlineUsers[id] = presence;
      debugPrint("✅ Online user added: $id (${user['userName']})");
    }

    debugPrint("🧠 Final online user IDs: ${_onlineUsers.keys.toList()}");
    notifyListeners();
  }

  void setKnownUsers(List<User> users) {
    for (final user in users) {
      final id = user.id.toString().trim();
      _knownUsers[id] = user;
      debugPrint("🧠 Cached known user: $id (${user.userName})");
    }
    notifyListeners();
  }

  List<UserPresence> getPresenceForGroup(List<String> userIds) {
    return userIds.map((id) {
      final normalizedId = id.toString().trim();

      final isOnline = _onlineUsers.containsKey(normalizedId);
      debugPrint("🧪 Checking $normalizedId -> online: $isOnline");

      final onlinePresence = _onlineUsers[normalizedId];
      if (onlinePresence != null) return onlinePresence;

      final fallbackUser = _knownUsers[normalizedId];
      debugPrint(
          "🔁 Fallback to offline user: ${fallbackUser?.userName ?? "Unknown"}");
      return UserPresence(
        userId: normalizedId,
        userName: fallbackUser?.userName ?? "Unknown",
        photoUrl: fallbackUser?.photoUrl ?? "", // leave empty
        isOnline: false,
      );
    }).toList();
  }
}
