import 'package:first_project/f-themes/widgets/view-item-styles/app_bar_styles.dart';
import 'package:flutter/material.dart';

import 'register_form.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppBarStyles.themeData,
      child: Scaffold(
        appBar: AppBar(title: const Text("SCHEDULE")),
        body: const SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 5.0),
            child: RegisterForm(),
          ),
        ),
      ),
    );
  }
}
