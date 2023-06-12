import 'package:firebase_auth/firebase_auth.dart';
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
          const Text('Please verify your email'),
          TextButton(
            onPressed: () async {
              final currentUser = FirebaseAuth.instance.currentUser;
              await currentUser?.sendEmailVerification();
              // Navigate to another screen after sending the verification email
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const EmailSentView(),
              ));
            },
            child: const Text('Send email verification'),
          ),
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
