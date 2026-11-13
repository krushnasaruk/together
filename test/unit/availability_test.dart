import 'package:flutter_test/flutter_test.dart';
import 'package:together/features/availability/domain/services/availability_calculator.dart';
import 'package:together/features/events/domain/models/event_model.dart';

void main() {
  group('AvailabilityCalculator Unit Tests', () {
    final testDate = DateTime(2026, 11, 13);

    test('Empty events list returns whole day as potential open window', () {
      final windows = AvailabilityCalculator.calculateSharedFreeWindows(
        events: [],
        date: testDate,
        dayStartHour: 8,
        dayEndHour: 22,
      );

      expect(windows.length, equals(1));
      expect(windows.first.start, equals(DateTime(2026, 11, 13, 8, 0)));
      expect(windows.first.end, equals(DateTime(2026, 11, 13, 22, 0)));
      expect(windows.first.duration.inHours, equals(14));
    });

    test('Private events strictly count as busy intervals', () {
      final privateEvent = CalendarEvent(
        id: 'e1',
        coupleId: 'c1',
        ownerId: 'u1',
        ownerName: 'Alex',
        title: 'Secret Dentist',
        startTime: DateTime(2026, 11, 13, 10, 0),
        endTime: DateTime(2026, 11, 13, 12, 0),
        visibility: EventVisibility.private,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final windows = AvailabilityCalculator.calculateSharedFreeWindows(
        events: [privateEvent],
        date: testDate,
        dayStartHour: 8,
        dayEndHour: 18,
      );

      // Window 1: 8:00 - 10:00 (2h free)
      // Window 2: 12:00 - 18:00 (6h free)
      expect(windows.length, equals(2));
      expect(windows[0].start.hour, equals(8));
      expect(windows[0].end.hour, equals(10));
      expect(windows[1].start.hour, equals(12));
      expect(windows[1].end.hour, equals(18));
    });

    test('Cancelled events are excluded and do NOT block availability', () {
      final cancelledEvent = CalendarEvent(
        id: 'e2',
        coupleId: 'c1',
        ownerId: 'u1',
        ownerName: 'Alex',
        title: 'Cancelled Meeting',
        startTime: DateTime(2026, 11, 13, 10, 0),
        endTime: DateTime(2026, 11, 13, 12, 0),
        status: EventStatus.cancelled,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final windows = AvailabilityCalculator.calculateSharedFreeWindows(
        events: [cancelledEvent],
        date: testDate,
        dayStartHour: 8,
        dayEndHour: 18,
      );

      // Entire 8:00 - 18:00 remains free
      expect(windows.length, equals(1));
      expect(windows.first.duration.inHours, equals(10));
    });

    test(
        'Overlapping events from both partners are merged into a single busy block',
        () {
      // Alex busy 10:00 - 12:00
      final alexEvent = CalendarEvent(
        id: 'e_alex',
        coupleId: 'c1',
        ownerId: 'user_alex',
        ownerName: 'Alex',
        title: 'Sprint Planning',
        startTime: DateTime(2026, 11, 13, 10, 0),
        endTime: DateTime(2026, 11, 13, 12, 0),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Taylor busy 11:00 - 13:00 (overlaps with Alex)
      final taylorEvent = CalendarEvent(
        id: 'e_taylor',
        coupleId: 'c1',
        ownerId: 'user_taylor',
        ownerName: 'Taylor',
        title: 'Design Critique',
        startTime: DateTime(2026, 11, 13, 11, 0),
        endTime: DateTime(2026, 11, 13, 13, 0),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final windows = AvailabilityCalculator.calculateSharedFreeWindows(
        events: [alexEvent, taylorEvent],
        date: testDate,
        dayStartHour: 8,
        dayEndHour: 18,
      );

      // Combined busy block: 10:00 - 13:00
      // Window 1: 8:00 - 10:00
      // Window 2: 13:00 - 18:00
      expect(windows.length, equals(2));
      expect(windows[0].start.hour, equals(8));
      expect(windows[0].end.hour, equals(10));
      expect(windows[1].start.hour, equals(13));
      expect(windows[1].end.hour, equals(18));
    });
  });
}
