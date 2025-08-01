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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyByP5UQJRaHVQwEhGAYbmA236N_fQHmS8w',
    appId: '1:294783853629:web:574930821bd34219d87654',
    messagingSenderId: '294783853629',
    projectId: 'payroll-6b3ff',
    authDomain: 'payroll-6b3ff.firebaseapp.com',
    storageBucket: 'payroll-6b3ff.firebasestorage.app',
    measurementId: 'G-S3Q3C59X0T',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDWj5dJDbAj1MGBhHXPusf0Si4hDyrmcy4',
    appId: '1:294783853629:android:3b4f9d6171fb1546d87654',
    messagingSenderId: '294783853629',
    projectId: 'payroll-6b3ff',
    storageBucket: 'payroll-6b3ff.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDUPC7Dt_hhwDuIE4QUqOpYahnpELPdidg',
    appId: '1:294783853629:ios:6bc35d417bcd3565d87654',
    messagingSenderId: '294783853629',
    projectId: 'payroll-6b3ff',
    storageBucket: 'payroll-6b3ff.firebasestorage.app',
    iosBundleId: 'com.example.payroll',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyByP5UQJRaHVQwEhGAYbmA236N_fQHmS8w',
    appId: '1:294783853629:web:a18a374d7155d100d87654',
    messagingSenderId: '294783853629',
    projectId: 'payroll-6b3ff',
    authDomain: 'payroll-6b3ff.firebaseapp.com',
    storageBucket: 'payroll-6b3ff.firebasestorage.app',
    measurementId: 'G-9921Z8GHFV',
  );
}
