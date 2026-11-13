import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/clay/clay_segmented_bar.dart';
import '../../../../shared/widgets/clay/together_surface.dart';
import '../../../../shared/widgets/components/section_header.dart';
import '../../../../shared/widgets/components/together_feedback.dart';
import '../../../../shared/widgets/mascot/mascot_states.dart';
import '../../../../shared/widgets/mascot/together_mascot.dart';
import '../../../../shared/widgets/motion/text_animations.dart';
import '../../../../shared/widgets/partner_switcher_badge.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../domain/models/together_model.dart';
import '../providers/together_plans_provider.dart';
import '../widgets/add_plan_sheet.dart';

/// Interactive Together space for shared date nights, bucket lists, and anniversaries.
/// Redesigned with Together's playful, expressive, warm hand-drawn Miso identity.
class TogetherScreen extends ConsumerStatefulWidget {
  const TogetherScreen({super.key});

  @override
  ConsumerState<TogetherScreen> createState() => _TogetherScreenState();
}

class _TogetherScreenState extends ConsumerState<TogetherScreen> {
  TogetherPlanType _selectedFilter = TogetherPlanType.dateNight;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space16,
          vertical: AppTokens.space12,
        ),
        children: [
          // Anniversary & Milestones Banner featuring Miso
          TogetherSurface(
            surfaceType: ClaySurfaceType.raised,
            accentColor: AppColors.partnerRose,
            padding: const EdgeInsets.all(AppTokens.space20),
            child: Row(
              children: [
                const TogetherMascot(
                  pose: MisoPose.message,
                  height: 64,
                  width: 64,
                  animateOnTap: true,
                ),
                const SizedBox(width: AppTokens.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AnimatedNumber(
                            value: daysTogether,
                            suffix: ' Days',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkSecondary
                                  : AppColors.partnerRoseDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'together',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Since ${DateFormat('MMMM d, yyyy').format(anniversary)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.space20),

          // Plan Type Category Tabs
          ClaySegmentedBar<TogetherPlanType>(
            values: TogetherPlanType.values,
            labels: TogetherPlanType.values.map((t) => t.label).toList(),
            selectedValue: _selectedFilter,
            onSelected: (type) => setState(() => _selectedFilter = type),
          ),
          const SizedBox(height: AppTokens.space16),

          // Section Header with Add Action
          SectionHeader(
            title: _selectedFilter.label,
            subtitle: 'Curated ideas and shared memories',
            padding: EdgeInsets.zero,
            trailing: TextButton.icon(
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Plan'),
              onPressed: () =>
                  AddPlanSheet.show(context, defaultType: _selectedFilter),
            ),
          ),
          const SizedBox(height: AppTokens.space8),

          // Plans List
          if (filteredPlans.isEmpty)
            MascotEmptyState(
              title: 'No ${_selectedFilter.label.toLowerCase()} yet',
              message:
                  'Start building special memories together. Tap below to create your first plan.',
              pose: MisoPose.curious,
              mascotHeight: 90,
              actionLabel: 'Add ${_selectedFilter.label}',
              onAction: () =>
                  AddPlanSheet.show(context, defaultType: _selectedFilter),
            )
          else
            ...filteredPlans.map((plan) {
              return TogetherSurface(
                surfaceType: ClaySurfaceType.raised,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space14,
                  vertical: AppTokens.space12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: plan.isCompleted,
                      activeColor: isDark
                          ? AppColors.darkSecondary
                          : AppColors.partnerRose,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (_) {
                        final willBeCompleted = !plan.isCompleted;
                        ref
                            .read(togetherPlansProvider.notifier)
                            .toggleCompletion(plan.id);

                        if (willBeCompleted) {
                          TogetherFeedback.showToast(
                            context,
                            message: 'Woohoo! Another memory made together! ✨',
                            pose: MisoPose.celebrating,
                          );
                        }
                      },
                    ),
                    const SizedBox(width: AppTokens.space8),
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
                                  : (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary),
                            ),
                          ),
                          if (plan.description != null &&
                              plan.description!.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              plan.description!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                          if (plan.targetDate != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.event_outlined,
                                  size: 13,
                                  color: isDark
                                      ? AppColors.darkSecondary
                                      : AppColors.partnerRose,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('MMM d, yyyy')
                                      .format(plan.targetDate!),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.darkSecondary
                                        : AppColors.partnerRose,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: AppColors.textTertiary,
                      ),
                      tooltip: 'Remove plan',
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
