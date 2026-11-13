import 'package:flutter/material.dart';

enum NotificationType {
  eventCreated('New Event Added', Icons.event_available_rounded),
  eventUpdated('Event Rescheduled / Updated', Icons.update_rounded),
  eventCancelled('Event Cancelled', Icons.event_busy_rounded),
  eventDeleted('Event Removed', Icons.delete_outline_rounded),
  statusUpdate('Partner Status Update', Icons.bolt_rounded);

  final String label;
  final IconData icon;

  const NotificationType(this.label, this.icon);
}

enum QuickStatusPreset {
  onMyWay('On my way', '🏃', 'Headed towards you / home'),
  runningLate('Running late', '⏳', 'Delayed slightly, will be there soon'),
  meetingExtended('Meeting extended', '💼',
      'Current discussion running longer than planned'),
  freeNow('Free now', '🌿', 'Available to chat, call or hang out'),
  takingBreak('Taking a break', '☕', 'Stepping away to recharge'),
  needFocus('Need focus time', '🎧', 'In deep work or study session');

  final String title;
  final String emoji;
  final String subtitle;

  const QuickStatusPreset(this.title, this.emoji, this.subtitle);

  static QuickStatusPreset fromString(String? val) {
    return QuickStatusPreset.values.firstWhere(
      (p) => p.name == val,
      orElse: () => QuickStatusPreset.freeNow,
    );
  }
}

/// Represents an in-app notification item for partner life updates.
class NotificationItem {
  final String id;
  final String recipientId;
  final String senderId;
  final String senderName;
  final NotificationType type;
  final String title;
  final String body;
  final String? entityId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.recipientId,
    required this.senderId,
    required this.senderName,
    required this.type,
    required this.title,
    required this.body,
    this.entityId,
    this.isRead = false,
    required this.createdAt,
  });

  NotificationItem copyWith({
    String? id,
    String? recipientId,
    String? senderId,
    String? senderName,
    NotificationType? type,
    String? title,
    String? body,
    String? entityId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      entityId: entityId ?? this.entityId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipientId': recipientId,
      'senderId': senderId,
      'senderName': senderName,
      'type': type.name,
      'title': title,
      'body': body,
      'entityId': entityId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      recipientId: json['recipientId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String? ?? 'Partner',
      type: NotificationType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => NotificationType.eventCreated,
      ),
      title: json['title'] as String,
      body: json['body'] as String,
      entityId: json['entityId'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Represents a voluntary quick status broadcast.
class StatusUpdate {
  final String id;
  final String userId;
  final String userName;
  final String coupleId;
  final QuickStatusPreset preset;
  final String? customNote;
  final DateTime createdAt;
  final DateTime expiresAt;

  const StatusUpdate({
    required this.id,
    required this.userId,
    required this.userName,
    required this.coupleId,
    required this.preset,
    this.customNote,
    required this.createdAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'coupleId': coupleId,
      'preset': preset.name,
      'customNote': customNote,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  factory StatusUpdate.fromJson(Map<String, dynamic> json) {
    return StatusUpdate(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      coupleId: json['coupleId'] as String,
      preset: QuickStatusPreset.fromString(json['preset'] as String?),
      customNote: json['customNote'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}
