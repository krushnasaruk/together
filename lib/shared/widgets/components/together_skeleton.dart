import 'package:flutter/material.dart';
import '../../../core/theme/app_tokens.dart';

/// Warm shimmering loading placeholder matching Together's layout.
class TogetherSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const TogetherSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  const TogetherSkeleton.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius =
            const BorderRadius.all(Radius.circular(AppTokens.radiusFull));

  @override
  State<TogetherSkeleton> createState() => _TogetherSkeletonState();
}

class _TogetherSkeletonState extends State<TogetherSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1400));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? const Color(0xFF2C322E) : const Color(0xFFEBE6DC);
    final highlightColor =
        isDark ? const Color(0xFF38403B) : const Color(0xFFF7F3EC);

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ??
                BorderRadius.circular(AppTokens.radiusMd),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.1, 0.5, 0.9],
              transform: _SlidingGradientTransform(
                slidePercent: _shimmerController.value,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}
