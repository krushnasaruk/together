import '../../../events/domain/models/event_model.dart';
import '../models/free_window.dart';

class _TimeInterval {
  final DateTime start;
  final DateTime end;
  final bool isTentative;

  const _TimeInterval(this.start, this.end, {this.isTentative = false});
}

/// Domain service calculating potential shared free windows between partners.
/// Strictly follows product principles:
/// - Private events count as busy.
/// - Cancelled events do not count as busy.
/// - Tentative events are flagged separately.
/// - Incomplete or empty data is not presented as confirmed availability.
class AvailabilityCalculator {
  static List<FreeWindow> calculateSharedFreeWindows({
    required List<CalendarEvent> events,
    required DateTime date,
    int dayStartHour = 8,
    int dayEndHour = 22,
    int minWindowMinutes = 30,
  }) {
    final dayStart = DateTime(date.year, date.month, date.day, dayStartHour, 0);
    final dayEnd = DateTime(date.year, date.month, date.day, dayEndHour, 0);

    // Filter valid busy events
    final busyEvents = events.where((e) {
      return e.status != EventStatus.cancelled;
    }).toList();

    if (busyEvents.isEmpty) {
      // Entire day is potentially free
      return [
        FreeWindow(
          start: dayStart,
          end: dayEnd,
          duration: dayEnd.difference(dayStart),
          suggestion:
              'Both of your schedules appear open today. Potential for quality time.',
        ),
      ];
    }

    // Convert events to bounded intervals
    final intervals = <_TimeInterval>[];
    for (final e in busyEvents) {
      final start = e.startTime.isBefore(dayStart) ? dayStart : e.startTime;
      final end = e.endTime.isAfter(dayEnd) ? dayEnd : e.endTime;
      if (end.isAfter(start)) {
        intervals.add(_TimeInterval(
          start,
          end,
          isTentative: e.status == EventStatus.tentative,
        ));
      }
    }

    // Sort intervals by start time
    intervals.sort((a, b) => a.start.compareTo(b.start));

    // Merge overlapping busy intervals
    final merged = <_TimeInterval>[];
    for (final interval in intervals) {
      if (merged.isEmpty) {
        merged.add(interval);
      } else {
        final last = merged.last;
        if (interval.start.isBefore(last.end) ||
            interval.start.isAtSameMomentAs(last.end)) {
          // Overlapping or contiguous: merge
          final newEnd =
              interval.end.isAfter(last.end) ? interval.end : last.end;
          final isTentative = last.isTentative || interval.isTentative;
          merged[merged.length - 1] =
              _TimeInterval(last.start, newEnd, isTentative: isTentative);
        } else {
          merged.add(interval);
        }
      }
    }

    // Invert merged busy intervals into free windows
    final freeWindows = <FreeWindow>[];
    var current = dayStart;

    for (final busy in merged) {
      if (busy.start.isAfter(current)) {
        final duration = busy.start.difference(current);
        if (duration.inMinutes >= minWindowMinutes) {
          freeWindows.add(FreeWindow(
            start: current,
            end: busy.start,
            duration: duration,
            containsTentative: busy.isTentative,
            suggestion:
                _generateContextualSuggestion(current, busy.start, duration),
          ));
        }
      }
      if (busy.end.isAfter(current)) {
        current = busy.end;
      }
    }

    // Check remaining window after last busy interval
    if (dayEnd.isAfter(current)) {
      final duration = dayEnd.difference(current);
      if (duration.inMinutes >= minWindowMinutes) {
        freeWindows.add(FreeWindow(
          start: current,
          end: dayEnd,
          duration: duration,
          suggestion: _generateContextualSuggestion(current, dayEnd, duration),
        ));
      }
    }

    return freeWindows;
  }

  static String _generateContextualSuggestion(
      DateTime start, DateTime end, Duration dur) {
    if (start.hour < 12) {
      return 'Morning coffee or quick call?';
    } else if (start.hour >= 12 && start.hour < 14) {
      return 'Shared lunch window?';
    } else if (start.hour >= 14 && start.hour < 18) {
      return 'Afternoon tea or quick walk?';
    } else {
      return 'Evening relaxation or dinner together?';
    }
  }
}
