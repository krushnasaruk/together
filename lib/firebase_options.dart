import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Together Firebase configuration.
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
    apiKey: 'AIzaSyTogetherDevWebKeyPlaceholder123',
    appId: '1:100000000000:web:togetherwebappdev1',
    messagingSenderId: '100000000000',
    projectId: 'together-couples-app',
    authDomain: 'together-couples-app.firebaseapp.com',
    storageBucket: 'together-couples-app.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyTogetherDevAndroidKeyPlaceholder123',
    appId: '1:100000000000:android:togetherandroiddev1',
    messagingSenderId: '100000000000',
    projectId: 'together-couples-app',
    storageBucket: 'together-couples-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyTogetherDevIosKeyPlaceholder123',
    appId: '1:100000000000:ios:togetheriosdev1',
    messagingSenderId: '100000000000',
    projectId: 'together-couples-app',
    storageBucket: 'together-couples-app.appspot.com',
    iosBundleId: 'com.together.together',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyTogetherDevMacKeyPlaceholder123',
    appId: '1:100000000000:ios:togethermacosdev1',
    messagingSenderId: '100000000000',
    projectId: 'together-couples-app',
    storageBucket: 'together-couples-app.appspot.com',
    iosBundleId: 'com.together.together',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyTogetherDevWinKeyPlaceholder123',
    appId: '1:100000000000:web:togetherwindev1',
    messagingSenderId: '100000000000',
    projectId: 'together-couples-app',
    authDomain: 'together-couples-app.firebaseapp.com',
    storageBucket: 'together-couples-app.appspot.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyTogetherDevLinuxKeyPlaceholder123',
    appId: '1:100000000000:web:togetherlinuxdev1',
    messagingSenderId: '100000000000',
    projectId: 'together-couples-app',
    authDomain: 'together-couples-app.firebaseapp.com',
    storageBucket: 'together-couples-app.appspot.com',
  );
}
