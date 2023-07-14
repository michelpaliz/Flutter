import 'dart:developer' as devtools show log;
import 'package:first_project/constants/routes.dart';
import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:first_project/services/firestore/firestore_exceptions.dart';
import 'package:first_project/services/user/user_provider.dart';
import 'package:first_project/views/add_note.dart';
import 'package:first_project/views/edit_note_screen.dart';
import 'package:first_project/views/login_view.dart';
import 'package:first_project/views/notes_view.dart';
import 'package:first_project/views/register_view.dart';
import 'package:first_project/views/verify_email_view.dart';
import 'package:flutter/material.dart';

import 'costume_widgets/my_drawer_header.dart';
import 'enums/menu_action.dart';

enum DrawerSections {
  dashboard,
  notes_view,
  settings,
}

//**Logic for my view */
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.firebase().initialize();
  try {
    currentUser = await getCurrentUser(); // Initialize Firebase
  } catch (error) {
    currentUser = null;
    throw UserNotFoundException();
  }
  runApp(const MyApp());
}

Widget MyDrawerList(BuildContext context) {
  return Container(
    padding: EdgeInsets.only(
      top: 15,
    ),
    child: Column(
      children: [
        menuItem(context, DrawerSections.dashboard, 'Dashboard', Icons.dashboard, true),
        menuItem(context, DrawerSections.notes_view, 'Notes View', Icons.notes, false),
        menuItem(context, DrawerSections.settings, 'Logout', Icons.logout, false),
      ],
    ),
  );
}

Widget menuItem(BuildContext context, DrawerSections section, String name, IconData iconData, bool selected) {
  return Material(
    child: InkWell(
      onTap: () {
        switch (section) {
          case DrawerSections.dashboard:
            // Handle dashboard section tap
            break;
          case DrawerSections.notes_view:
            // Handle notes view section tap
            Navigator.pushNamed(context, notesRoute);
            break;
          case DrawerSections.settings:
            // Handle logout section tap
            // Perform logout actions...
            break;
        }
      },
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: Row(
          children: [
            Expanded(
              child: Icon(
                iconData,
                size: 20,
                color: Colors.black,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                name,
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

//** UI for my view */
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
        addNote: (context) => EventNoteWidget(),
        editNote: (context) => EditNoteScreen(),
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
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("MICHEL'S SCHEDULE"),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (_) => false);
                  }
                  break;
                default:
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [MyHeaderDrawer(), MyDrawerList(context)],
            ),
          ),
        ),
      ),
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

  Future<bool> showLogOutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Log out'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }
}


