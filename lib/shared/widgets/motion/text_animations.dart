import 'package:flutter/material.dart';
import '../../../core/motion/motion_tokens.dart';

/// Animated heading component that gently slides up and fades in on entrance.
class AnimatedHeading extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final Duration delay;

  const AnimatedHeading({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
    this.delay = Duration.zero,
  });

  @override
  State<AnimatedHeading> createState() => _AnimatedHeadingState();
}

class _AnimatedHeadingState extends State<AnimatedHeading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: TogetherMotion.normal,
    );

    final curve = CurvedAnimation(
      parent: _controller,
      curve: TogetherMotion.smoothOut,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curve);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(curve);

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Text(
        widget.text,
        style: widget.style,
        textAlign: widget.textAlign,
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Text(
          widget.text,
          style: widget.style,
          textAlign: widget.textAlign,
        ),
      ),
    );
  }
}

/// Animated numeric ticker that rolls smoothly from 0 to [value].
class AnimatedNumber extends StatefulWidget {
  final int value;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final Duration duration;

  const AnimatedNumber({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = TogetherMotion.counter,
  });

  @override
  State<AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<AnimatedNumber>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _lastValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.value.toDouble(),
    ).animate(
      CurvedAnimation(parent: _controller, curve: TogetherMotion.smoothOut),
    );
    _lastValue = widget.value;
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: _lastValue.toDouble(),
        end: widget.value.toDouble(),
      ).animate(
        CurvedAnimation(parent: _controller, curve: TogetherMotion.smoothOut),
      );
      _lastValue = widget.value;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Text(
        '${widget.prefix}${widget.value}${widget.suffix}',
        style: widget.style,
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentVal = _animation.value.round();
        return Text(
          '${widget.prefix}$currentVal${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}

/// Smooth cross-fade transition when partner status or message text changes.
class AnimatedStatusText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const AnimatedStatusText({
    super.key,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: TogetherMotion.fast,
      switchInCurve: TogetherMotion.smoothOut,
      switchOutCurve: TogetherMotion.smoothOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.2),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        text,
        key: ValueKey<String>(text),
        style: style,
      ),
    );
  }
}

/// Staggered container that smoothly animates children sequentially into view.
class StaggeredContent extends StatefulWidget {
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final Duration staggerInterval;

  const StaggeredContent({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.staggerInterval = TogetherMotion.staggerItem,
  });

  @override
  State<StaggeredContent> createState() => _StaggeredContentState();
}

class _StaggeredContentState extends State<StaggeredContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final totalDuration = TogetherMotion.normal +
        (widget.staggerInterval * widget.children.length);
    _controller = AnimationController(
      vsync: this,
      duration: totalDuration,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Column(
        crossAxisAlignment: widget.crossAxisAlignment,
        children: widget.children,
      );
    }

    final totalCount = widget.children.length;
    final totalDurationMs = _controller.duration!.inMilliseconds;

    return Column(
      crossAxisAlignment: widget.crossAxisAlignment,
      children: List.generate(totalCount, (index) {
        final startMs = index * widget.staggerInterval.inMilliseconds;
        final endMs = startMs + TogetherMotion.normal.inMilliseconds;

        final startFraction = (startMs / totalDurationMs).clamp(0.0, 1.0);
        final endFraction = (endMs / totalDurationMs).clamp(0.0, 1.0);

        final animation = CurvedAnimation(
          parent: _controller,
          curve: Interval(startFraction, endFraction,
              curve: TogetherMotion.smoothOut),
        );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.08),
              end: Offset.zero,
            ).animate(animation),
            child: widget.children[index],
          ),
        );
      }),
    );
  }
}
