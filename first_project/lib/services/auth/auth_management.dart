import 'package:flutter/material.dart';
import 'package:first_project/models/user.dart';

import 'package:flutter/foundation.dart';

class ProviderManagement extends ChangeNotifier {  User? _user;

  User? get user => _user;

  void fillUser(User user) {
    _user = user;
    notifyListeners();
  }

  void updateUser(User newUser){
    _user = newUser; // Call the AuthService to update the user
    notifyListeners();
  }
}
