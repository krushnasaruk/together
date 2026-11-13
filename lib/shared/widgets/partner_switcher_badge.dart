import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../../features/pairing/presentation/widgets/pairing_sheet.dart';
import 'components/together_feedback.dart';
import 'mascot/together_mascot.dart';

/// Discreet pill in the header showing active user identity and couple status.
class PartnerSwitcherBadge extends ConsumerWidget {
  const PartnerSwitcherBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.currentUser;
    final partnerColor = user.themeColor;
    final isPaired = auth.isPaired;

    return InkWell(
      onTap: () {
        if (!isPaired) {
          PairingSheet.show(context);
        } else {
          ref.read(authProvider.notifier).switchPartner();
          final switchedTo = ref.read(authProvider).currentUser.displayName;
          TogetherFeedback.showToast(
            context,
            message: 'Viewing as $switchedTo',
            pose: MisoPose.wave,
            duration: const Duration(seconds: 1),
          );
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: partnerColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: partnerColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: isPaired ? partnerColor : AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isPaired
                  ? (user.displayName.isNotEmpty
                      ? user.displayName.split(' ').first
                      : 'You')
                  : 'Link Partner +',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: partnerColor,
              ),
            ),
            if (isPaired) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.swap_horiz_rounded,
                size: 14,
                color: partnerColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
