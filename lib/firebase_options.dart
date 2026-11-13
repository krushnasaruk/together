import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for Together connected to the 'together-2c65c' Firebase project.
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
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDlN3hwfUaQoky0yqq_S5YHiW_abBGEoL0',
    appId: '1:43462501856:web:3517c319d3acd693a77785',
    messagingSenderId: '43462501856',
    projectId: 'together-2c65c',
    authDomain: 'together-2c65c.firebaseapp.com',
    storageBucket: 'together-2c65c.firebasestorage.app',
    measurementId: 'G-ELDT51G1HB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDlN3hwfUaQoky0yqq_S5YHiW_abBGEoL0',
    appId: '1:43462501856:web:3517c319d3acd693a77785',
    messagingSenderId: '43462501856',
    projectId: 'together-2c65c',
    authDomain: 'together-2c65c.firebaseapp.com',
    storageBucket: 'together-2c65c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDlN3hwfUaQoky0yqq_S5YHiW_abBGEoL0',
    appId: '1:43462501856:web:3517c319d3acd693a77785',
    messagingSenderId: '43462501856',
    projectId: 'together-2c65c',
    authDomain: 'together-2c65c.firebaseapp.com',
    storageBucket: 'together-2c65c.firebasestorage.app',
    iosBundleId: 'com.together.together',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDlN3hwfUaQoky0yqq_S5YHiW_abBGEoL0',
    appId: '1:43462501856:web:3517c319d3acd693a77785',
    messagingSenderId: '43462501856',
    projectId: 'together-2c65c',
    authDomain: 'together-2c65c.firebaseapp.com',
    storageBucket: 'together-2c65c.firebasestorage.app',
    iosBundleId: 'com.together.together',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDlN3hwfUaQoky0yqq_S5YHiW_abBGEoL0',
    appId: '1:43462501856:web:3517c319d3acd693a77785',
    messagingSenderId: '43462501856',
    projectId: 'together-2c65c',
    authDomain: 'together-2c65c.firebaseapp.com',
    storageBucket: 'together-2c65c.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDlN3hwfUaQoky0yqq_S5YHiW_abBGEoL0',
    appId: '1:43462501856:web:3517c319d3acd693a77785',
    messagingSenderId: '43462501856',
    projectId: 'together-2c65c',
    authDomain: 'together-2c65c.firebaseapp.com',
    storageBucket: 'together-2c65c.firebasestorage.app',
  );
}
