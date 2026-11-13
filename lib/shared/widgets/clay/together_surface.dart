import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/clay_tokens.dart';

export '../../../core/theme/clay_tokens.dart';

/// Fundamental tactile surface component embodying Together's refined claymorphic visual language.
/// Supports raised, inset, flat, and floating dock treatments with natural press physics.
class TogetherSurface extends StatefulWidget {
  final Widget child;
  final ClaySurfaceType surfaceType;
  final Color? color;
  final Color? accentColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final bool animatePress;
  final double? width;
  final double? height;

  const TogetherSurface({
    super.key,
    required this.child,
    this.surfaceType = ClaySurfaceType.raised,
    this.color,
    this.accentColor,
    this.borderColor,
    this.borderRadius,
    this.padding = const EdgeInsets.all(AppTokens.space16),
    this.margin,
    this.onTap,
    this.animatePress = true,
    this.width,
    this.height,
  });

  @override
  State<TogetherSurface> createState() => _TogetherSurfaceState();
}

class _TogetherSurfaceState extends State<TogetherSurface>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap != null && widget.animatePress) {
      setState(() => _isPressed = true);
      _pressController.forward();
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onTap != null && widget.animatePress) {
      setState(() => _isPressed = false);
      _pressController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null && widget.animatePress) {
      setState(() => _isPressed = false);
      _pressController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = widget.borderRadius ?? BorderRadius.circular(AppTokens.radiusMd);

    List<BoxShadow> shadows;
    Gradient? gradient;
    Color surfaceBase =
        widget.color ?? (isDark ? AppColors.darkSurface : AppColors.surface);

    if (widget.accentColor != null) {
      surfaceBase = Color.lerp(
        surfaceBase,
        widget.accentColor,
        isDark ? 0.15 : 0.08,
      )!;
    }

    switch (widget.surfaceType) {
      case ClaySurfaceType.raised:
        shadows = isDark
            ? (_isPressed ? ClayTokens.darkPressed : ClayTokens.darkRaised)
            : (_isPressed ? ClayTokens.lightPressed : ClayTokens.lightRaised);
        gradient = isDark
            ? ClayTokens.darkRaisedGradient(tintColor: surfaceBase)
            : ClayTokens.lightRaisedGradient(tintColor: surfaceBase);
        break;

      case ClaySurfaceType.dock:
        shadows = isDark ? ClayTokens.darkFloating : ClayTokens.lightFloating;
        gradient = isDark
            ? ClayTokens.darkRaisedGradient(tintColor: surfaceBase)
            : ClayTokens.lightRaisedGradient(tintColor: surfaceBase);
        break;

      case ClaySurfaceType.inset:
        shadows = isDark ? ClayTokens.darkInset : ClayTokens.lightInset;
        surfaceBase =
            isDark ? const Color(0xFF181B19) : const Color(0xFFF1EBE0);
        gradient = null;
        break;

      case ClaySurfaceType.flat:
        shadows = const [];
        gradient = null;
        break;
    }

    Widget content = Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: surfaceBase,
        gradient: gradient,
        borderRadius: r,
        boxShadow: shadows,
        border: Border.all(
          color: widget.borderColor ??
              (isDark ? const Color(0x2E4A564D) : const Color(0x38FFFFFF)),
          width: 1.0,
        ),
      ),
      child: widget.child,
    );

    if (widget.onTap != null) {
      content = GestureDetector(
        onTap: widget.onTap,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    if (widget.animatePress && widget.onTap != null) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: content,
      );
    }

    return content;
  }
}
