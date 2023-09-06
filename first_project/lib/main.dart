import 'dart:developer' as devtools show log;
import 'package:firebase_core/firebase_core.dart';
import 'package:first_project/constants/routes.dart';
import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:first_project/services/firestore/firestore_exceptions.dart';
import 'package:first_project/services/user/user_provider.dart';
import 'package:first_project/views/add_note.dart';
import 'package:first_project/views/edit_group.dart';
import 'package:first_project/views/group_details.dart';
import 'package:first_project/views/show_notifications.dart';
import 'package:first_project/views/dashboard.dart';
import 'package:first_project/views/edit_note_screen.dart';
import 'package:first_project/views/login_view.dart';
import 'package:first_project/views/notes_view.dart';
import 'package:first_project/views/register_view.dart';
import 'package:first_project/views/create_group.dart';
import 'package:first_project/views/verify_email_view.dart';
import 'package:flutter/material.dart';
import 'costume_widgets/drawer/my_drawer.dart';
import 'models/group.dart';
import 'models/user.dart';

//** Logic for my view */
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (error) {
    print('Error initializing Firebase: $error');
  }

  // Check the current user's authentication status
  User? currentUser;
  try {
    currentUser =
        await getCurrentUser(); // Replace with your authentication method
  } catch (error) {
    currentUser = null;
    UserNotFoundException();
  }

  runApp(MyApp(currentUser: currentUser));
}

//** UI for my view */
class MyApp extends StatelessWidget {
  final User? currentUser;

  const MyApp({Key? key, this.currentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = currentUser != null;

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        loginRoute: (context) => const LoginViewState(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        editNote: (context) => EditNoteScreen(),
        dashboard: (context) => Dashboard(),
        createGroup: (context) => CreateGroup(),
        showNotifications: (context) => ShowNotifications(),
        editGroup: (context) {
          final group = ModalRoute.of(context)?.settings.arguments as Group?;
          if (group != null) {
            return EditGroup(group: group);
          }
          // Handle the case when no group is passed
          return SizedBox
              .shrink(); // Return an empty widget or handle the error
        },
        groupDetails: (context) {
          final group = ModalRoute.of(context)?.settings.arguments as Group?;
          if (group != null) {
            return GroupDetails(group: group);
          }
          // Handle the case when no group is passed
          return SizedBox
              .shrink(); // Return an empty widget or handle the error
        },
        addNote: (context) {
          final dynamic arg = ModalRoute.of(context)?.settings.arguments;

          User? user;
          Group? group;

          if (arg is User) {
            user = arg;
          } else if (arg is Group) {
            group = arg;
          }

          return EventNoteWidget(user: user, group: group);
        },
      },
      home: isLoggedIn ? const HomePage() : const LoginViewState(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      body: FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final currentUser = AuthService.firebase().currentUser;
              if (currentUser != null) {
                final emailVerified = currentUser.isEmailVerified;
                devtools.log('Is verified ? $emailVerified');
                if (emailVerified) {
                  return const NotesView();
                } else {
                  return const VerifyEmailView();
                }
              } else {
                return const LoginViewState();
              }
            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      ),
    );
  }
}
