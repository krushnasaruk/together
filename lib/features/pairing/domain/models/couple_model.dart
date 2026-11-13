/// Represents a shared private couple workspace.
class CoupleModel {
  final String id;
  final List<String> members;
  final Map<String, String> memberNames;
  final DateTime? anniversaryDate;
  final String status;
  final DateTime createdAt;

  const CoupleModel({
    required this.id,
    required this.members,
    required this.memberNames,
    this.anniversaryDate,
    this.status = 'active',
    required this.createdAt,
  });

  bool get isFull => members.length >= 2;

  String? getPartnerName(String currentUserId) {
    for (final entry in memberNames.entries) {
      if (entry.key != currentUserId) {
        return entry.value;
      }
    }
    return null;
  }

  String? getPartnerId(String currentUserId) {
    for (final uid in members) {
      if (uid != currentUserId) {
        return uid;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'members': members,
      'memberNames': memberNames,
      'anniversaryDate': anniversaryDate?.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CoupleModel.fromJson(Map<String, dynamic> json) {
    return CoupleModel(
      id: json['id'] as String,
      members: List<String>.from(json['members'] as List),
      memberNames: Map<String, String>.from(json['memberNames'] as Map),
      anniversaryDate: json['anniversaryDate'] != null
          ? DateTime.parse(json['anniversaryDate'] as String)
          : null,
      status: json['status'] as String? ?? 'active',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Pre-configured demo couple
  static final CoupleModel demoCouple = CoupleModel(
    id: 'couple_workspace_01',
    members: const ['user_alex', 'user_taylor'],
    memberNames: const {
      'user_alex': 'Alex Rivers',
      'user_taylor': 'Taylor Brooks',
    },
    anniversaryDate: DateTime.now().subtract(const Duration(days: 428)),
    status: 'active',
    createdAt: DateTime.now().subtract(const Duration(days: 428)),
  );
}
