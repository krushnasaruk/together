import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'together_mascot.dart';

/// Enhanced Miso presentation component with subtle breathing idle motion,
/// interactive tap bounce, and screen reader accessibility labels.
class MisoCharacter extends StatefulWidget {
  final MisoPose pose;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool animateIdle;

  const MisoCharacter({
    super.key,
    this.pose = MisoPose.defaultPose,
    this.width,
    this.height = 100,
    this.onTap,
    this.animateIdle = true,
  });

  @override
  State<MisoCharacter> createState() => _MisoCharacterState();
}

class _MisoCharacterState extends State<MisoCharacter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );

    if (widget.animateIdle) {
      _idleController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant MisoCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animateIdle != widget.animateIdle) {
      if (widget.animateIdle) {
        _idleController.repeat(reverse: true);
      } else {
        _idleController.stop();
      }
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Image.asset(
        widget.pose.assetPath,
        width: widget.width,
        height: widget.height,
        semanticLabel: widget.pose.semanticLabel,
        fit: BoxFit.contain,
      );
    }

    Widget content = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Image.asset(
        widget.pose.assetPath,
        width: widget.width,
        height: widget.height,
        semanticLabel: widget.pose.semanticLabel,
        fit: BoxFit.contain,
      ),
    );

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (widget.onTap != null) widget.onTap!();
      },
      child: content,
    );
  }
}

