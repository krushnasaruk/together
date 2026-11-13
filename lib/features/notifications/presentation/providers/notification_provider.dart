import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/notification_model.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../../core/services/cloud_sync_service.dart';

class NotificationNotifier extends StateNotifier<List<NotificationItem>> {
  static const String _prefKey = 'together_notifications_feed';
  final Ref _ref;
  StreamSubscription? _cloudSub;

  NotificationNotifier(this._ref) : super([]) {
    _loadNotifications();
    _initCloudSync();
  }

  void _initCloudSync() {
    _ref.listen<AuthState>(authProvider, (previous, next) {
      final newCoupleId = next.currentUser.coupleId;
      if (newCoupleId != null &&
          newCoupleId != previous?.currentUser.coupleId) {
        _subscribeToCloud(newCoupleId);
      }
    });

    final currentCoupleId = _ref.read(authProvider).currentUser.coupleId;
    if (currentCoupleId != null) {
      _subscribeToCloud(currentCoupleId);
    }
  }

  void _subscribeToCloud(String coupleId) {
    _cloudSub?.cancel();
    _cloudSub = _ref
        .read(cloudSyncServiceProvider)
        .streamNotifications(coupleId)
        .listen((cloudNotifs) {
      final currentUserId = _ref.read(authProvider).currentUser.uid;
      // Check if new incoming notification for me
      if (cloudNotifs.isNotEmpty && state.isNotEmpty) {
        final newest = cloudNotifs.first;
        final alreadyKnown = state.any((n) => n.id == newest.id);
        if (!alreadyKnown && newest.recipientId == currentUserId) {
          _ref.read(inAppNotificationBannerProvider.notifier).state = newest;
        }
      }
      state = cloudNotifs;
      _saveToPrefs();
    }, onError: (e) {
      debugPrint('Cloud notifications sync note: $e');
    });
  }

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_prefKey);
      if (data != null) {
        final list = (jsonDecode(data) as List)
            .map((item) =>
                NotificationItem.fromJson(item as Map<String, dynamic>))
            .toList();
        state = list;
        return;
      }
    } catch (_) {}

    // Clean slate with no dummy notifications
    state = const [];
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(state.map((e) => e.toJson()).toList());
      await prefs.setString(_prefKey, raw);
    } catch (_) {}
  }

  /// Send an automated notification to the other partner
  void dispatchNotificationToPartner({
    required String senderId,
    required String senderName,
    required NotificationType type,
    required String title,
    required String body,
    String? entityId,
  }) {
    final authState = _ref.read(authProvider);
    final recipientId = authState.currentUser.partnerId ??
        (senderId == 'user_alex' ? 'user_taylor' : 'user_alex');

    final item = NotificationItem(
      id: const Uuid().v4(),
      recipientId: recipientId,
      senderId: senderId,
      senderName: senderName,
      type: type,
      title: title,
      body: body,
      entityId: entityId,
      isRead: false,
      createdAt: DateTime.now(),
    );

    state = [item, ...state];
    _saveToPrefs();

    // Trigger instant in-app notification popup
    _ref.read(inAppNotificationBannerProvider.notifier).state = item;

    // Sync notification to cloud
    final coupleId = authState.currentUser.coupleId;
    if (coupleId != null) {
      _ref.read(cloudSyncServiceProvider).saveNotification(coupleId, item);
    }
  }

  void markAsRead(String id) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(isRead: true);
      }
      return item;
    }).toList();
    _saveToPrefs();
  }

  void markAllAsRead(String currentUserId) {
    state = state.map((item) {
      if (item.recipientId == currentUserId) {
        return item.copyWith(isRead: true);
      }
      return item;
    }).toList();
    _saveToPrefs();
  }

  void clearNotifications(String currentUserId) {
    state = state.where((item) => item.recipientId != currentUserId).toList();
    _saveToPrefs();
  }

  @override
  void dispose() {
    _cloudSub?.cancel();
    super.dispose();
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<NotificationItem>>((ref) {
  return NotificationNotifier(ref);
});

/// Unread count specifically for current user
final unreadNotificationCountProvider = Provider<int>((ref) {
  final currentUserId = ref.watch(authProvider).currentUser.uid;
  final notifications = ref.watch(notificationProvider);
  return notifications
      .where((n) => n.recipientId == currentUserId && !n.isRead)
      .length;
});

/// Live in-app banner provider for instant drop-down popups
final inAppNotificationBannerProvider =
    StateProvider<NotificationItem?>((ref) => null);

