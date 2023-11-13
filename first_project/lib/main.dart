import 'package:firebase_core/firebase_core.dart';
import 'package:first_project/my-lib/utilities.dart';
import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:first_project/services/firestore/implements/firestore_service.dart';
import 'package:first_project/views/log-user/login_view.dart';
import 'package:first_project/views/my_app.dart';
import 'package:first_project/views/provider/provider_management.dart';
import 'package:first_project/views/provider/theme_preference_provider.dart';
import 'package:flutter/material.dart';
//** Logic for my view */
// main.dart
import 'package:provider/provider.dart';

import 'models/group.dart';
import 'models/user.dart';
// ...


class AppInitializer {
  static void goToMain(BuildContext context, User user) async {
    final AuthService authService = AuthService.firebase();
    ProviderManagement? providerManagement;
    ThemePreferenceProvider? themePreferenceProvider;

    // Set the custom user model in AuthService
    authService.costumeUser = user;
    providerManagement = ProviderManagement(user: user);

    // Create instances of providers
    themePreferenceProvider = ThemePreferenceProvider();

    // Initialize the StoreService by providing the ProviderManagement
    StoreService storeService = StoreService.firebase(providerManagement);

    // Fetched user groups for the provider
    List<Group>? fetchedGroups =
        await storeService.fetchUserGroups(authService.costumeUser?.groupIds);

    // Set the user groups into the service
    providerManagement.setGroups = fetchedGroups;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MultiProvider(
          providers: [
            ChangeNotifierProvider<ProviderManagement>.value(
              value: providerManagement!,
            ),
            ChangeNotifierProvider<ThemePreferenceProvider>.value(
              value: themePreferenceProvider!,
            ),
            Provider<StoreService>.value(value: storeService),
          ],
          child: MyApp(currentUser: user),
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Utilities.loadCustomFonts();
  try {
    await Firebase.initializeApp();
  } catch (error) {
    print('Error initializing Firebase: $error');
  }

  runApp(
    MaterialApp(
      home: Builder(
        builder: (context) => LoginView(
          onLoginSuccess: (user) {
            AppInitializer.goToMain(context, user);
          },
        ),
      ),
    ),
  );
}