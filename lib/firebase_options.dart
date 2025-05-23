// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBLhDuykjN5LW_bTNbIfFz0Zp5w5AfHSZI',
    appId: '1:194283088715:android:6db377f8c0a5eee90b56ce',
    messagingSenderId: '194283088715',
    projectId: 'solutionchalleng2025-cnu',
    storageBucket: 'solutionchalleng2025-cnu.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDW7SRuQ6xggHdsveH3lniTN95PACCRTa8',
    appId: '1:194283088715:ios:2db458e7010a13bc0b56ce',
    messagingSenderId: '194283088715',
    projectId: 'solutionchalleng2025-cnu',
    storageBucket: 'solutionchalleng2025-cnu.firebasestorage.app',
    iosBundleId: 'com.example.naviya',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAj4D986T-2N9CWjdEqL2LofG-MDNjR4Uw',
    appId: '1:194283088715:web:22fd100955ec24e80b56ce',
    messagingSenderId: '194283088715',
    projectId: 'solutionchalleng2025-cnu',
    authDomain: 'solutionchalleng2025-cnu.firebaseapp.com',
    storageBucket: 'solutionchalleng2025-cnu.firebasestorage.app',
    measurementId: 'G-L0T395NMEH',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAj4D986T-2N9CWjdEqL2LofG-MDNjR4Uw',
    appId: '1:194283088715:web:504a4beaa25ac3ba0b56ce',
    messagingSenderId: '194283088715',
    projectId: 'solutionchalleng2025-cnu',
    authDomain: 'solutionchalleng2025-cnu.firebaseapp.com',
    storageBucket: 'solutionchalleng2025-cnu.firebasestorage.app',
    measurementId: 'G-NEHN5G8282',
  );

}