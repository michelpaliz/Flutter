// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDUS4521eV6lMdZZxWk1I5UaOv81K0dnkE',
    appId: '1:962743140116:web:f5d27c7f002e397638cc01',
    messagingSenderId: '962743140116',
    projectId: 'firstapp-75986',
    authDomain: 'firstapp-75986.firebaseapp.com',
    storageBucket: 'firstapp-75986.appspot.com',
    measurementId: 'G-53WW18P3TK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC_m74g7gEl4z_eYMK5DabndBhRcSr8TUo',
    appId: '1:962743140116:android:c257229235ebc51438cc01',
    messagingSenderId: '962743140116',
    projectId: 'firstapp-75986',
    storageBucket: 'firstapp-75986.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB3rR24YNtysqmgOK_wPIGW01vYtC0lG2I',
    appId: '1:962743140116:ios:12484b79bff38ca238cc01',
    messagingSenderId: '962743140116',
    projectId: 'firstapp-75986',
    storageBucket: 'firstapp-75986.appspot.com',
    iosClientId: '962743140116-5odm8dspv9052oc3c7m61vqijfeh8g2b.apps.googleusercontent.com',
    iosBundleId: 'com.example.firstProject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB3rR24YNtysqmgOK_wPIGW01vYtC0lG2I',
    appId: '1:962743140116:ios:210076729609154338cc01',
    messagingSenderId: '962743140116',
    projectId: 'firstapp-75986',
    storageBucket: 'firstapp-75986.appspot.com',
    iosClientId: '962743140116-4ovu5hgi54ibuuke8qbgk9ba3fcbg2i3.apps.googleusercontent.com',
    iosBundleId: 'com.example.firstProject.RunnerTests',
  );
}
