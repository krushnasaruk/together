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

/// Production-ready Registration Screen enabling individual profile creation with Google or Email.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).registerWithEmail(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (!mounted) return;
      setState(() => _isLoading = false);

      final user = ref.read(authProvider).currentUser;
      ref.read(guidedTourControllerProvider.notifier).startFirstRunTour();
      context.go('/today');
      TogetherToast.show(
        context,
        message: 'Account created! Welcome, ${user.displayName.split(' ').first}.',
        pose: MisoPose.happy,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      TogetherToast.show(
        context,
        message: 'Registration error: $e',
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
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
                          text: 'Create Your Account',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Join Together with your own individual profile and pair with your partner.',
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
              const SizedBox(height: AppTokens.space24),

              // Sign up with Google Button
              GoogleSignInButton(
                onPressed: _handleGoogleSignIn,
                isLoading: _isGoogleLoading,
                label: 'Sign up with Google',
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

              // Full Name Clay Input
              ClayInput(
                controller: _nameController,
                labelText: 'Your Name',
                hintText: 'e.g. Jordan Smith',
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTokens.space16),

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
                    return 'Please enter a password';
                  }
                  if (val.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTokens.space16),

              // Confirm Password Clay Input
              ClayInput(
                controller: _confirmPasswordController,
                labelText: 'Confirm Password',
                hintText: '••••••••',
                obscureText: _obscurePassword,
                prefixIcon: const Icon(Icons.lock_reset_rounded, size: 20),
                validator: (val) {
                  if (val != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTokens.space24),

              // Register Tactile Clay Button
              ClayButton(
                label: 'Create Account',
                onPressed: _handleRegister,
                isLoading: _isLoading,
                expanded: true,
                height: AppTokens.buttonHeightLg,
              ),
              const SizedBox(height: AppTokens.space16),

              // Sign in Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/login'),
                    child: Text(
                      'Sign in',
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
