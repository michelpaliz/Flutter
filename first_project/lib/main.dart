import 'package:firebase_core/firebase_core.dart';
import 'package:first_project/lib/utilities.dart';
import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:first_project/services/firestore_database/implements/firestore_service.dart';
import 'package:first_project/views/my_app.dart';
import 'package:first_project/provider/provider_management.dart';
import 'package:first_project/provider/theme_preference_provider.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;
//** Logic for my view */
// main.dart
import 'package:provider/provider.dart';

import 'models/group.dart';
import 'models/user.dart';
// ...

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Utilities.loadCustomFonts();
  await initializeApp();
}

Future<void> initializeApp() async {
  try {
    await Firebase.initializeApp();
    await Utilities.loadCustomFonts();
    // Load translations
  } catch (error) {
    print('Error initializing app: $error');
    // Handle error appropriately
    return;
  }
  final AuthService authService = AuthService.firebase();
  User? user = await authService.generateUserCustomModel();

  devtools.log("THIS IS THE MAIN $user");
  await AppInitializer.goToMainDirectly(user);
  // if (user == null) {
  //   runApp(
  //     MaterialApp(
  //         home: Builder(
  //           builder: (context) => LoginView(
  //             //We call here the callBack from the loginView
  //             onLoginSuccess: (user) async {
  //               devtools.log('This is the register user from the login $user');
  //               await AppInitializer.goToMain(context, user);
  //             },
  //           ),
  //         ),
  //         routes: {registerRoute: (context) => const RegisterView()}),
  //   );
  // } else {
  //   await AppInitializer.goToMainDirectly(user);
  // }
}

class AppInitializer {
  static ProviderManagement? providerManagement;
  static ThemePreferenceProvider? themePreferenceProvider;
  static FirestoreService? storeService; // Declare storeService

  /// Navigates to the main application, initializing necessary services and providers.
  static Future<void> goToMain(BuildContext context, User user) async {
    await setServices(user);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MultiProvider(
          providers: [
            // Provide the ProviderManagement instance using ChangeNotifierProvider
            ChangeNotifierProvider<ProviderManagement>.value(
              value: providerManagement!,
            ),
            // Provide the ThemePreferenceProvider instance using ChangeNotifierProvider
            ChangeNotifierProvider<ThemePreferenceProvider>.value(
              value: themePreferenceProvider!,
            ),
            // Provide the StoreService instance using Provider
            Provider<FirestoreService>.value(value: storeService!),
          ],
          child: MyApp(currentUser: user),
        ),
      ),
    );
  }

  /// Directly initializes the main application, skipping the login view.
  static Future<void> goToMainDirectly(User? user) async {
    await setServices(user);

    runApp(
      MultiProvider(
        providers: [
          // Provide the ProviderManagement instance using ChangeNotifierProvider
          ChangeNotifierProvider<ProviderManagement>.value(
            value: providerManagement!,
          ),
          // Provide the ThemePreferenceProvider instance using ChangeNotifierProvider
          ChangeNotifierProvider<ThemePreferenceProvider>.value(
            value: themePreferenceProvider!,
          ),
          // Provide the StoreService instance using Provider
          Provider<FirestoreService>.value(value: storeService!),
        ],
        child: MyApp(currentUser: user),
      ),
    );
  }

  /// Initializes necessary services and sets up providers.
  static Future<void> setServices(User? user) async {
    final AuthService authService = AuthService.firebase();

    // Initialize the ProviderManagement instance
    providerManagement = ProviderManagement(user: user);
    // Initialize the ThemePreferenceProvider instance
    themePreferenceProvider = ThemePreferenceProvider();
    // Initialize the StoreService instance
    storeService = FirestoreService.firebase(providerManagement!);

    // Fetch user groups for the provider
    List<Group>? fetchedGroups =
        await storeService!.fetchUserGroups(authService.costumeUser?.groupIds);

    // Set the fetched user groups into the ProviderManagement
    providerManagement!.setGroups = fetchedGroups;
  }
}
