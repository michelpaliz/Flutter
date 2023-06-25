import 'package:first_project/constants/routes.dart';
import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:flutter/material.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Column(
        children: [
          const Text(
              "We've sent you an email verification, Please open it to verify your account."),
          const Text(
              "If you haven't recieved your verification email yet, press the button below"),
          TextButton(
            onPressed: () async {
              await AuthService.firebase()
                  .sendEmailVerification(); // Navigate to another screen after sending the verification email
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const EmailSentView(),
              ));
            },
            child: const Text('Send email verification'),
          ),
          TextButton(
              onPressed: () async {
                await AuthService.firebase().logOut();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text('Restart'))
        ],
      ),
    );
  }
}

class EmailSentView extends StatelessWidget {
  const EmailSentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email Sent')),
      body: const Center(
        child: Text('Email sent successfully!'),
      ),
    );
  }
}
