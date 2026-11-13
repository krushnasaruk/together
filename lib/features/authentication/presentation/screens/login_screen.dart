import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/onboarding/guided_tour_controller.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/clay/clay_button.dart';
import '../../../../shared/widgets/clay/clay_input.dart';
import '../../../../shared/widgets/clay/google_sign_in_button.dart';
import '../../../../shared/widgets/clay/together_toast.dart';
import '../../../../shared/widgets/mascot/together_mascot.dart';
import '../../../../shared/widgets/motion/text_animations.dart';
import '../providers/auth_provider.dart';

/// Production-ready Login Screen with Google Sign-In and tactile claymorphic controls.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (!mounted) return;
      setState(() => _isLoading = false);

      final user = ref.read(authProvider).currentUser;
      // Launch Miso's Little Guide upon successful login
      ref.read(guidedTourControllerProvider.notifier).startFirstRunTour();
      context.go('/today');
      TogetherToast.show(
        context,
        message: 'Welcome back, ${user.displayName.split(' ').first}!',
        pose: MisoPose.happy,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      TogetherToast.show(
        context,
        message: 'Sign in error: $e',
        pose: MisoPose.confused,
      );
    }
  }

  void _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      final success =
          await ref.read(authProvider.notifier).signInWithGoogle();
      if (!mounted) return;
      setState(() => _isGoogleLoading = false);

      if (success) {
        final user = ref.read(authProvider).currentUser;
        ref.read(guidedTourControllerProvider.notifier).startFirstRunTour();
        context.go('/today');
        TogetherToast.show(
          context,
          message: 'Welcome to Together, ${user.displayName.split(' ').first}!',
          pose: MisoPose.happy,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGoogleLoading = false);
      TogetherToast.show(
        context,
        message: 'Google Sign-In: $e',
        pose: MisoPose.confused,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
              )
            : null,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.space24,
              vertical: AppTokens.space12,
            ),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedHeading(
                          text: 'Welcome Back',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sign in to coordinate your everyday lives together.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      'assets/logo/together_icon.png',
                      height: 64,
                      width: 64,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.space28),

              // Active Google Sign In Button
              GoogleSignInButton(
                onPressed: _handleGoogleSignIn,
                isLoading: _isGoogleLoading,
                label: 'Sign in with Google',
              ),
              const SizedBox(height: AppTokens.space20),

              // OR Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: isDark
                          ? AppColors.darkDivider
                          : AppColors.borderSubtle,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR WITH EMAIL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: isDark
                          ? AppColors.darkDivider
                          : AppColors.borderSubtle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.space20),

              // Email Clay Input
              ClayInput(
                controller: _emailController,
                labelText: 'Email Address',
                hintText: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!val.contains('@') || !val.contains('.')) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTokens.space16),

              // Password Clay Input
              ClayInput(
                controller: _passwordController,
                labelText: 'Password',
                hintText: '••••••••',
                obscureText: _obscurePassword,
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (val.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTokens.space8),

              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkPrimary
                          : AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTokens.space16),

              // Sign In Tactile Clay Button
              ClayButton(
                label: 'Sign In',
                onPressed: _handleLogin,
                isLoading: _isLoading,
                expanded: true,
                height: AppTokens.buttonHeightLg,
              ),
              const SizedBox(height: AppTokens.space20),

              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: Text(
                      'Create one',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
