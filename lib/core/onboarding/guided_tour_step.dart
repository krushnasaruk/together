import '../../shared/widgets/mascot/together_mascot.dart';

enum SpeechPointerPosition { top, bottom, none }

/// Model representing a single step in Miso's Little Guide.
class GuidedTourStep {
  final String id;
  final String title;
  final String message;
  final MisoPose pose;
  final String? targetId;
  final SpeechPointerPosition pointerPosition;

  const GuidedTourStep({
    required this.id,
    required this.title,
    required this.message,
    this.pose = MisoPose.wave,
    this.targetId,
    this.pointerPosition = SpeechPointerPosition.bottom,
  });
}

/// Catalog of pre-configured tour sequences for Together.
class TourSequence {
  TourSequence._();

  static const String firstRunTourId = 'first_run_tour';

  static final List<GuidedTourStep> firstRunSteps = [
    const GuidedTourStep(
      id: 'step_welcome',
      title: 'Hey there! 🐱',
      message:
          'I\'m Miso! Welcome to Together. Let me give you a quick little tour of your private shared space.',
      pose: MisoPose.wave,
      targetId: null, // Centered modal
      pointerPosition: SpeechPointerPosition.none,
    ),
    const GuidedTourStep(
      id: 'step_today',
      title: 'Today: Your Daily Anchor',
      message:
          'Here is your shared daily view. You can see your partner\'s schedule, upcoming activities, and shared free windows.',
      pose: MisoPose.curious,
      targetId: 'tour_nav_today',
      pointerPosition: SpeechPointerPosition.bottom,
    ),
    const GuidedTourStep(
      id: 'step_calendar',
      title: 'Shared Calendar',
      message:
          'Need the bigger picture? Explore months, inspect week schedules, and detect overlapping commitments with ease.',
      pose: MisoPose.relaxed,
      targetId: 'tour_nav_calendar',
      pointerPosition: SpeechPointerPosition.bottom,
    ),
    const GuidedTourStep(
      id: 'step_together',
      title: 'Together Space',
      message:
          'Your relationship sanctuary! Track anniversaries, curate romantic date nights, and check off shared bucket lists.',
      pose: MisoPose.message,
      targetId: 'tour_nav_together',
      pointerPosition: SpeechPointerPosition.bottom,
    ),
    const GuidedTourStep(
      id: 'step_profile',
      title: 'Profile & Privacy',
      message:
          'Manage your couple workspace, appearance mode, and preferences. Remember: private events always stay strictly confidential!',
      pose: MisoPose.reassuring,
      targetId: 'tour_nav_profile',
      pointerPosition: SpeechPointerPosition.bottom,
    ),
    const GuidedTourStep(
      id: 'step_finish',
      title: 'You\'re All Set! ✨',
      message:
          'That\'s the tour! Go ahead and make some lovely plans together.',
      pose: MisoPose.celebrating,
      targetId: null,
      pointerPosition: SpeechPointerPosition.none,
    ),
  ];
}
