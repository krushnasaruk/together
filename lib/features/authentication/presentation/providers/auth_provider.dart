import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/user_model.dart';
import '../../../pairing/domain/models/couple_model.dart';

/// State of the demo authentication and pairing session.
class AuthState {
  final UserModel currentUser;
  final CoupleModel? couple;
  final bool isLoading;

  const AuthState({
    required this.currentUser,
    this.couple,
    this.isLoading = false,
  });

  bool get isPaired => couple != null && currentUser.isPaired;

  AuthState copyWith({
    UserModel? currentUser,
    CoupleModel? couple,
    bool? isLoading,
  }) {
    return AuthState(
      currentUser: currentUser ?? this.currentUser,
      couple: couple ?? this.couple,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  static const String _prefUserKey = 'together_current_user';

  AuthNotifier()
      : super(
          AuthState(
            currentUser: UserModel.demoAlex,
            couple: CoupleModel.demoCouple,
          ),
        ) {
    _loadPersistedUser();
  }

  Future<void> _loadPersistedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_prefUserKey);
      if (userJson != null) {
        final map = jsonDecode(userJson) as Map<String, dynamic>;
        final user = UserModel.fromJson(map);
        state = state.copyWith(
          currentUser: user,
          couple: CoupleModel.demoCouple,
        );
      }
    } catch (_) {
      // Default to Alex
    }
  }

  /// Switch between Partner A (Alex) and Partner B (Taylor)
  Future<void> switchPartner() async {
    final nextUser = state.currentUser.uid == UserModel.demoAlex.uid
        ? UserModel.demoTaylor
        : UserModel.demoAlex;

    state = state.copyWith(currentUser: nextUser);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefUserKey, jsonEncode(nextUser.toJson()));
  }

  /// Set specific active user
  Future<void> setUser(UserModel user) async {
    state = state.copyWith(currentUser: user);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefUserKey, jsonEncode(user.toJson()));
  }

  /// Join a couple workspace with an invitation code
  Future<bool> joinWithInviteCode(String code) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 600));

    // Valid demo invitation codes
    if (code.trim().toUpperCase() == 'TOG-789' || code.trim().length >= 4) {
      final updatedCouple = CoupleModel(
        id: 'couple_workspace_${code.trim().toUpperCase()}',
        members: [state.currentUser.uid, 'partner_connected'],
        memberNames: {
          state.currentUser.uid: state.currentUser.displayName,
          'partner_connected': state.currentUser.partnerName ?? 'Partner',
        },
        anniversaryDate: DateTime.now().subtract(const Duration(days: 365)),
        status: 'active',
        createdAt: DateTime.now(),
      );

      final updatedUser = state.currentUser.copyWith(
        coupleId: updatedCouple.id,
      );

      state = state.copyWith(
        currentUser: updatedUser,
        couple: updatedCouple,
        isLoading: false,
      );
      await setUser(updatedUser);
      return true;
    }

    state = state.copyWith(isLoading: false);
    return false;
  }

  /// Leave couple workspace
  Future<void> leaveCouple() async {
    final uncoupledUser = UserModel(
      uid: state.currentUser.uid,
      email: state.currentUser.email,
      displayName: state.currentUser.displayName,
      coupleId: null,
      partnerId: null,
      partnerName: null,
      themeColor: state.currentUser.themeColor,
    );

    state = state.copyWith(
      currentUser: uncoupledUser,
      couple: null,
    );
    await setUser(uncoupledUser);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
