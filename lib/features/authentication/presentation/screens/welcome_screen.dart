import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/clay/clay_button.dart';
import '../../../../shared/widgets/clay/together_surface.dart';
import '../../../../shared/widgets/mascot/miso_character.dart';
import '../../../../shared/widgets/mascot/together_mascot.dart';
import '../../../../shared/widgets/motion/text_animations.dart';

/// Warm, tactile, playful welcome & onboarding screen featuring Miso.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.space24,
            vertical: AppTokens.space20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // Miso Waving Mascot Hero with breathing animation
              const MisoCharacter(
                pose: MisoPose.wave,
                height: 140,
                animateIdle: true,
              ),
              const SizedBox(height: AppTokens.space20),

              // Title with entrance animation & Tagline
              AnimatedHeading(
                text: AppConstants.appName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.0,
                    ),
              ),
              const SizedBox(height: AppTokens.space6),
              Text(
                AppConstants.appTagline,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTokens.space24),

              // Value Proposition Clay Surface
              TogetherSurface(
                surfaceType: ClaySurfaceType.raised,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space16,
                  vertical: AppTokens.space12,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 20,
                      color: isDark
                          ? AppColors.darkPrimary
                          : AppColors.primaryDark,
                    ),
                    const SizedBox(width: AppTokens.space12),
                    Expanded(
                      child: Text(
                        'Private by default. Shared understanding without surveillance.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Primary Actions with Tactile Clay Buttons
              ClayButton(
                label: 'Create Two-Person Space',
                variant: ClayButtonVariant.primary,
                expanded: true,
                height: AppTokens.buttonHeightLg,
                onPressed: () => context.push('/register'),
              ),
              const SizedBox(height: AppTokens.space12),
              ClayButton(
                label: 'Sign In to Account',
                variant: ClayButtonVariant.secondary,
                expanded: true,
                height: AppTokens.buttonHeightLg,
                onPressed: () => context.push('/login'),
              ),
              const SizedBox(height: AppTokens.space12),

              // Quick Demo Entry
              TextButton(
                onPressed: () => context.go('/today'),
                child: Text(
                  'Explore Demo Workspace with Miso',
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        isDark ? AppColors.darkPrimary : AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
