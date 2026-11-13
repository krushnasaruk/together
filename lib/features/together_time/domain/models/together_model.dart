enum TogetherPlanType {
  dateNight('Date Night', 'Curated experiences and plans for two'),
  bucketList(
      'Bucket List', 'Shared goals, places to explore, and memories to make'),
  occasion(
      'Occasion / Anniversary', 'Special moments and relationship milestones');

  final String label;
  final String description;
  const TogetherPlanType(this.label, this.description);

  static TogetherPlanType fromString(String? val) {
    return TogetherPlanType.values.firstWhere(
      (t) => t.name == val,
      orElse: () => TogetherPlanType.dateNight,
    );
  }
}

/// Represents a shared romantic or lifestyle plan.
class TogetherPlan {
  final String id;
  final String coupleId;
  final TogetherPlanType type;
  final String title;
  final String? description;
  final DateTime? targetDate;
  final bool isCompleted;
  final String createdById;
  final String createdByName;
  final DateTime createdAt;

  const TogetherPlan({
    required this.id,
    required this.coupleId,
    required this.type,
    required this.title,
    this.description,
    this.targetDate,
    this.isCompleted = false,
    required this.createdById,
    required this.createdByName,
    required this.createdAt,
  });

  TogetherPlan copyWith({
    String? id,
    String? coupleId,
    TogetherPlanType? type,
    String? title,
    String? description,
    DateTime? targetDate,
    bool? isCompleted,
    String? createdById,
    String? createdByName,
    DateTime? createdAt,
  }) {
    return TogetherPlan(
      id: id ?? this.id,
      coupleId: coupleId ?? this.coupleId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdById: createdById ?? this.createdById,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coupleId': coupleId,
      'type': type.name,
      'title': title,
      'description': description,
      'targetDate': targetDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'createdById': createdById,
      'createdByName': createdByName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TogetherPlan.fromJson(Map<String, dynamic> json) {
    return TogetherPlan(
      id: json['id'] as String,
      coupleId: json['coupleId'] as String,
      type: TogetherPlanType.fromString(json['type'] as String?),
      title: json['title'] as String,
      description: json['description'] as String?,
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdById: json['createdById'] as String,
      createdByName: json['createdByName'] as String? ?? 'Partner',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
