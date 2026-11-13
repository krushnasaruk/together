import 'package:shared_preferences/shared_preferences.dart';

/// Storage service for persisting tour completion status across app sessions.
class GuidedTourStorage {
  static const String _keyPrefix = 'together_tour_';

  const GuidedTourStorage();

  Future<bool> isTourCompleted(String tourId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_keyPrefix$tourId') ?? false;
  }

  Future<void> setTourCompleted(String tourId, [bool completed = true]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_keyPrefix$tourId', completed);
  }

  Future<void> resetTour(String tourId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$tourId');
  }

  Future<void> resetAllTours() async {
    final prefs = await SharedPreferences.getInstance();
    final keys =
        prefs.getKeys().where((k) => k.startsWith(_keyPrefix)).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}
