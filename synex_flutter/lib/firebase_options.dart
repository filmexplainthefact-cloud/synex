import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return android;
      case TargetPlatform.iOS: return ios;
      default: return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDjN72zb90c8GzasTiFx-wZHKk_XbL2XPw',
    appId: '1:93914740482:android:d41f8492e8db7f071e741b',
    messagingSenderId: '93914740482',
    projectId: 'dgsell',
    databaseURL: 'https://dgsell-default-rtdb.firebaseio.com',
    storageBucket: 'dgsell.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDjN72zb90c8GzasTiFx-wZHKk_XbL2XPw',
    appId: '1:93914740482:web:d41f8492e8db7f071e741b',
    messagingSenderId: '93914740482',
    projectId: 'dgsell',
    databaseURL: 'https://dgsell-default-rtdb.firebaseio.com',
    storageBucket: 'dgsell.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDjN72zb90c8GzasTiFx-wZHKk_XbL2XPw',
    appId: '1:93914740482:ios:d41f8492e8db7f071e741b',
    messagingSenderId: '93914740482',
    projectId: 'dgsell',
    databaseURL: 'https://dgsell-default-rtdb.firebaseio.com',
    storageBucket: 'dgsell.firebasestorage.app',
    iosClientId: '93914740482-bovs2ucih60opm1k324pf2deqgmi2pfq.apps.googleusercontent.com',
    iosBundleId: 'com.synex.synexLive',
  );
}
