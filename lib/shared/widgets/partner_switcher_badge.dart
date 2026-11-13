import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';

/// Discreet badge allowing quick switching between Partner A and Partner B in demo mode.
class PartnerSwitcherBadge extends ConsumerWidget {
  const PartnerSwitcherBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.currentUser;
    final partnerColor = user.themeColor;

    return InkWell(
      onTap: () {
        ref.read(authProvider.notifier).switchPartner();
        final switchedTo =
            user.uid == 'user_alex' ? 'Taylor Brooks' : 'Alex Rivers';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched view to $switchedTo'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                color: partnerColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              user.displayName.split(' ').first,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: partnerColor,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.swap_horiz_rounded,
              size: 14,
              color: partnerColor,
            ),
          ],
        ),
      ),
    );
  }
}
