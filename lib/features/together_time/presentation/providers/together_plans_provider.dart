import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/together_model.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

class TogetherPlansNotifier extends StateNotifier<List<TogetherPlan>> {
  static const String _prefKey = 'together_romantic_plans';
  final Ref _ref;

  TogetherPlansNotifier(this._ref) : super([]) {
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_prefKey);
      if (data != null) {
        final list = (jsonDecode(data) as List)
            .map((item) => TogetherPlan.fromJson(item as Map<String, dynamic>))
            .toList();
        state = list;
        return;
      }
    } catch (_) {}

    // Clean slate with no dummy items
    state = const [];
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(state.map((e) => e.toJson()).toList());
      await prefs.setString(_prefKey, raw);
    } catch (_) {}
  }

  void addPlan({
    required TogetherPlanType type,
    required String title,
    String? description,
    DateTime? targetDate,
  }) {
    final user = _ref.read(authProvider).currentUser;
    final plan = TogetherPlan(
      id: const Uuid().v4(),
      coupleId: user.coupleId ?? 'couple_workspace_01',
      type: type,
      title: title,
      description: description,
      targetDate: targetDate,
      isCompleted: false,
      createdById: user.uid,
      createdByName: user.displayName,
      createdAt: DateTime.now(),
    );

    state = [...state, plan];
    _saveToPrefs();
  }

  void toggleCompletion(String id) {
    state = state.map((p) {
      if (p.id == id) {
        return p.copyWith(isCompleted: !p.isCompleted);
      }
      return p;
    }).toList();
    _saveToPrefs();
  }

  void deletePlan(String id) {
    state = state.where((p) => p.id != id).toList();
    _saveToPrefs();
  }
}

final togetherPlansProvider =
    StateNotifierProvider<TogetherPlansNotifier, List<TogetherPlan>>((ref) {
  return TogetherPlansNotifier(ref);
});
