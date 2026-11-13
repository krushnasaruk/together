import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

/// Central Firebase configuration and initialization service.
class FirebaseService {
  static bool _initialized = false;
  static const bool useEmulator =
      bool.fromEnvironment('USE_FIREBASE_EMULATOR', defaultValue: false);

  /// Initializes Firebase and optionally connects to local emulators.
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      if (useEmulator) {
        await _connectToEmulators();
      }

      _initialized = true;
    } catch (e, stack) {
      debugPrint(
          'FirebaseService: Initialization warning or error: $e\n$stack');
      // Allow app to continue in offline/preview mode if Firebase cannot initialize
    }
  }

  static Future<void> _connectToEmulators() async {
    const host = '127.0.0.1';
    try {
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
      debugPrint('FirebaseService: Connected to Firebase Emulators on $host');
    } catch (e) {
      debugPrint('FirebaseService: Failed to bind emulators: $e');
    }
  }

  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
}
