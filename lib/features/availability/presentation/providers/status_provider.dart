import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../notifications/domain/models/notification_model.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

class StatusNotifier extends StateNotifier<Map<String, StatusUpdate>> {
  static const String _prefKey = 'together_partner_statuses';
  final Ref _ref;

  StatusNotifier(this._ref) : super({}) {
    _loadStatuses();
  }

  Future<void> _loadStatuses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_prefKey);
      if (data != null) {
        final map = jsonDecode(data) as Map<String, dynamic>;
        final result = <String, StatusUpdate>{};
        map.forEach((k, v) {
          result[k] = StatusUpdate.fromJson(v as Map<String, dynamic>);
        });
        state = result;
        return;
      }
    } catch (_) {}

    // Seed initial active statuses
    final now = DateTime.now();
    state = {
      'user_alex': StatusUpdate(
        id: 'status_01',
        userId: 'user_alex',
        userName: 'Alex',
        coupleId: 'couple_workspace_01',
        preset: QuickStatusPreset.needFocus,
        customNote: 'Focus sprint until 1:00 PM',
        createdAt: now.subtract(const Duration(minutes: 30)),
        expiresAt: now.add(const Duration(hours: 2)),
      ),
      'user_taylor': StatusUpdate(
        id: 'status_02',
        userId: 'user_taylor',
        userName: 'Taylor',
        coupleId: 'couple_workspace_01',
        preset: QuickStatusPreset.freeNow,
        customNote: 'Finished lecture, grabbed iced matcha 🍵',
        createdAt: now.subtract(const Duration(minutes: 15)),
        expiresAt: now.add(const Duration(hours: 2)),
      ),
    };
    _saveToPrefs();
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = state.map((k, v) => MapEntry(k, v.toJson()));
      await prefs.setString(_prefKey, jsonEncode(map));
    } catch (_) {}
  }

  /// Update the status of the current user and alert the partner
  void setStatus({
    required QuickStatusPreset preset,
    String? customNote,
  }) {
    final auth = _ref.read(authProvider);
    final user = auth.currentUser;
    final now = DateTime.now();

    final update = StatusUpdate(
      id: const Uuid().v4(),
      userId: user.uid,
      userName: user.displayName,
      coupleId: user.coupleId ?? 'couple_workspace_01',
      preset: preset,
      customNote: customNote,
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 2)),
    );

    state = {
      ...state,
      user.uid: update,
    };
    _saveToPrefs();

    // Alert partner
    _ref.read(notificationProvider.notifier).dispatchNotificationToPartner(
          senderId: user.uid,
          senderName: user.displayName,
          type: NotificationType.statusUpdate,
          title: 'Partner Status: ${preset.title} ${preset.emoji}',
          body: customNote != null && customNote.isNotEmpty
              ? '${user.displayName}: "$customNote"'
              : '${user.displayName} is now "${preset.title}"',
          entityId: update.id,
        );
  }
}

final statusProvider =
    StateNotifierProvider<StatusNotifier, Map<String, StatusUpdate>>((ref) {
  return StatusNotifier(ref);
});

/// Returns the status of the other partner
final partnerStatusProvider = Provider<StatusUpdate?>((ref) {
  final currentUserId = ref.watch(authProvider).currentUser.uid;
  final statuses = ref.watch(statusProvider);
  for (final entry in statuses.entries) {
    if (entry.key != currentUserId && !entry.value.isExpired) {
      return entry.value;
    }
  }
  return null;
});
