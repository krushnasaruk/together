import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/event_model.dart';
import '../../../notifications/domain/models/notification_model.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

class EventNotifier extends StateNotifier<List<CalendarEvent>> {
  static const String _prefKey = 'together_calendar_events';
  final Ref _ref;

  EventNotifier(this._ref) : super(const []) {
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_prefKey);
      if (data != null) {
        final list = (jsonDecode(data) as List)
            .map((item) => CalendarEvent.fromJson(item as Map<String, dynamic>))
            .toList();
        state = list;
        return;
      }
    } catch (_) {}
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(state.map((e) => e.toJson()).toList());
      await prefs.setString(_prefKey, raw);
    } catch (_) {}
  }

  /// Add new event and dispatch notification to partner
  void addEvent(CalendarEvent event) {
    state = [...state, event];
    _saveToPrefs();

    // Respect privacy in push notification payloads
    final isPrivate = event.visibility == EventVisibility.private;
    final notifTitle = isPrivate
        ? '${event.ownerName} added a Busy block'
        : 'New Event: ${event.title}';
    final notifBody = isPrivate
        ? '${event.ownerName} is scheduled to be busy at that time.'
        : 'Scheduled for ${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}';

    _ref.read(notificationProvider.notifier).dispatchNotificationToPartner(
          senderId: event.ownerId,
          senderName: event.ownerName,
          type: NotificationType.eventCreated,
          title: notifTitle,
          body: notifBody,
          entityId: event.id,
        );
  }

  /// Update existing event with version increment and notification
  void updateEvent(CalendarEvent updated) {
    final newVersion = updated.version + 1;
    final eventWithVersion = updated.copyWith(
      version: newVersion,
      updatedAt: DateTime.now(),
    );

    state =
        state.map((e) => e.id == updated.id ? eventWithVersion : e).toList();
    _saveToPrefs();

    final isPrivate = eventWithVersion.visibility == EventVisibility.private;
    final notifTitle =
        isPrivate ? 'Schedule Updated' : 'Updated: ${eventWithVersion.title}';
    final notifBody = isPrivate
        ? '${eventWithVersion.ownerName} adjusted their busy schedule.'
        : 'Event details or time modified.';

    _ref.read(notificationProvider.notifier).dispatchNotificationToPartner(
          senderId: eventWithVersion.ownerId,
          senderName: eventWithVersion.ownerName,
          type: NotificationType.eventUpdated,
          title: notifTitle,
          body: notifBody,
          entityId: eventWithVersion.id,
        );
  }

  /// Delete an event and notify partner
  void deleteEvent(String id) {
    final event =
        state.firstWhere((e) => e.id == id, orElse: () => state.first);
    state = state.where((e) => e.id != id).toList();
    _saveToPrefs();

    _ref.read(notificationProvider.notifier).dispatchNotificationToPartner(
          senderId: event.ownerId,
          senderName: event.ownerName,
          type: NotificationType.eventDeleted,
          title: 'Event Removed',
          body: '${event.ownerName} removed an event from the calendar.',
          entityId: id,
        );
  }

  /// Duplicate an event
  void duplicateEvent(String id) {
    final original = state.firstWhere((e) => e.id == id);
    final auth = _ref.read(authProvider);
    final user = auth.currentUser;

    final duplicated = original.copyWith(
      id: const Uuid().v4(),
      ownerId: user.uid,
      ownerName: user.displayName,
      title: '${original.title} (Copy)',
      startTime: original.startTime.add(const Duration(days: 1)),
      endTime: original.endTime.add(const Duration(days: 1)),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      version: 1,
    );

    addEvent(duplicated);
  }

  /// Update event status (e.g. Mark completed, tentative, cancelled)
  void updateStatus(String id, EventStatus newStatus) {
    final event = state.firstWhere((e) => e.id == id);
    final updated = event.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );
    updateEvent(updated);
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }
}

final eventProvider =
    StateNotifierProvider<EventNotifier, List<CalendarEvent>>((ref) {
  return EventNotifier(ref);
});

/// Events filtered for a specific date
final eventsForDateProvider =
    Provider.family<List<CalendarEvent>, DateTime>((ref, date) {
  final allEvents = ref.watch(eventProvider);
  return allEvents.where((e) {
    return e.startTime.year == date.year &&
        e.startTime.month == date.month &&
        e.startTime.day == date.day;
  }).toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));
});
