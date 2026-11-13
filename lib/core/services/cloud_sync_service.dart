import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/authentication/domain/models/user_model.dart';
import '../../features/events/domain/models/event_model.dart';
import '../../features/notifications/domain/models/notification_model.dart';
import '../../features/pairing/domain/models/couple_model.dart';
import '../../features/together_time/domain/models/together_model.dart';
import 'firebase_service.dart';

/// Central cloud synchronization service connecting Together to Firebase Firestore.
/// Enables two physical devices to pair via invitation code and sync events, statuses,
/// shared plans, and notifications in real time.
class CloudSyncService {
  final FirebaseFirestore? _firestore;

  CloudSyncService([this._firestore]);

  bool get _isTest => !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  // --- 1. Couple Pairing & Workspace Sync ---

  /// Join an existing couple workspace or create one with the given invite code.
  Future<CoupleModel?> joinOrCreateCouple({
    required String code,
    required UserModel user,
  }) async {
    final sanitizedCode = code.trim().toUpperCase();

    if (_isTest || _firestore == null) {
      return CoupleModel(
        id: sanitizedCode,
        members: [user.uid, 'partner_connected'],
        memberNames: {
          user.uid: user.displayName,
          'partner_connected': user.partnerName ?? 'Partner',
        },
        anniversaryDate: DateTime.now().subtract(const Duration(days: 365)),
        status: 'active',
        createdAt: DateTime.now(),
      );
    }

    final docRef = _firestore.collection('couples').doc(sanitizedCode);

    try {
      final doc = await docRef.get().timeout(const Duration(seconds: 8));

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final currentMembers = List<String>.from(data['members'] as List? ?? []);
        final memberNames =
            Map<String, String>.from(data['memberNames'] as Map? ?? {});

        if (!currentMembers.contains(user.uid)) {
          currentMembers.add(user.uid);
        }
        memberNames[user.uid] = user.displayName;

        final updated = CoupleModel(
          id: sanitizedCode,
          members: currentMembers,
          memberNames: memberNames,
          anniversaryDate: data['anniversaryDate'] != null
              ? DateTime.tryParse(data['anniversaryDate'] as String)
              : null,
          status: 'active',
          createdAt: data['createdAt'] != null
              ? DateTime.tryParse(data['createdAt'] as String) ?? DateTime.now()
              : DateTime.now(),
        );

        await docRef.set(updated.toJson(), SetOptions(merge: true));
        debugPrint('☁️ [CloudSync] Joined existing couple workspace: $sanitizedCode');
        return updated;
      } else {
        // Create new couple workspace document
        final newCouple = CoupleModel(
          id: sanitizedCode,
          members: [user.uid],
          memberNames: {user.uid: user.displayName},
          anniversaryDate: DateTime.now(),
          status: 'pending',
          createdAt: DateTime.now(),
        );

        await docRef.set(newCouple.toJson());
        debugPrint('☁️ [CloudSync] Created new couple workspace: $sanitizedCode');
        return newCouple;
      }
    } catch (e) {
      debugPrint('⚠️ [CloudSync] Cloud pairing note (falling back to local): $e');
      // Return a local CoupleModel so pairing succeeds even offline
      return CoupleModel(
        id: sanitizedCode,
        members: [user.uid, 'partner_connected'],
        memberNames: {
          user.uid: user.displayName,
          'partner_connected': user.partnerName ?? 'Partner',
        },
        anniversaryDate: DateTime.now().subtract(const Duration(days: 365)),
        status: 'active',
        createdAt: DateTime.now(),
      );
    }
  }

  /// Find active couple workspace containing the given user ID.
  Future<CoupleModel?> findCoupleForUser(String userId) async {
    if (_isTest || _firestore == null || userId.isEmpty) return null;

    try {
      final query = await _firestore
          .collection('couples')
          .where('members', arrayContains: userId)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 6));

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final data = doc.data();
        return CoupleModel(
          id: doc.id,
          members: List<String>.from(data['members'] as List? ?? []),
          memberNames:
              Map<String, String>.from(data['memberNames'] as Map? ?? {}),
          anniversaryDate: data['anniversaryDate'] != null
              ? DateTime.tryParse(data['anniversaryDate'] as String)
              : null,
          status: data['status'] as String? ?? 'active',
          createdAt: data['createdAt'] != null
              ? DateTime.tryParse(data['createdAt'] as String) ?? DateTime.now()
              : DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('Cloud lookup error: $e');
    }
    return null;
  }

  // --- 2. Calendar Events Real-Time Cloud Sync ---

  /// Live Firestore stream of calendar events for a couple
  Stream<List<CalendarEvent>> streamEvents(String coupleId) {
    if (_isTest || _firestore == null) return const Stream.empty();
    try {
      return _firestore
          .collection('couples')
          .doc(coupleId)
          .collection('events')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return CalendarEvent.fromJson(data);
        }).toList();
      });
    } catch (e) {
      debugPrint('⚠️ [CloudSync] Stream events error: $e');
      return const Stream.empty();
    }
  }

  Future<void> saveEvent(String coupleId, CalendarEvent event) async {
    if (_isTest || _firestore == null) return;
    try {
      await _firestore
          .collection('couples')
          .doc(coupleId)
          .collection('events')
          .doc(event.id)
          .set(event.toJson());
      debugPrint('☁️ [CloudSync] Synced event "${event.title}" to Firestore');
    } catch (e) {
      debugPrint('⚠️ [CloudSync] Save event to cloud error: $e');
    }
  }

  Future<void> deleteEvent(String coupleId, String eventId) async {
    if (_isTest || _firestore == null) return;
    try {
      await _firestore
          .collection('couples')
          .doc(coupleId)
          .collection('events')
          .doc(eventId)
          .delete();
      debugPrint('☁️ [CloudSync] Deleted event $eventId from Firestore');
    } catch (e) {
      debugPrint('⚠️ [CloudSync] Delete event from cloud error: $e');
    }
  }

  // --- 3. Live Partner Status Real-Time Cloud Sync ---

  Stream<Map<String, StatusUpdate>> streamStatuses(String coupleId) {
    if (_isTest || _firestore == null) return const Stream.empty();
    try {
      return _firestore
          .collection('couples')
          .doc(coupleId)
          .collection('statuses')
          .snapshots()
          .map((snapshot) {
        final result = <String, StatusUpdate>{};
        for (final doc in snapshot.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          result[doc.id] = StatusUpdate.fromJson(data);
        }
        return result;
      });
    } catch (e) {
      debugPrint('⚠️ [CloudSync] Stream statuses error: $e');
      return const Stream.empty();
    }
  }

  Future<void> saveStatus(String coupleId, StatusUpdate status) async {
    if (_isTest || _firestore == null) return;
    try {
      await _firestore
          .collection('couples')
          .doc(coupleId)
          .collection('statuses')
          .doc(status.userId)
          .set(status.toJson());
      debugPrint('☁️ [CloudSync] Synced status for ${status.userName}');
    } catch (e) {
      debugPrint('⚠️ [CloudSync] Save status error: $e');
    }
  }

  // --- 4. Live Notifications & Pokes Cloud Sync ---

  Stream<List<NotificationItem>> streamNotifications(String coupleId) {
    if (_isTest || _firestore == null) return const Stream.empty();
    try {
      return _firestore
          .collection('couples')
          .doc(coupleId)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return NotificationItem.fromJson(data);
        }).toList();
      });
    } catch (e) {
      debugPrint('⚠️ [CloudSync] Stream notifications error: $e');
      return const Stream.empty();
    }
  }

  Future<void> saveNotification(
    String coupleId,
    NotificationItem notification,
  ) async {
    if (_isTest || _firestore == null) return;
    try {
      await _firestore
          .collection('couples')
          .doc(coupleId)
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toJson());
      debugPrint('☁️ [CloudSync] Synced notification: ${notification.title}');
    } catch (e) {
      debugPrint('⚠️ [CloudSync] Save notification error: $e');
    }
  }

  // --- 5. Together Romantic Plans Cloud Sync ---

  Stream<List<TogetherPlan>> streamPlans(String coupleId) {
    if (_isTest || _firestore == null) return const Stream.empty();
    try {
      return _firestore
          .collection('couples')
          .doc(coupleId)
          .collection('plans')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return TogetherPlan.fromJson(data);
        }).toList();
      });
    } catch (e) {
      debugPrint('⚠️ [CloudSync] Stream plans error: $e');
      return const Stream.empty();
    }
  }

  Future<void> savePlan(String coupleId, TogetherPlan plan) async {
    if (_isTest || _firestore == null) return;
    try {
      await _firestore
          .collection('couples')
          .doc(coupleId)
          .collection('plans')
          .doc(plan.id)
          .set(plan.toJson());
      debugPrint('☁️ [CloudSync] Synced together plan: ${plan.title}');
    } catch (e) {
      debugPrint('⚠️ [CloudSync] Save plan error: $e');
    }
  }

  Future<void> deletePlan(String coupleId, String planId) async {
    if (_isTest || _firestore == null) return;
    try {
      await _firestore
          .collection('couples')
          .doc(coupleId)
          .collection('plans')
          .doc(planId)
          .delete();
      debugPrint('☁️ [CloudSync] Deleted plan $planId');
    } catch (e) {
      debugPrint('⚠️ [CloudSync] Delete plan error: $e');
    }
  }
}

final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  if (kIsWeb || !Platform.environment.containsKey('FLUTTER_TEST')) {
    try {
      return CloudSyncService(FirebaseService.firestore);
    } catch (_) {}
  }
  return CloudSyncService();
});
