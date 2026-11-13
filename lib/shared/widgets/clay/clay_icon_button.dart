import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_tokens.dart';

/// Tactile circular clay icon button with directional lighting and spring press physics.
class ClayIconButton extends StatefulWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final Color? iconColor;
  final String? tooltip;

  const ClayIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 42.0,
    this.color,
    this.iconColor,
    this.tooltip,
  });

  @override
  State<ClayIconButton> createState() => _ClayIconButtonState();
}

class _ClayIconButtonState extends State<ClayIconButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg =
        widget.color ?? (isDark ? AppColors.darkSurface : AppColors.surface);
    final shadows = isDark
        ? (_isPressed ? ClayTokens.darkPressed : ClayTokens.darkRaised)
        : (_isPressed ? ClayTokens.lightPressed : ClayTokens.lightRaised);

    Widget content = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: shadows,
        border: Border.all(
          color: isDark ? const Color(0x33FFFFFF) : const Color(0x66FFFFFF),
          width: 1.0,
        ),
      ),
      child: Center(
        child: IconTheme(
          data: IconThemeData(
            color: widget.iconColor ??
                (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
            size: widget.size * 0.48,
          ),
          child: widget.icon,
        ),
      ),
    );

    if (widget.tooltip != null) {
      content = Tooltip(message: widget.tooltip!, child: content);
    }

    return GestureDetector(
      onTap: () {
        if (widget.onPressed != null) {
          HapticFeedback.selectionClick();
          widget.onPressed!();
        }
      },
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _pressController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _pressController.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _pressController.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: content,
      ),
    );
  }
}
