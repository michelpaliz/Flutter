import 'package:first_project/b-backend/auth/auth_database/exceptions/auth_exceptions.dart';
import 'package:first_project/c-frontend/routes/appRoutes.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:first_project/f-themes/widgets/show_error_dialog.dart';
import 'package:first_project/f-themes/widgets/view-item-styles/text_field_widget.dart';
import 'package:first_project/f-themes/widgets/view-item-styles/textfield_styles.dart'
    show TextFieldStyles;
import 'package:first_project/utilities/enums/color_properties.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'register_controller.dart';

Widget buildUserFields(RegisterController controller, BuildContext context) {
  final loc = AppLocalizations.of(context)!;

  return Column(
    children: [
      TextFieldWidget(
        controller: controller.userName,
        decoration: _decoration(
          loc.userName,
          loc.userNameHint,
          Icons.verified_user_rounded,
        ),
        keyboardType: TextInputType.text,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9_]+$')),
          LengthLimitingTextInputFormatter(10),
        ],
        validator: (val) => val!.isEmpty ? loc.userNameRequired : null,
      ),
      const SizedBox(height: 10),
      TextFieldWidget(
        controller: controller.name,
        decoration: _decoration(
          loc.name,
          loc.nameHint,
          Icons.person,
        ),
        keyboardType: TextInputType.text,
        validator: (val) => val!.isEmpty ? loc.nameRequired : null,
      ),
      const SizedBox(height: 10),
      TextFieldWidget(
        controller: controller.email,
        decoration: _decoration(
          'Email',
          loc.emailHint,
          Icons.email,
        ),
        keyboardType: TextInputType.emailAddress,
        validator: (val) => val!.isEmpty ? loc.emailRequired : null,
      ),
      const SizedBox(height: 10),
      TextFieldWidget(
        controller: controller.password,
        decoration: _decoration(
          loc.password,
          loc.passwordHint,
          Icons.lock,
        ),
        keyboardType: TextInputType.visiblePassword, // ✅ Added
        obscureText: true,
        validator: (val) => val!.length < 6 ? loc.passwordLength : null,
      ),
      const SizedBox(height: 10),
      TextFieldWidget(
        controller: controller.confirmPassword,
        decoration: _decoration(
          loc.confirmPassword,
          loc.confirmPassword,
          Icons.lock,
        ),
        keyboardType: TextInputType.visiblePassword, // ✅ Added
        obscureText: true,
        validator: (val) =>
            val != controller.password.text ? loc.passwordNotMatch : null,
      ),
    ],
  );
}

Widget buildRegisterButton(
  RegisterController controller,
  BuildContext context,
  GlobalKey<FormState> formKey,
  dynamic authProvider,
) {
  return Container(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      style: ColorProperties.defaultButton(),
      onPressed: () async {
        if (!formKey.currentState!.validate()) return;

        final userName = controller.userName.text.trim();
        final email = controller.email.text.trim();
        final password = controller.password.text;
        final confirmPassword = controller.confirmPassword.text;
        final name = controller.name.text.trim();

        if (password != confirmPassword) {
          await showErrorDialog(
              context, AppLocalizations.of(context)!.passwordNotMatch);
          return;
        }

        try {
          final registrationStatus = await authProvider.createUser(
            userName: userName,
            name: name,
            email: email,
            password: password,
          );

          final user =
              await authProvider.logIn(email: email, password: password);

// ✅ Update the app state so other screens can use this user
          Provider.of<UserManagement>(context, listen: false)
              .setCurrentUser(user);

// Now go to the home screen
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.homePage,
            (route) => false,
          );

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Registration Status'),
                content: Text(registrationStatus),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              );
            },
          );
        } on WeakPasswordException {
          await showErrorDialog(
              context, AppLocalizations.of(context)!.weakPassword);
        } on EmailAlreadyUseAuthException {
          await showErrorDialog(
              context, AppLocalizations.of(context)!.emailTaken);
        } on InvalidEmailAuthException {
          await showErrorDialog(
              context, AppLocalizations.of(context)!.invalidEmail);
        } on GenericAuthException {
          await showErrorDialog(
              context, AppLocalizations.of(context)!.registrationError);
        }
      },
      child: Text(
        AppLocalizations.of(context)!.register,
        style: const TextStyle(color: Colors.white),
      ),
    ),
  );
}

Widget buildLoginButton(BuildContext context) {
  return TextButton(
    onPressed: () => Navigator.pushNamed(context, AppRoutes.loginRoute),
    child: RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: AppLocalizations.of(context)!.alreadyRegistered,
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
          TextSpan(
            text: AppLocalizations.of(context)!.login,
            style: const TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    ),
  );
}

InputDecoration _decoration(String label, String hint, IconData icon) {
  return TextFieldStyles.saucyInputDecoration(
    hintText: hint,
    labelText: label,
    suffixIcon: icon,
  );
}
