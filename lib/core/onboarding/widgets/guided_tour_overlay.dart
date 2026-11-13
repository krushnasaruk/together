import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../guided_tour_controller.dart';
import '../guided_tour_registry.dart';
import '../guided_tour_step.dart';
import 'comic_dialogue_bubble.dart';
import 'spotlight_target.dart';

/// Full-screen interactive overlay presenting Miso's Little Guide.
/// Computes dynamic spotlight cutouts and positions comic speech bubbles
/// relative to registered TourTarget widgets.
class GuidedTourOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const GuidedTourOverlay({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<GuidedTourOverlay> createState() => _GuidedTourOverlayState();
}

class _GuidedTourOverlayState extends ConsumerState<GuidedTourOverlay>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  void _syncPulseAnimation(bool isActive) {
    if (isActive) {
      if (_pulseController == null) {
        _pulseController = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1200),
        )..repeat(reverse: true);
      } else if (!_pulseController!.isAnimating) {
        _pulseController!.repeat(reverse: true);
      }
    } else {
      _pulseController?.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tourState = ref.watch(guidedTourControllerProvider);
    final tourNotifier = ref.read(guidedTourControllerProvider.notifier);

    _syncPulseAnimation(tourState.isActive);

    if (!tourState.isActive || tourState.currentStep == null) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        _buildActiveTour(context, tourState, tourNotifier),
      ],
    );
  }

  Widget _buildActiveTour(
    BuildContext context,
    GuidedTourState tourState,
    GuidedTourController tourNotifier,
  ) {
    final step = tourState.currentStep!;
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    // Retrieve live bounding box of registered target or compute safe tab target
    Rect? targetRect;
    if (step.targetId != null) {
      try {
        targetRect = GuidedTourRegistry.getTargetRect(step.targetId!);
      } catch (_) {
        targetRect = null;
      }

      // Robust fallback for navigation destinations
      if (targetRect == null) {
        int? tabIndex;
        if (step.targetId == 'tour_nav_today') tabIndex = 0;
        if (step.targetId == 'tour_nav_calendar') tabIndex = 1;
        if (step.targetId == 'tour_nav_together') tabIndex = 2;
        if (step.targetId == 'tour_nav_profile') tabIndex = 3;

        if (tabIndex != null) {
          final tabWidth = screenSize.width / 4;
          const navHeight = 72.0;
          targetRect = Rect.fromLTWH(
            tabIndex * tabWidth + 6,
            screenSize.height - navHeight - padding.bottom + 2,
            tabWidth - 12,
            navHeight - 4,
          );
        }
      }
    }

    // Determine bubble placement and pointer orientation
    final bool isModal = targetRect == null;
    SpeechPointerPosition pointerPos = step.pointerPosition;
    double pointerTargetX = 0.0;
    double? top;
    double? bottom;

    if (!isModal) {
      final targetCenter = targetRect.center;
      pointerTargetX =
          ((targetCenter.dx / screenSize.width) * 2 - 1).clamp(-0.75, 0.75);

      final isTargetInLowerHalf = targetCenter.dy > screenSize.height * 0.45;
      if (isTargetInLowerHalf) {
        // Place bubble above target
        bottom = (screenSize.height - targetRect.top) + 12.0;
        pointerPos = SpeechPointerPosition.bottom;
      } else {
        // Place bubble below target
        top = targetRect.bottom + 12.0;
        pointerPos = SpeechPointerPosition.top;
      }
    }

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Scrim and spotlight cutout painter
          if (_pulseController != null)
            AnimatedBuilder(
              animation: _pulseController!,
              builder: (context, _) {
                return CustomPaint(
                  size: screenSize,
                  painter: SpotlightPainter(
                    targetRect: targetRect,
                    pulseValue: _pulseController!.value,
                  ),
                );
              },
            )
          else
            CustomPaint(
              size: screenSize,
              painter: SpotlightPainter(
                targetRect: targetRect,
                pulseValue: 0.0,
              ),
            ),

          // 2. Gesture interceptor for scrim
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // Tap scrim advances to next step
              tourNotifier.nextStep();
            },
          ),

          // 3. Comic Dialogue Bubble
          if (isModal)
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  vertical: padding.top + 24,
                  horizontal: 8,
                ),
                child: ComicDialogueBubble(
                  key: ValueKey(step.id),
                  title: step.title,
                  message: step.message,
                  pose: step.pose,
                  stepIndex: tourState.currentIndex,
                  totalSteps: tourState.totalSteps,
                  pointerPosition: SpeechPointerPosition.none,
                  pointerTargetX: 0.0,
                  onNext: tourNotifier.nextStep,
                  onPrevious: tourNotifier.previousStep,
                  onClose: tourNotifier.skipTour,
                ),
              ),
            )
          else
            Positioned(
              left: 0,
              right: 0,
              top: top,
              bottom: bottom,
              child: SafeArea(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: screenSize.height * 0.65,
                  ),
                  child: SingleChildScrollView(
                    child: ComicDialogueBubble(
                      key: ValueKey(step.id),
                      title: step.title,
                      message: step.message,
                      pose: step.pose,
                      stepIndex: tourState.currentIndex,
                      totalSteps: tourState.totalSteps,
                      pointerPosition: pointerPos,
                      pointerTargetX: pointerTargetX,
                      onNext: tourNotifier.nextStep,
                      onPrevious: tourNotifier.previousStep,
                      onClose: tourNotifier.skipTour,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
