import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import 'register_form.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        // Uses the localized "Register" / "Registrarse"
        title: Text(l10n.register),
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 5.0),
          child: RegisterForm(),
        ),
      ),
    );
  }
}
