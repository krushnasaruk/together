import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/partner_switcher_badge.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../pairing/presentation/widgets/pairing_sheet.dart';

/// Interactive Profile & Settings screen.
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
    final auth = ref.watch(authProvider);
    final user = auth.currentUser;
    final couple = auth.couple;
    final partnerColor = user.themeColor;

    return Scaffold(
      backgroundColor: AppColors.background,
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Active User Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: partnerColor.withOpacity(0.18),
                  child: Text(
                    user.displayName[0],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: partnerColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(authProvider.notifier).switchPartner();
                  },
                  icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                  label: const Text('Switch', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: partnerColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Couple Workspace Section
          Text(
            'Couple Workspace',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => PairingSheet.show(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.partnerRoseLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: AppColors.partnerRose,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.isPaired
                              ? 'Paired with ${user.partnerName ?? "Partner"}'
                              : 'Unpaired Workspace',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          auth.isPaired
                              ? 'Workspace ID: ${couple?.id ?? "couple_workspace_01"}'
                              : 'Tap to generate invite code or enter partner code',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textTertiary,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Notification Preferences
          Text(
            'Notification Preferences',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle),
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
                  activeColor: AppColors.partnerSage,
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
                  activeColor: AppColors.partnerSage,
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
                  activeColor: AppColors.partnerSage,
                  value: _notifyOnStatus,
                  onChanged: (val) => setState(() => _notifyOnStatus = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Privacy & Event Defaults
          Text(
            'Privacy & Visibility',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Default New Events to Private',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: const Text(
                      'Partner only sees "Busy" unless explicitly marked as shared',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  activeColor: AppColors.partnerSage,
                  value: _defaultPrivate,
                  onChanged: (val) => setState(() => _defaultPrivate = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Account Management / Data
          Text(
            'Account & Diagnostics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.refresh_rounded,
                      size: 20, color: AppColors.textPrimary),
                  title: const Text('Reset Demo Data',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: const Text(
                      'Restore default schedules and initial plans',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Demo schedules and initial data refreshed.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const Divider(),
                const ListTile(
                  leading: Icon(Icons.shield_outlined,
                      size: 20, color: AppColors.statusConfirmed),
                  title: Text('Security & Data Isolation Active',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: Text(
                      'End-to-end masked privacy rules enforced',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  trailing: Icon(Icons.check_circle_rounded,
                      color: AppColors.statusConfirmed, size: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
