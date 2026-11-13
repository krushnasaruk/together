import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/partner_switcher_badge.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../domain/models/together_model.dart';
import '../providers/together_plans_provider.dart';
import '../widgets/add_plan_sheet.dart';

/// Interactive Together space for shared date nights, bucket lists, and anniversaries.
class TogetherScreen extends ConsumerStatefulWidget {
  const TogetherScreen({super.key});

  @override
  ConsumerState<TogetherScreen> createState() => _TogetherScreenState();
}

class _TogetherScreenState extends ConsumerState<TogetherScreen> {
  TogetherPlanType _selectedFilter = TogetherPlanType.dateNight;

  @override
  Widget build(BuildContext context) {
    final allPlans = ref.watch(togetherPlansProvider);
    final auth = ref.watch(authProvider);
    final couple = auth.couple;

    // Filter plans by current selection
    final filteredPlans =
        allPlans.where((p) => p.type == _selectedFilter).toList();

    // Calculate anniversary days
    final now = DateTime.now();
    final anniversary =
        couple?.anniversaryDate ?? now.subtract(const Duration(days: 428));
    final daysTogether = now.difference(anniversary).inDays;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Text('Together Space'),
            SizedBox(width: 8),
            PartnerSwitcherBadge(),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Anniversary & Milestones Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.partnerRoseLight.withOpacity(0.9),
                  AppColors.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.partnerRose,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '$daysTogether Days',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.partnerRoseDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'together',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Since ${DateFormat('MMMM d, yyyy').format(anniversary)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Plan Type Category Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: TogetherPlanType.values.map((type) {
                final isSelected = _selectedFilter == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(type.label),
                    selected: isSelected,
                    selectedColor: AppColors.partnerRose,
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.textInverse
                          : AppColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 13,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : AppColors.borderSubtle,
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedFilter = type);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Section Header with Add Action
          Row(
            children: [
              Text(
                _selectedFilter.label,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Plan'),
                onPressed: () =>
                    AddPlanSheet.show(context, defaultType: _selectedFilter),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Plans List
          if (filteredPlans.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  const Icon(Icons.wb_twilight_rounded,
                      size: 32, color: AppColors.textTertiary),
                  const SizedBox(height: 10),
                  Text(
                    'No ${_selectedFilter.label.toLowerCase()} added yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap "Add Plan" to start curating memories together.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            )
          else
            ...filteredPlans.map((plan) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: plan.isCompleted,
                      activeColor: AppColors.partnerRose,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (_) {
                        ref
                            .read(togetherPlansProvider.notifier)
                            .toggleCompletion(plan.id);
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              decoration: plan.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: plan.isCompleted
                                  ? AppColors.textTertiary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          if (plan.description != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              plan.description!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                          if (plan.targetDate != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.event_outlined,
                                    size: 13, color: AppColors.partnerRose),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('MMM d, yyyy')
                                      .format(plan.targetDate!),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.partnerRose,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          size: 18, color: AppColors.textTertiary),
                      onPressed: () {
                        ref
                            .read(togetherPlansProvider.notifier)
                            .deletePlan(plan.id);
                      },
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
