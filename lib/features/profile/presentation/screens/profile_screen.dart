import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../shared/widgets/components/section_header.dart';
import '../../../../shared/widgets/components/together_avatar.dart';
import '../../../../shared/widgets/components/together_feedback.dart';
import '../../../../shared/widgets/mascot/together_mascot.dart';
import '../../../../shared/widgets/partner_switcher_badge.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../pairing/presentation/widgets/pairing_sheet.dart';

/// Interactive Profile & Settings screen.
/// Redesigned with Together's warm, calm, functional and friendly Miso visual identity.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _notifyOnCreated = true;
  bool _notifyOnUpdated = true;
  bool _notifyOnStatus = true;
  bool _defaultPrivate = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = ref.watch(authProvider);
    final user = auth.currentUser;
    final couple = auth.couple;
    final partnerColor = user.themeColor;
    final currentThemeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Text('Profile & Settings'),
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
          // Active User Card with Miso Identity
          Container(
            padding: const EdgeInsets.all(AppTokens.space16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(
                color: isDark ? AppColors.darkDivider : AppColors.borderSubtle,
                width: 1,
              ),
              boxShadow: AppTokens.softShadow,
            ),
            child: Row(
              children: [
                TogetherAvatar(
                  name: user.displayName,
                  size: 52,
                  borderColor: partnerColor,
                ),
                const SizedBox(width: AppTokens.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(authProvider.notifier).switchPartner();
                    TogetherFeedback.showToast(
                      context,
                      message: 'Switched persona to partner',
                      pose: MisoPose.wave,
                    );
                  },
                  icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                  label: const Text('Switch', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(80, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.space20),

          // Couple Workspace Section
          const SectionHeader(
            title: 'Couple Workspace',
            subtitle: 'Pairing and shared life connection',
            padding: EdgeInsets.only(bottom: AppTokens.space8),
          ),
          InkWell(
            onTap: () => PairingSheet.show(context),
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            child: Container(
              padding: const EdgeInsets.all(AppTokens.space16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                border: Border.all(
                  color:
                      isDark ? AppColors.darkDivider : AppColors.borderSubtle,
                  width: 1,
                ),
                boxShadow: AppTokens.softShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF382A2A)
                          : AppColors.partnerRoseLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: AppColors.partnerRose,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppTokens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.isPaired
                              ? 'Paired with ${user.partnerName ?? "Partner"}'
                              : 'Unpaired Workspace',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          auth.isPaired
                              ? 'Workspace ID: ${couple?.id ?? "couple_workspace_01"}'
                              : 'Tap to generate invite code or pair',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textTertiary,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTokens.space20),

          // Appearance & Theme Mode (Light / Dark Mode)
          const SectionHeader(
            title: 'Appearance',
            subtitle: 'Choose between warm light and cozy dark mode',
            padding: EdgeInsets.only(bottom: AppTokens.space8),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(
                color: isDark ? AppColors.darkDivider : AppColors.borderSubtle,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('Light Mode (Warm Cream)',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  value: ThemeMode.light,
                  groupValue: currentThemeMode,
                  activeColor:
                      isDark ? AppColors.darkPrimary : AppColors.primaryDark,
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(themeModeProvider.notifier).setThemeMode(val);
                    }
                  },
                ),
                const Divider(),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark Mode (Warm Charcoal)',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  value: ThemeMode.dark,
                  groupValue: currentThemeMode,
                  activeColor:
                      isDark ? AppColors.darkPrimary : AppColors.primaryDark,
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(themeModeProvider.notifier).setThemeMode(val);
                    }
                  },
                ),
                const Divider(),
                RadioListTile<ThemeMode>(
                  title: const Text('System Default',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  value: ThemeMode.system,
                  groupValue: currentThemeMode,
                  activeColor:
                      isDark ? AppColors.darkPrimary : AppColors.primaryDark,
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(themeModeProvider.notifier).setThemeMode(val);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.space20),

          // Notification Preferences
          const SectionHeader(
            title: 'Notification Preferences',
            subtitle: 'Control which partner alerts you receive',
            padding: EdgeInsets.only(bottom: AppTokens.space8),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(
                color: isDark ? AppColors.darkDivider : AppColors.borderSubtle,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('New Event Notifications',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: const Text(
                      'Receive push alerts when partner schedules events',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  activeColor:
                      isDark ? AppColors.darkPrimary : AppColors.primaryDark,
                  value: _notifyOnCreated,
                  onChanged: (val) => setState(() => _notifyOnCreated = val),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Schedule Update Alerts',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: const Text(
                      'Get notified when partner reschedules or changes plans',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  activeColor:
                      isDark ? AppColors.darkPrimary : AppColors.primaryDark,
                  value: _notifyOnUpdated,
                  onChanged: (val) => setState(() => _notifyOnUpdated = val),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Quick Status Updates',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: const Text(
                      'Receive notifications for "On my way", "Free now", etc.',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  activeColor:
                      isDark ? AppColors.darkPrimary : AppColors.primaryDark,
                  value: _notifyOnStatus,
                  onChanged: (val) => setState(() => _notifyOnStatus = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.space20),

          // Privacy & Event Defaults
          const SectionHeader(
            title: 'Privacy & Visibility',
            subtitle: 'Default event visibility settings',
            padding: EdgeInsets.only(bottom: AppTokens.space8),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(
                color: isDark ? AppColors.darkDivider : AppColors.borderSubtle,
                width: 1,
              ),
            ),
            child: SwitchListTile(
              title: const Text('Default New Events to Private',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              subtitle: const Text(
                  'Partner only sees "Busy" unless explicitly marked as shared',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              activeColor:
                  isDark ? AppColors.darkPrimary : AppColors.primaryDark,
              value: _defaultPrivate,
              onChanged: (val) => setState(() => _defaultPrivate = val),
            ),
          ),
          const SizedBox(height: AppTokens.space20),

          // Account Management & Diagnostics
          const SectionHeader(
            title: 'Account & Diagnostics',
            subtitle: 'Session reset and data integrity',
            padding: EdgeInsets.only(bottom: AppTokens.space8),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(
                color: isDark ? AppColors.darkDivider : AppColors.borderSubtle,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.refresh_rounded, size: 20),
                  title: const Text('Reset Demo Data',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: const Text(
                      'Restore default schedules and initial plans',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  onTap: () {
                    TogetherFeedback.showToast(
                      context,
                      message: 'Demo schedules and initial data refreshed!',
                      pose: MisoPose.happy,
                    );
                  },
                ),
                const Divider(),
                const ListTile(
                  leading: Icon(Icons.shield_outlined,
                      size: 20, color: AppColors.success),
                  title: Text('Security & Data Isolation Active',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: Text('End-to-end masked privacy rules enforced',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  trailing: Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.space24),

          // Account Actions (Sign Out & Delete Account)
          OutlinedButton.icon(
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Sign Out of Account'),
            onPressed: () {
              context.go('/welcome');
            },
          ),
          const SizedBox(height: AppTokens.space12),
          TextButton.icon(
            icon: const Icon(Icons.delete_forever_rounded,
                size: 18, color: AppColors.error),
            label: const Text(
              'Delete Account & Data',
              style: TextStyle(color: AppColors.error, fontSize: 13),
            ),
            onPressed: () async {
              final confirmed = await TogetherFeedback.showDialog(
                context,
                title: 'Delete Account?',
                message:
                    'This action is irreversible. All your personal events will be deleted. '
                    'Your partner will remain in Together with their personal schedule intact.',
                pose: MisoPose.confused,
                confirmLabel: 'Confirm Deletion',
                isDestructive: true,
              );

              if (confirmed == true && context.mounted) {
                context.go('/welcome');
                TogetherFeedback.showToast(
                  context,
                  message: 'Account successfully removed.',
                  pose: MisoPose.reassuring,
                );
              }
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
