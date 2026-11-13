import 'package:flutter_test/flutter_test.dart';
import 'package:together/features/pairing/domain/models/couple_model.dart';
import 'package:together/features/notifications/domain/models/notification_model.dart';

void main() {
  group('CoupleModel Domain Tests', () {
    final now = DateTime.now();

    test('CoupleModel identifies partner correctly', () {
      final couple = CoupleModel(
        id: 'couple_01',
        members: ['user_alex', 'user_taylor'],
        memberNames: {
          'user_alex': 'Alex Rivers',
          'user_taylor': 'Taylor Brooks',
        },
        anniversaryDate: DateTime(2025, 9, 12),
        status: 'active',
        createdAt: now,
      );

      expect(couple.isFull, isTrue);
      expect(couple.getPartnerName('user_alex'), 'Taylor Brooks');
      expect(couple.getPartnerId('user_alex'), 'user_taylor');
      expect(couple.getPartnerName('user_taylor'), 'Alex Rivers');
      expect(couple.getPartnerId('user_taylor'), 'user_alex');
      expect(couple.getPartnerName('unknown_user'), isNotNull);
    });

    test('CoupleModel serialization and deserialization', () {
      final couple = CoupleModel(
        id: 'couple_01',
        members: ['user_alex', 'user_taylor'],
        memberNames: {
          'user_alex': 'Alex Rivers',
          'user_taylor': 'Taylor Brooks',
        },
        anniversaryDate: DateTime(2025, 9, 12),
        status: 'active',
        createdAt: DateTime(2025, 9, 12, 10, 0),
      );

      final json = couple.toJson();
      final restored = CoupleModel.fromJson(json);

      expect(restored.id, couple.id);
      expect(restored.members.length, 2);
      expect(restored.status, 'active');
      expect(restored.anniversaryDate, couple.anniversaryDate);
    });
  });

  group('StatusUpdate & NotificationItem Tests', () {
    final now = DateTime.now();

    test('StatusUpdate isExpired works accurately based on expiresAt', () {
      final activeStatus = StatusUpdate(
        id: 'st_1',
        userId: 'user_alex',
        userName: 'Alex',
        coupleId: 'c_1',
        preset: QuickStatusPreset.freeNow,
        createdAt: now,
        expiresAt: now.add(const Duration(hours: 1)),
      );

      expect(activeStatus.isExpired, isFalse);

      final expiredStatus = StatusUpdate(
        id: 'st_2',
        userId: 'user_alex',
        userName: 'Alex',
        coupleId: 'c_1',
        preset: QuickStatusPreset.runningLate,
        createdAt: now.subtract(const Duration(hours: 2)),
        expiresAt: now.subtract(const Duration(minutes: 5)),
      );

      expect(expiredStatus.isExpired, isTrue);
    });

    test('NotificationItem read status and copyWith', () {
      final notification = NotificationItem(
        id: 'notif_1',
        recipientId: 'user_taylor',
        senderId: 'user_alex',
        senderName: 'Alex Rivers',
        type: NotificationType.eventCreated,
        title: 'New Event Added',
        body: 'Alex added: Dinner at Bistro',
        entityId: 'evt_100',
        isRead: false,
        createdAt: now,
      );

      expect(notification.isRead, isFalse);

      final readNotification = notification.copyWith(isRead: true);
      expect(readNotification.isRead, isTrue);
      expect(readNotification.id, notification.id);
      expect(readNotification.title, notification.title);
    });
  });
}
