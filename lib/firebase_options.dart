import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyAo4mODOc9RcOjjPRsMhnjyEPDAuIzqPXM',
    appId: '1:413766033013:web:618e6bc618f066283e623c',
    messagingSenderId: '413766033013',
    projectId: 'tiktok-375bc',//A B C D E F G H I J K L M N O P Q R S T U V W X Y Z, NOW I KNOW MY ABC NEXT TIME I WANT U SAY WITH ME
    // A for Apple,B for Ball , C for Cat, D for Dog,
    // E for elephant, F for fog, G for gun,  H for hen,
    // I for ink, J for jack, K for kangaroo, L for lion,
    // M for monkey, N for neck, O for Orange, P for potato,
    // Q for queen, R for rain,S for sun,T for telephone ,U for umbrella,
    // V for vein ,W for wood,X for xray,Y for young ,Z for zebra,


    authDomain: 'tiktok-375bc.firebaseapp.com',
    databaseURL: 'https://tiktok-375bc-default-rtdb.firebaseio.com',
    storageBucket: 'tiktok-375bc.firebasestorage.app',
    measurementId: 'G-T57NRRHDGR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCsibnoebvyp_-K9EX02y9EqgscE2lwxwM',
    appId: '1:413766033013:android:55131210345e40de3e623c',
    messagingSenderId: '413766033013',
    projectId: 'tiktok-375bc',
    databaseURL: 'https://tiktok-375bc-default-rtdb.firebaseio.com',
    storageBucket: 'tiktok-375bc.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDVSZNvRvaAvsrLruzAP32fXUtoE5WYJHM',
    appId: '1:413766033013:ios:3d59497727e611563e623c',
    messagingSenderId: '413766033013',
    projectId: 'tiktok-375bc',
    databaseURL: 'https://tiktok-375bc-default-rtdb.firebaseio.com',
    storageBucket: 'tiktok-375bc.firebasestorage.app',
    iosClientId: '413766033013-al6a4blb2n3kqsvr62rokq6uk0rt5f59.apps.googleusercontent.com',
    iosBundleId: 'com.example.untitled17',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDVSZNvRvaAvsrLruzAP32fXUtoE5WYJHM',
    appId: '1:413766033013:ios:3d59497727e611563e623c',
    messagingSenderId: '413766033013',
    projectId: 'tiktok-375bc',
    databaseURL: 'https://tiktok-375bc-default-rtdb.firebaseio.com',
    storageBucket: 'tiktok-375bc.firebasestorage.app',
    iosClientId: '413766033013-al6a4blb2n3kqsvr62rokq6uk0rt5f59.apps.googleusercontent.com',
    iosBundleId: 'com.example.untitled17',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAo4mODOc9RcOjjPRsMhnjyEPDAuIzqPXM',
    appId: '1:413766033013:web:d1843b751d8c852a3e623c',
    messagingSenderId: '413766033013',
    projectId: 'tiktok-375bc',
    authDomain: 'tiktok-375bc.firebaseapp.com',
    databaseURL: 'https://tiktok-375bc-default-rtdb.firebaseio.com',
    storageBucket: 'tiktok-375bc.firebasestorage.app',
    measurementId: 'G-YJV98844XN',
  );
}
