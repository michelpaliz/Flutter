import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as devtools show log;

import '../models/user.dart';
 // Replace 'path_to_user_class' with the actual path to your User class file

class SharedPrefsUtils {
  static Future<void> storeUser(User user) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String userJson = json.encode(user.toJson());
    devtools.log('this is the user json: ' + userJson);
    await preferences.setString('user', userJson);
  }

  static Future<User?> getUserFromPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userJson = preferences.getString('user');
    if (userJson != null) {
      Map<String, dynamic> userMap = json.decode(userJson);
      return User.fromJson(userMap);
    }
    return null;
  }
}
