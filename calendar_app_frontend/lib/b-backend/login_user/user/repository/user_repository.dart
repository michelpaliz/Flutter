import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/a-models/notification_model/notification_user.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/b-backend/login_user/auth/auth_database/token_storage.dart';
import 'package:hexora/b-backend/login_user/user/api/user_api_client.dart';

class UserRepository {
  final UserApiClient _svc;

  UserRepository(this._svc);

  Future<String?> _token() => TokenStorage.loadToken();

  // -------- Blobs / Avatars --------
  Future<String> getFreshAvatarUrl({required String blobName}) async {
    final token = await _token();
    if (token == null) {
      throw Exception('Not authenticated');
    }
    return _svc.getFreshAvatarUrl(blobName: blobName, token: token);
  }

  // -------- Create / Read / Update / Delete --------
  Future<User> createUser(User user) async {
    return _svc.createUser(user);
  }

  Future<User> getUserById(String id) async {
    final token = await _token();
    if (token == null) throw Exception('Not authenticated');
    return _svc.getUserById(id, token: token);
  }

  Future<User> getUserByEmail(String email) async {
    final token = await _token(); // optional depending on backend
    return _svc.getUserByEmail(email, token: token);
  }

  Future<User> getUserByAuthID(String authID) async {
    final token = await _token(); // optional depending on backend
    return _svc.getUserByAuthID(authID, token: token);
  }

  Future<User> updateUser(User user) async {
    final token = await _token();
    if (token == null) throw Exception('Not authenticated');
    return _svc.updateUser(user, token: token);
  }

  Future<User> updateUserByUsername(String username, User user) async {
    final token = await _token();
    if (token == null) throw Exception('Not authenticated');
    return _svc.updateUserByUsername(username, user, token: token);
  }

  Future<void> deleteUser(String id) async {
    final token = await _token();
    if (token == null) throw Exception('Not authenticated');
    return _svc.deleteUser(id, token: token);
  }

  Future<List<User>> getAllUsers() async {
    final token = await _token(); // optional depending on backend
    return _svc.getAllUsers(token: token);
  }

  // -------- Lookups --------
  Future<User> getUserByUsername(String username) async {
    final token = await _token(); // optional depending on backend
    return _svc.getUserByUsername(username, token: token);
  }

  Future<List<String>> searchUsernames(String query) async {
    final token = await _token(); // optional depending on backend
    return _svc.searchUsernames(query, token: token);
  }

  // Useful helper for presence or invitations
  Future<List<User>> getUsersForGroup(Group group) async {
    // group.userIds could be List<dynamic> — cast safely
    final ids = group.userIds.map((e) => e.toString()).toList();
    return getUsersByIds(ids);
  }

  Future<List<User>> getUsersByIds(List<String> ids) async {
    final futures = ids.map(getUserById);
    return Future.wait(futures, eagerError: false);
  }

  // -------- Notifications --------
  Future<List<NotificationUser>> getNotificationsByUser(String userName) async {
    final token = await _token();
    if (token == null) throw Exception('Not authenticated');
    return _svc.getNotificationsByUser(userName, token: token);
  }

  // -------- Generic selector --------
  Future<User> getUserBySelector(String selector) async {
    final token = await _token(); // optional depending on backend
    return _svc.getUserBySelector(selector, token: token);
  }
}
