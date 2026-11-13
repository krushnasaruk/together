import 'package:flutter_test/flutter_test.dart';
import 'package:together/features/events/domain/models/event_model.dart';

void main() {
  group('CalendarEvent Domain Model Tests', () {
    final now = DateTime.now();
    const eventOwnerId = 'user_alex';
    const partnerId = 'user_taylor';

    test('Shared event displays true details to partner', () {
      final sharedEvent = CalendarEvent(
        id: 'evt_1',
        coupleId: 'c_1',
        ownerId: eventOwnerId,
        ownerName: 'Alex Rivers',
        title: 'Team Retrospective',
        description: 'Sprint debrief meeting',
        location: 'Design Studio B',
        startTime: now,
        endTime: now.add(const Duration(hours: 1)),
        visibility: EventVisibility.shared,
        createdAt: now,
        updatedAt: now,
      );

      expect(sharedEvent.isMaskedFor(partnerId), isFalse);
      expect(sharedEvent.displayTitleFor(partnerId), 'Team Retrospective');
      expect(sharedEvent.displayDescriptionFor(partnerId),
          'Sprint debrief meeting');
      expect(sharedEvent.displayLocationFor(partnerId), 'Design Studio B');
    });

    test('Private event masks details for partner and reveals Busy only', () {
      final privateEvent = CalendarEvent(
        id: 'evt_2',
        coupleId: 'c_1',
        ownerId: eventOwnerId,
        ownerName: 'Alex Rivers',
        title: 'Confidential Medical Consultation',
        description: 'Health review at downtown clinic',
        location: 'Medical Center Suite 400',
        startTime: now,
        endTime: now.add(const Duration(hours: 1)),
        visibility: EventVisibility.private,
        createdAt: now,
        updatedAt: now,
      );

      // Masked for partner
      expect(privateEvent.isMaskedFor(partnerId), isTrue);
      expect(privateEvent.displayTitleFor(partnerId), 'Busy (Private)');
      expect(privateEvent.displayDescriptionFor(partnerId), isNull);
      expect(privateEvent.displayLocationFor(partnerId), isNull);

      // Unmasked for author/owner
      expect(privateEvent.isMaskedFor(eventOwnerId), isFalse);
      expect(privateEvent.displayTitleFor(eventOwnerId),
          'Confidential Medical Consultation');
      expect(privateEvent.displayDescriptionFor(eventOwnerId),
          'Health review at downtown clinic');
      expect(privateEvent.displayLocationFor(eventOwnerId),
          'Medical Center Suite 400');
    });

    test(
        'Serialization and deserialization preserves all attributes and versioning',
        () {
      final event = CalendarEvent(
        id: 'evt_3',
        coupleId: 'c_1',
        ownerId: eventOwnerId,
        ownerName: 'Alex Rivers',
        title: 'Coffee Tasting',
        description: 'Specialty pour-over workshop',
        location: 'Artisan Roastery',
        startTime: DateTime(2026, 11, 20, 10, 0),
        endTime: DateTime(2026, 11, 20, 11, 30),
        category: EventCategory.personal,
        visibility: EventVisibility.shared,
        status: EventStatus.confirmed,
        recurrence: RecurrenceFrequency.weekly,
        version: 3,
        createdAt: DateTime(2026, 11, 10, 8, 0),
        updatedAt: DateTime(2026, 11, 12, 14, 0),
      );

      final json = event.toJson();
      final restored = CalendarEvent.fromJson(json);

      expect(restored.id, event.id);
      expect(restored.title, event.title);
      expect(restored.category, EventCategory.personal);
      expect(restored.recurrence, RecurrenceFrequency.weekly);
      expect(restored.version, 3);
      expect(restored.startTime, event.startTime);
      expect(restored.endTime, event.endTime);
    });
  });
}
