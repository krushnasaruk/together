import 'package:flutter/material.dart';
import '../../../core/theme/app_tokens.dart';

/// Enum representing the official expression/pose catalog for Miso the cat.
enum MisoPose {
  defaultPose('assets/mascot/miso_default.png', 'Miso sitting contentedly'),
  happy('assets/mascot/miso_happy.png', 'Miso cheering happily'),
  wave('assets/mascot/miso_wave.png', 'Miso waving a warm hello'),
  curious('assets/mascot/miso_curious.png', 'Miso curiously tilting head'),
  message('assets/mascot/miso_message.png', 'Miso delivering a love letter'),
  sleeping('assets/mascot/miso_sleeping.png', 'Miso peacefully sleeping'),
  celebrating('assets/mascot/miso_celebrating.png',
      'Miso celebrating with paws raised'),
  confused('assets/mascot/miso_confused.png', 'Miso wondering what happened'),
  reassuring(
      'assets/mascot/miso_reassuring.png', 'Miso offering reassuring presence'),
  relaxed('assets/mascot/miso_relaxed.png', 'Miso resting with a little heart'),
  avatar('assets/mascot/miso_avatar.png', 'Miso avatar icon'),
  monochrome('assets/mascot/miso_monochrome.png', 'Miso silhouette back view');

  final String assetPath;
  final String semanticLabel;

  const MisoPose(this.assetPath, this.semanticLabel);
}

/// The brand companion widget: Miso the cat.
/// Supports multiple sizes, gentle interactive micro-bounce on tap,
/// and screen reader accessibility labels.
class TogetherMascot extends StatefulWidget {
  final MisoPose pose;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool animateOnTap;

  const TogetherMascot({
    super.key,
    this.pose = MisoPose.defaultPose,
    this.width,
    this.height = 100,
    this.onTap,
    this.animateOnTap = true,
  });

  @override
  State<TogetherMascot> createState() => _TogetherMascotState();
}

class _TogetherMascotState extends State<TogetherMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: AppMotion.bounce),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.animateOnTap) {
      _controller.forward().then((_) => _controller.reverse());
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset(
      widget.pose.assetPath,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.contain,
      semanticLabel: widget.pose.semanticLabel,
      errorBuilder: (context, error, stackTrace) {
        // Safe graceful placeholder if image fails to load
        return Container(
          width: widget.width ?? widget.height,
          height: widget.height,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EFE8),
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
          alignment: Alignment.center,
          child: const Text('🐱', style: TextStyle(fontSize: 28)),
        );
      },
    );

    if (widget.onTap != null || widget.animateOnTap) {
      image = GestureDetector(
        onTap: _handleTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: image,
        ),
      );
    }

    return Semantics(
      label: widget.pose.semanticLabel,
      image: true,
      child: image,
    );
  }
}
