import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/clay/clay_button.dart';
import '../../../../shared/widgets/clay/clay_icon_button.dart';
import '../../../../shared/widgets/clay/clay_input.dart';
import '../../../../shared/widgets/clay/together_surface.dart';
import '../../../../shared/widgets/clay/together_toast.dart';
import '../../../../shared/widgets/mascot/together_mascot.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

/// Modal bottom sheet for couple invitation generation and pairing verification with tactile clay styling.
class PairingSheet extends ConsumerStatefulWidget {
  const PairingSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PairingSheet(),
    );
  }

  @override
  ConsumerState<PairingSheet> createState() => _PairingSheetState();
}

class _PairingSheetState extends ConsumerState<PairingSheet> {
  final _codeController = TextEditingController();
  final String _generatedCode = 'TOG-789';
  bool _isJoining = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleJoin() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isJoining = true);
    final success =
        await ref.read(authProvider.notifier).joinWithInviteCode(code);
    setState(() => _isJoining = false);

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
        TogetherToast.show(
          context,
          message: 'Successfully paired! Couple workspace is active.',
          pose: MisoPose.celebrating,
        );
      } else {
        TogetherToast.show(
          context,
          message: 'Invalid or expired invitation code. Try TOG-789.',
          pose: MisoPose.confused,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = ref.watch(authProvider);
    final user = auth.currentUser;
    final isPaired = auth.isPaired;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderMedium,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Couple Pairing',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(),
            Flexible(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  if (isPaired) ...[
                    // Paired Status Card
                    TogetherSurface(
                      surfaceType: ClaySurfaceType.raised,
                      accentColor: AppColors.partnerRose,
                      padding: const EdgeInsets.all(AppTokens.space16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: AppColors.partnerRoseLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.favorite_rounded,
                                color: AppColors.partnerRose, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Connected with ${user.partnerName ?? "Partner"}',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Shared workspace: ${auth.couple?.id ?? "couple_workspace_01"}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    ClayButton(
                      label: 'Leave Couple Workspace',
                      variant: ClayButtonVariant.danger,
                      expanded: true,
                      onPressed: () async {
                        await ref.read(authProvider.notifier).leaveCouple();
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          TogetherToast.show(
                            context,
                            message: 'Left couple workspace.',
                            pose: MisoPose.reassuring,
                          );
                        }
                      },
                    ),
                  ] else ...[
                    // Share Code Section
                    Text(
                      'Invite Your Partner',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Share this single-use code with your partner to securely join the same couple space.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 14),

                    TogetherSurface(
                      surfaceType: ClaySurfaceType.raised,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Your Invite Code (Expires in 48h)',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textTertiary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _generatedCode,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2,
                                    color: AppColors.partnerSage,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ClayIconButton(
                            icon: const Icon(Icons.copy_rounded, size: 20),
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: _generatedCode));
                              TogetherToast.show(
                                context,
                                message: 'Invite code copied to clipboard!',
                                pose: MisoPose.wave,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Join with Code Section
                    Text(
                      'Have a Code from Your Partner?',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    ClayInput(
                      controller: _codeController,
                      labelText: 'Enter Partner Code',
                      hintText: 'e.g. TOG-789',
                      prefixIcon: const Icon(Icons.vpn_key_outlined, size: 20),
                    ),
                    const SizedBox(height: 14),
                    ClayButton(
                      label: 'Accept & Join Workspace',
                      onPressed: _isJoining ? null : _handleJoin,
                      isLoading: _isJoining,
                      expanded: true,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
