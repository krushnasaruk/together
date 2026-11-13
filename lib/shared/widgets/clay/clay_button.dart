import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/clay_tokens.dart';

enum ClayButtonVariant { primary, secondary, outline, ghost, danger }

/// Tactile clay pill button with physical press compression and dual-shadow depth.
class ClayButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final ClayButtonVariant variant;
  final Color? color;
  final bool isLoading;
  final double? width;
  final double height;
  final bool expanded;

  const ClayButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = ClayButtonVariant.primary,
    this.color,
    this.isLoading = false,
    this.width,
    this.height = AppTokens.buttonHeightMd,
    this.expanded = false,
  });

  @override
  State<ClayButton> createState() => _ClayButtonState();
}

class _ClayButtonState extends State<ClayButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _pressController.forward();
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = false);
      _pressController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = false);
      _pressController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    Border? border;

    switch (widget.variant) {
      case ClayButtonVariant.primary:
        bg = isDark ? AppColors.darkPrimary : AppColors.primaryDark;
        fg = isDark ? AppColors.darkBackground : AppColors.textInverse;
        break;
      case ClayButtonVariant.secondary:
        bg = isDark ? const Color(0xFF38433A) : const Color(0xFFE4EDE1);
        fg = isDark ? AppColors.darkTextPrimary : AppColors.primaryDark;
        break;
      case ClayButtonVariant.outline:
        bg = Colors.transparent;
        fg = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
        border = Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.borderMedium,
          width: 1.2,
        );
        break;
      case ClayButtonVariant.ghost:
        bg = Colors.transparent;
        fg = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
        break;
      case ClayButtonVariant.danger:
        bg = AppColors.error;
        fg = Colors.white;
        break;
    }

    if (widget.color != null) {
      bg = widget.color!;
    }

    final isFlat = widget.variant == ClayButtonVariant.outline ||
        widget.variant == ClayButtonVariant.ghost;

    final shadows = isFlat
        ? const <BoxShadow>[]
        : (isDark
            ? (_isPressed ? ClayTokens.darkPressed : ClayTokens.darkRaised)
            : (_isPressed ? ClayTokens.lightPressed : ClayTokens.lightRaised));

    final borderRadius = BorderRadius.circular(AppTokens.radiusXl);

    Widget content = Container(
      width: widget.expanded ? double.infinity : widget.width,
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.space20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: borderRadius,
        border: border ??
            Border.all(
              color: isDark ? const Color(0x33FFFFFF) : const Color(0x66FFFFFF),
              width: 1.0,
            ),
        boxShadow: shadows,
      ),
      child: Center(
        child: widget.isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    IconTheme(
                      data: IconThemeData(color: fg, size: 18),
                      child: widget.icon!,
                    ),
                    const SizedBox(width: AppTokens.space8),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
      ),
    );

    return GestureDetector(
      onTap: () {
        if (widget.onPressed != null && !widget.isLoading) {
          HapticFeedback.lightImpact();
          widget.onPressed!();
        }
      },
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: content,
      ),
    );
  }
}
