import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'guided_tour_step.dart';
import 'guided_tour_storage.dart';

/// State representation for Miso's Little Guide walkthrough system.
class GuidedTourState {
  final bool isActive;
  final String? tourId;
  final List<GuidedTourStep> steps;
  final int currentIndex;
  final bool hasCompletedFirstRun;

  const GuidedTourState({
    this.isActive = false,
    this.tourId,
    this.steps = const [],
    this.currentIndex = 0,
    this.hasCompletedFirstRun = false,
  });

  GuidedTourStep? get currentStep {
    if (!isActive || steps.isEmpty || currentIndex >= steps.length) {
      return null;
    }
    return steps[currentIndex];
  }

  bool get isFirstStep => currentIndex == 0;
  bool get isLastStep => steps.isNotEmpty && currentIndex == steps.length - 1;
  int get totalSteps => steps.length;

  GuidedTourState copyWith({
    bool? isActive,
    String? tourId,
    List<GuidedTourStep>? steps,
    int? currentIndex,
    bool? hasCompletedFirstRun,
  }) {
    return GuidedTourState(
      isActive: isActive ?? this.isActive,
      tourId: tourId ?? this.tourId,
      steps: steps ?? this.steps,
      currentIndex: currentIndex ?? this.currentIndex,
      hasCompletedFirstRun: hasCompletedFirstRun ?? this.hasCompletedFirstRun,
    );
  }
}

/// Storage provider
final guidedTourStorageProvider = Provider<GuidedTourStorage>((ref) {
  return const GuidedTourStorage();
});

/// Riverpod Controller for Guided Tour walkthroughs.
class GuidedTourController extends StateNotifier<GuidedTourState> {
  final GuidedTourStorage _storage;

  GuidedTourController(this._storage) : super(const GuidedTourState()) {
    _init();
  }

  Future<void> _init() async {
    final completed =
        await _storage.isTourCompleted(TourSequence.firstRunTourId);
    state = state.copyWith(hasCompletedFirstRun: completed);
  }

  /// Start a tour sequence.
  void startTour(String tourId, List<GuidedTourStep> steps) {
    if (steps.isEmpty) return;
    state = state.copyWith(
      isActive: true,
      tourId: tourId,
      steps: steps,
      currentIndex: 0,
    );
  }

  /// Start the default first-run guided tour.
  void startFirstRunTour() {
    startTour(TourSequence.firstRunTourId, TourSequence.firstRunSteps);
  }

  /// Advance to the next tour step or conclude if on the final step.
  void nextStep() {
    if (!state.isActive) return;
    if (state.isLastStep) {
      finishTour();
    } else {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  /// Return to the previous tour step.
  void previousStep() {
    if (!state.isActive || state.currentIndex <= 0) return;
    state = state.copyWith(currentIndex: state.currentIndex - 1);
  }

  /// Prematurely dismiss / skip the tour and persist completion.
  void skipTour() {
    if (state.tourId != null) {
      _storage.setTourCompleted(state.tourId!, true);
    }
    state = state.copyWith(
      isActive: false,
      hasCompletedFirstRun: true,
    );
  }

  /// Successfully conclude the tour sequence.
  void finishTour() {
    if (state.tourId != null) {
      _storage.setTourCompleted(state.tourId!, true);
    }
    state = state.copyWith(
      isActive: false,
      hasCompletedFirstRun: true,
    );
  }

  /// Reset tour status and replay from step 1.
  Future<void> replayFirstRunTour() async {
    await _storage.resetTour(TourSequence.firstRunTourId);
    state = state.copyWith(hasCompletedFirstRun: false);
    startFirstRunTour();
  }
}

final guidedTourControllerProvider =
    StateNotifierProvider<GuidedTourController, GuidedTourState>((ref) {
  final storage = ref.watch(guidedTourStorageProvider);
  return GuidedTourController(storage);
});
