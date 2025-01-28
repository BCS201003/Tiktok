//lib/firebase_option.dart
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
    apiKey: 'AIzaSyBImwOLxGV4kfMIZ2CDh4IPaxIH-hix7_E',
    appId: '1:741663572382:web:13edcb84b00ec05401968f',
    messagingSenderId: '741663572382',
    projectId: 'bloodarranger',
    authDomain: 'bloodarranger.firebaseapp.com',
    databaseURL: 'https://bloodarranger-default-rtdb.firebaseio.com',
    storageBucket: 'bloodarranger.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCWn5tUGZcL81HniLsPxSWSr4ayq2X5uoM',
    appId: '1:741663572382:android:ecd5286029f7c7e501968f',
    messagingSenderId: '741663572382',
    projectId: 'bloodarranger',
    databaseURL: 'https://bloodarranger-default-rtdb.firebaseio.com',
    storageBucket: 'bloodarranger.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAjDSo9CiHmgQ9o8sEg8c6CUlmoUzX7Pyc',
    appId: '1:741663572382:ios:010eccefc914250a01968f',
    messagingSenderId: '741663572382',
    projectId: 'bloodarranger',
    databaseURL: 'https://bloodarranger-default-rtdb.firebaseio.com',
    storageBucket: 'bloodarranger.appspot.com',
    iosBundleId: 'com.example.untitled17',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAjDSo9CiHmgQ9o8sEg8c6CUlmoUzX7Pyc',
    appId: '1:741663572382:ios:010eccefc914250a01968f',
    messagingSenderId: '741663572382',
    projectId: 'bloodarranger',
    databaseURL: 'https://bloodarranger-default-rtdb.firebaseio.com',
    storageBucket: 'bloodarranger.appspot.com',
    iosBundleId: 'com.example.untitled17',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBImwOLxGV4kfMIZ2CDh4IPaxIH-hix7_E',
    appId: '1:741663572382:web:3ecf90d94992145501968f',
    messagingSenderId: '741663572382',
    projectId: 'bloodarranger',
    authDomain: 'bloodarranger.firebaseapp.com',
    databaseURL: 'https://bloodarranger-default-rtdb.firebaseio.com',
    storageBucket: 'bloodarranger.appspot.com',
  );

}