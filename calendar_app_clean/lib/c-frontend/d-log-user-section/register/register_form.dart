import 'package:first_project/b-backend/auth/auth_database/auth/auth_service.dart'; // ✅ Updated import
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'register_controller.dart';
import 'register_fields.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  late final RegisterController controller;

  @override
  void initState() {
    super.initState();
    controller = RegisterController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService.custom(); // ✅ Replaces AuthProvider

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Image.asset('assets/images/login_image.png', width: 100, height: 100),
          const SizedBox(height: 30),
          Center(
            child: Text(
              AppLocalizations.of(context)!.register,
              style: const TextStyle(
                fontSize: 37,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(202, 34, 108, 192),
                fontFamily: 'righteous',
              ),
            ),
          ),
          const SizedBox(height: 25),
          buildUserFields(controller, context),
          const SizedBox(height: 10),
          buildRegisterButton(
              controller, context, _formKey, authService), // ✅ Updated
          buildLoginButton(context),
        ],
      ),
    );
  }
}
