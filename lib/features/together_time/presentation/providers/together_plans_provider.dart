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

    final now = DateTime.now();
    state = [
      TogetherPlan(
        id: 'plan_01',
        coupleId: 'couple_workspace_01',
        type: TogetherPlanType.dateNight,
        title: 'Sunset Picnic at the Skyline Vista',
        description: 'Pack strawberries, sparkling cider, and warm blankets.',
        targetDate: now.add(const Duration(days: 4)),
        isCompleted: false,
        createdById: 'user_alex',
        createdByName: 'Alex',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      TogetherPlan(
        id: 'plan_02',
        coupleId: 'couple_workspace_01',
        type: TogetherPlanType.dateNight,
        title: 'Cook Homemade Ravioli from Scratch',
        description: 'Try the ricotta & spinach recipe from nonna.',
        targetDate: now.add(const Duration(days: 9)),
        isCompleted: true,
        createdById: 'user_taylor',
        createdByName: 'Taylor',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      TogetherPlan(
        id: 'plan_03',
        coupleId: 'couple_workspace_01',
        type: TogetherPlanType.bucketList,
        title: 'See the Northern Lights in Tromsø',
        description: 'Rent a glass igloo and watch aurora borealis together.',
        targetDate: null,
        isCompleted: false,
        createdById: 'user_taylor',
        createdByName: 'Taylor',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      TogetherPlan(
        id: 'plan_04',
        coupleId: 'couple_workspace_01',
        type: TogetherPlanType.bucketList,
        title: 'Weekend Ceramic Pottery Workshop',
        description: 'Make a pair of matching breakfast mugs.',
        targetDate: now.add(const Duration(days: 14)),
        isCompleted: false,
        createdById: 'user_alex',
        createdByName: 'Alex',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      TogetherPlan(
        id: 'plan_05',
        coupleId: 'couple_workspace_01',
        type: TogetherPlanType.occasion,
        title: 'First Date Anniversary',
        description:
            'Celebrate where it all began at the indie bookstore cafe.',
        targetDate: now.add(const Duration(days: 28)),
        isCompleted: false,
        createdById: 'user_alex',
        createdByName: 'Alex',
        createdAt: now.subtract(const Duration(days: 60)),
      ),
    ];
    _saveToPrefs();
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
