// import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth show User;

import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

//This class and all its subclass must have final values (immutable)
@immutable
class AuthUser{

  final bool isEmailVerified;

  const AuthUser(this.isEmailVerified);

  factory AuthUser.fromFirebase(User user) => AuthUser(user.emailVerified);
  

}