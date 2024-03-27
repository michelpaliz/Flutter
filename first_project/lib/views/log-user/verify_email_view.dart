import 'package:first_project/enums/routes/routes.dart';
import 'package:first_project/services/auth/logic_backend/auth_service.dart';
import 'package:flutter/material.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  void initState() {
    super.initState();
    _sendEmailVerification();
  }

  // Function to send the email verification
  Future<void> _sendEmailVerification() async {
    try {
      await AuthService.firebase().sendEmailVerification();
    } catch (error) {
      print('Error sending email verification: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Column(
        children: [
          const Text(
              "We've sent you an email verification, Please open it to verify your account."),
          TextButton(
              onPressed: () async {
                await AuthService.firebase().logOut();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginRoute, (route) => false);
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
