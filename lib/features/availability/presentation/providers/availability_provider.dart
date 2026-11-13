import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../events/presentation/providers/event_provider.dart';
import '../../domain/models/free_window.dart';
import '../../domain/services/availability_calculator.dart';

/// Riverpod family provider computing potential shared free windows for a given date.
final sharedFreeWindowsProvider =
    Provider.family<List<FreeWindow>, DateTime>((ref, targetDate) {
  final events = ref.watch(eventsForDateProvider(targetDate));

  return AvailabilityCalculator.calculateSharedFreeWindows(
    events: events,
    date: targetDate,
  );
});
