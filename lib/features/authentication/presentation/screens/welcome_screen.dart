import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/mascot/together_mascot.dart';

/// Warm, playful, friendly welcome & onboarding screen featuring Miso.
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
              // Miso Waving Mascot Hero
              const TogetherMascot(
                pose: MisoPose.wave,
                height: 140,
                animateOnTap: true,
              ),
              const SizedBox(height: AppTokens.space20),

              // Title & Tagline
              Text(
                AppConstants.appName,
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

              // Value Proposition Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space16,
                  vertical: AppTokens.space12,
                ),
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

              // Primary Actions
              ElevatedButton(
                onPressed: () => context.push('/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? AppColors.darkPrimary : AppColors.primaryDark,
                  foregroundColor:
                      isDark ? AppColors.darkBackground : AppColors.textInverse,
                  minimumSize:
                      const Size(double.infinity, AppTokens.buttonHeightLg),
                ),
                child: const Text('Create Two-Person Space'),
              ),
              const SizedBox(height: AppTokens.space12),
              OutlinedButton(
                onPressed: () => context.push('/login'),
                style: OutlinedButton.styleFrom(
                  minimumSize:
                      const Size(double.infinity, AppTokens.buttonHeightLg),
                ),
                child: const Text('Sign In to Account'),
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
