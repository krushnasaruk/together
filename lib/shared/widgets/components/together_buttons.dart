import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_tokens.dart';

enum TogetherButtonVariant { primary, secondary, outline, ghost, danger }

/// A delightful, responsive button with subtle scale feedback on press.
class TogetherButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final TogetherButtonVariant variant;
  final bool isLoading;
  final double? width;
  final double height;
  final bool expanded;

  const TogetherButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = TogetherButtonVariant.primary,
    this.isLoading = false,
    this.width,
    this.height = AppTokens.buttonHeightMd,
    this.expanded = false,
  });

  @override
  State<TogetherButton> createState() => _TogetherButtonState();
}

class _TogetherButtonState extends State<TogetherButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
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
      _pressController.forward();
    }
  }

  void _onTapUp(TapUpDetails _) {
    _pressController.reverse();
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    Border? border;

    switch (widget.variant) {
      case TogetherButtonVariant.primary:
        bg = isDark ? AppColors.darkPrimary : AppColors.primaryDark;
        fg = isDark ? AppColors.darkBackground : AppColors.textInverse;
        break;
      case TogetherButtonVariant.secondary:
        bg = isDark ? const Color(0xFF3B443D) : const Color(0xFFE8EFE8);
        fg = isDark ? AppColors.darkTextPrimary : AppColors.primaryDark;
        break;
      case TogetherButtonVariant.outline:
        bg = Colors.transparent;
        fg = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
        border = Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.borderMedium,
          width: AppTokens.borderWidthThin,
        );
        break;
      case TogetherButtonVariant.ghost:
        bg = Colors.transparent;
        fg = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
        break;
      case TogetherButtonVariant.danger:
        bg = AppColors.error;
        fg = AppColors.textInverse;
        break;
    }

    final isEnabled = widget.onPressed != null && !widget.isLoading;
    if (!isEnabled) {
      bg = bg.withOpacity(0.5);
      fg = fg.withOpacity(0.6);
    }

    Widget content = Row(
      mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: fg,
            ),
          )
        else ...[
          if (widget.icon != null) ...[
            widget.icon!,
            const SizedBox(width: AppTokens.space8),
          ],
          Text(
            widget.label,
            style: TextStyle(
              color: fg,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ],
    );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.expanded ? double.infinity : widget.width,
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.space16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: border,
          ),
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );
  }
}

/// An icon button with press micro-feedback.
class TogetherIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final double size;

  const TogetherIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      ),
      child: IconButton(
        icon: icon,
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
      ),
    );

    return button;
  }
}
