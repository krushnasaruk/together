import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Represents an authenticated user in Together.
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? coupleId;
  final String? partnerId;
  final String? partnerName;
  final Color themeColor;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.coupleId,
    this.partnerId,
    this.partnerName,
    this.themeColor = AppColors.partnerSage,
  });

  bool get isPaired => coupleId != null && coupleId!.isNotEmpty;
  bool get isAuthenticated => uid.isNotEmpty;

  // Unauthenticated guest user
  static const UserModel initialGuest = UserModel(
    uid: '',
    email: '',
    displayName: 'You',
    coupleId: null,
    partnerId: null,
    partnerName: null,
    themeColor: AppColors.partnerSage,
  );

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? coupleId,
    String? partnerId,
    String? partnerName,
    Color? themeColor,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      coupleId: coupleId ?? this.coupleId,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      themeColor: themeColor ?? this.themeColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'coupleId': coupleId,
      'partnerId': partnerId,
      'partnerName': partnerName,
      'themeColor': themeColor.value,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      coupleId: json['coupleId'] as String?,
      partnerId: json['partnerId'] as String?,
      partnerName: json['partnerName'] as String?,
      themeColor: json['themeColor'] != null
          ? Color(json['themeColor'] as int)
          : AppColors.partnerSage,
    );
  }

  // Pre-configured demo users
  static const UserModel demoAlex = UserModel(
    uid: 'user_alex',
    email: 'alex@together.app',
    displayName: 'Alex Rivers',
    coupleId: 'couple_workspace_01',
    partnerId: 'user_taylor',
    partnerName: 'Taylor Brooks',
    themeColor: AppColors.partnerSage,
  );

  static const UserModel demoTaylor = UserModel(
    uid: 'user_taylor',
    email: 'taylor@together.app',
    displayName: 'Taylor Brooks',
    coupleId: 'couple_workspace_01',
    partnerId: 'user_alex',
    partnerName: 'Alex Rivers',
    themeColor: AppColors.partnerRose,
  );
}
