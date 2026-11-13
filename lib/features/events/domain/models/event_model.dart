import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum EventCategory {
  work('Work', Icons.work_outline_rounded, AppColors.categoryWork),
  college('College', Icons.school_outlined, AppColors.categoryCollege),
  study('Study', Icons.menu_book_outlined, AppColors.categoryStudy),
  personal(
      'Personal', Icons.person_outline_rounded, AppColors.categoryPersonal),
  family('Family', Icons.home_outlined, AppColors.categoryFamily),
  social('Social', Icons.people_outline_rounded, AppColors.categorySocial),
  travel('Travel', Icons.flight_takeoff_rounded, AppColors.categoryTravel),
  other('Other', Icons.category_outlined, AppColors.categoryOther);

  final String label;
  final IconData icon;
  final Color color;

  const EventCategory(this.label, this.icon, this.color);

  static EventCategory fromString(String? value) {
    return EventCategory.values.firstWhere(
      (c) => c.name.toLowerCase() == (value ?? '').toLowerCase(),
      orElse: () => EventCategory.other,
    );
  }
}

enum EventVisibility {
  shared('Shared with Partner', 'Partner can see title, time, and details'),
  private('Private (Busy)',
      'Partner only sees a busy time block; title and notes are hidden');

  final String label;
  final String description;

  const EventVisibility(this.label, this.description);

  static EventVisibility fromString(String? value) {
    return EventVisibility.values.firstWhere(
      (v) => v.name.toLowerCase() == (value ?? '').toLowerCase(),
      orElse: () => EventVisibility.shared,
    );
  }
}

enum EventStatus {
  confirmed('Confirmed', AppColors.statusConfirmed),
  tentative('Tentative', AppColors.statusTentative),
  completed('Completed', AppColors.statusCompleted),
  cancelled('Cancelled', AppColors.statusCancelled);

  final String label;
  final Color color;

  const EventStatus(this.label, this.color);

  static EventStatus fromString(String? value) {
    return EventStatus.values.firstWhere(
      (s) => s.name.toLowerCase() == (value ?? '').toLowerCase(),
      orElse: () => EventStatus.confirmed,
    );
  }
}

enum RecurrenceFrequency {
  none('Does not repeat'),
  daily('Repeats Daily'),
  weekly('Repeats Weekly'),
  monthly('Repeats Monthly');

  final String label;
  const RecurrenceFrequency(this.label);

  static RecurrenceFrequency fromString(String? value) {
    return RecurrenceFrequency.values.firstWhere(
      (r) => r.name.toLowerCase() == (value ?? '').toLowerCase(),
      orElse: () => RecurrenceFrequency.none,
    );
  }
}

/// Core domain calendar event entity for Together.
class CalendarEvent {
  final String id;
  final String coupleId;
  final String ownerId;
  final String ownerName;
  final String title;
  final String? description;
  final String? location;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAllDay;
  final EventCategory category;
  final EventVisibility visibility;
  final EventStatus status;
  final RecurrenceFrequency recurrence;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CalendarEvent({
    required this.id,
    required this.coupleId,
    required this.ownerId,
    required this.ownerName,
    required this.title,
    this.description,
    this.location,
    required this.startTime,
    required this.endTime,
    this.isAllDay = false,
    this.category = EventCategory.personal,
    this.visibility = EventVisibility.shared,
    this.status = EventStatus.confirmed,
    this.recurrence = RecurrenceFrequency.none,
    this.version = 1,
    required this.createdAt,
    required this.updatedAt,
  });

  bool isOwnedBy(String uid) => ownerId == uid;

  /// Crucial Privacy Rule:
  /// A private event never exposes its title, description or location to the partner.
  /// The partner may only see that the owner is busy during that time.
  bool isMaskedFor(String viewerId) =>
      visibility == EventVisibility.private && ownerId != viewerId;

  String displayTitleFor(String viewerId) {
    if (isMaskedFor(viewerId)) {
      return 'Busy (Private)';
    }
    return title;
  }

  String? displayDescriptionFor(String viewerId) {
    if (isMaskedFor(viewerId)) {
      return null;
    }
    return description;
  }

  String? displayLocationFor(String viewerId) {
    if (isMaskedFor(viewerId)) {
      return null;
    }
    return location;
  }

  CalendarEvent copyWith({
    String? id,
    String? coupleId,
    String? ownerId,
    String? ownerName,
    String? title,
    String? description,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
    EventCategory? category,
    EventVisibility? visibility,
    EventStatus? status,
    RecurrenceFrequency? recurrence,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      coupleId: coupleId ?? this.coupleId,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      category: category ?? this.category,
      visibility: visibility ?? this.visibility,
      status: status ?? this.status,
      recurrence: recurrence ?? this.recurrence,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coupleId': coupleId,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'title': title,
      'description': description,
      'location': location,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAllDay': isAllDay,
      'category': category.name,
      'visibility': visibility.name,
      'status': status.name,
      'recurrence': recurrence.name,
      'version': version,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] as String,
      coupleId: json['coupleId'] as String,
      ownerId: json['ownerId'] as String,
      ownerName: json['ownerName'] as String? ?? 'Partner',
      title: json['title'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      isAllDay: json['isAllDay'] as bool? ?? false,
      category: EventCategory.fromString(json['category'] as String?),
      visibility: EventVisibility.fromString(json['visibility'] as String?),
      status: EventStatus.fromString(json['status'] as String?),
      recurrence: RecurrenceFrequency.fromString(json['recurrence'] as String?),
      version: json['version'] as int? ?? 1,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
