/// Central constants for Together.
class AppConstants {
  AppConstants._();

  static const String appName = 'Together';
  static const String appTagline = 'Two lives. One shared space.';

  // Storage / SharedPreferences keys
  static const String keyAuthToken = 'auth_token';
  static const String keyActiveCoupleId = 'active_couple_id';
  static const String keyCachedUser = 'cached_user';

  // Navigation tab indices
  static const int tabToday = 0;
  static const int tabCalendar = 1;
  static const int tabTogether = 2;
  static const int tabProfile = 3;

  // Pairing constants
  static const int inviteCodeLength = 6;
  static const Duration inviteExpiration = Duration(hours: 48);

  // Timeouts & Durations
  static const Duration defaultTimeout = Duration(seconds: 15);
  static const Duration quickStatusDuration = Duration(hours: 2);
}
