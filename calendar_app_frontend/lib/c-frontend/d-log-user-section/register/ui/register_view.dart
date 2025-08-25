import 'package:calendar_app_frontend/c-frontend/d-log-user-section/shared_utilities/auth_switcher_view.dart';
import 'package:flutter/material.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Just delegate to AuthSwitcherView
    return const AuthSwitcherView();
  }
}
