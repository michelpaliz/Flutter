// ======= REGISTER =========
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/styles/widgets/view-item-styles/text_field_widget.dart';
import 'package:first_project/enums/color_properties.dart';
import 'package:first_project/styles/widgets/view-item-styles/app_bar_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../enums/routes/appRoutes.dart';
import '../../services/auth/exceptions/auth_exceptions.dart';
import '../../services/auth/logic_backend/auth_service.dart';
import '../../styles/widgets/view-item-styles/textfield_styles.dart';
import '../../styles/widgets/show_error_dialog.dart';
import 'dart:developer' as devtools show log;
import "package:flutter_gen/gen_l10n/app_localizations.dart";

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _confirmPassword;
  late final TextEditingController _nameController;
  late final TextEditingController _userNameController;
  bool buttonHovered = false; // Added buttonHovered variable

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
    _confirmPassword = TextEditingController();
    _nameController = TextEditingController();
    _userNameController = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<bool> _isUserNameTaken(String userName) async {
    final firestore = FirebaseFirestore.instance;
    final userCollection = firestore.collection('users');

    final querySnapshot = await userCollection
        .where('userName', isEqualTo: userName)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppBarStyles.themeData,
      child: Scaffold(
        appBar: AppBar(
          title: Text("SCHEDULE"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 5.0),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              children: [
                Image.asset(
                  'assets/images/login_image.png', // Replace with your image path
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.register,
                    style: TextStyle(
                      fontSize: 37,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(202, 34, 108, 192),
                      fontFamily: 'rigtheous',
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                TextFieldWidget(
                  controller: _userNameController,
                  decoration: TextFieldStyles.saucyInputDecoration(
                    hintText: AppLocalizations.of(context)!.userNameHint,
                    labelText: AppLocalizations.of(context)!.userName,
                    suffixIcon: Icons.verified_user_rounded,
                  ),
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^[a-zA-Z0-9_]+$')), // Updated regex pattern
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
                const SizedBox(height: 10),
                TextFieldWidget(
                  controller: _nameController,
                  decoration: TextFieldStyles.saucyInputDecoration(
                      hintText: AppLocalizations.of(context)!.nameHint,
                      labelText: AppLocalizations.of(context)!.name,
                      suffixIcon: Icons.person),
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^[a-zA-Z0-9_]+$')), // Updated regex pattern
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
                const SizedBox(height: 10),
                TextFieldWidget(
                  controller: _email,
                  decoration: TextFieldStyles.saucyInputDecoration(
                    hintText: AppLocalizations.of(context)!.emailHint,
                    labelText: 'Email',
                    suffixIcon: Icons.email,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                TextFieldWidget(
                  controller: _password,
                  decoration: TextFieldStyles.saucyInputDecoration(
                      hintText: AppLocalizations.of(context)!.passwordHint,
                      labelText: AppLocalizations.of(context)!.password,
                      suffixIcon: Icons.lock),
                  keyboardType: TextInputType.text,
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                TextFieldWidget(
                  controller: _confirmPassword,
                  decoration: TextFieldStyles.saucyInputDecoration(
                      hintText: AppLocalizations.of(context)!.confirmPassword,
                      labelText: AppLocalizations.of(context)!.confirmPassword,
                      suffixIcon: Icons.lock),
                  keyboardType: TextInputType.text,
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                Container(
                  width: 0,
                  height: 50,
                  child: TextButton(
                    onPressed: () async {
                      final userName = _userNameController.text;
                      final email = _email.text;
                      final password = _password.text;
                      final name = _nameController.text;
                      final confirmPassword = _confirmPassword.text;
                      String? registrationStatus;

                      if (password != confirmPassword) {
                        await showErrorDialog(context,
                            AppLocalizations.of(context)!.passwordNotMatch);
                        return;
                      }
                      if (await _isUserNameTaken(userName)) {
                        // Inform the user that the user name is already taken
                        await showErrorDialog(context,
                            AppLocalizations.of(context)!.userNameTaken);
                        return;
                      }

                      try {
                        // The await keyword is used to wait for the registration process to complete before proceeding.
                        registrationStatus = await AuthService.firebase()
                            .createUser(
                                userName: userName,
                                name: name,
                                email: email,
                                password: password);
                        // Sign in the user after successful registration
                        await AuthService.firebase()
                            .logIn(email: email, password: password);
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.verifyEmailRoute, (route) => false);
                      } on WeakPasswordException {
                        await showErrorDialog(context,
                            AppLocalizations.of(context)!.weakPassword);
                      } on EmailAlreadyUseAuthException {
                        await showErrorDialog(
                            context, AppLocalizations.of(context)!.emailTaken);
                      } on InvalidEmailAuthException {
                        await showErrorDialog(context,
                            AppLocalizations.of(context)!.invalidEmail);
                      } on GenericAuthException {
                        await showErrorDialog(context,
                            AppLocalizations.of(context)!.registrationError);
                      }
                      ;
                      if (registrationStatus != null) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Registration Status'),
                                content: registrationStatus != null
                                    ? Text(registrationStatus)
                                    : const Text('Registration failed'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              );
                            });
                      }
                    },
                    style: ColorProperties.defaultButton(),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (event) {
                        setState(() {
                          buttonHovered = true;
                        });
                      },
                      onExit: (event) {
                        setState(() {
                          buttonHovered = false;
                        });
                      },
                      child: Text(
                        AppLocalizations.of(context)!.register,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pushNamed(context, AppRoutes.loginRoute);
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (event) {
                      setState(() {
                        buttonHovered = true;
                      });
                    },
                    onExit: (event) {
                      setState(() {
                        buttonHovered = false;
                      });
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: AppLocalizations.of(context)!
                                  .alreadyRegistered,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              )),
                          TextSpan(
                            text: AppLocalizations.of(context)!.login,
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              // decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    // backgroundColor: const Color.fromARGB(255, 180, 189, 197),
  }
}
