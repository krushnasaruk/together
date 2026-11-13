import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together/core/onboarding/guided_tour_controller.dart';
import 'package:together/core/onboarding/guided_tour_step.dart';
import 'package:together/core/onboarding/guided_tour_storage.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('GuidedTour Engine Unit Tests', () {
    test('Default tour sequence catalog has valid steps', () {
      final steps = TourSequence.firstRunSteps;
      expect(steps.length, equals(6));
      expect(steps.first.id, equals('step_welcome'));
      expect(steps.last.id, equals('step_finish'));
    });

    test('GuidedTourStorage persists and resets completion status', () async {
      const storage = GuidedTourStorage();
      const tourId = 'test_tour_01';

      expect(await storage.isTourCompleted(tourId), isFalse);

      await storage.setTourCompleted(tourId, true);
      expect(await storage.isTourCompleted(tourId), isTrue);

      await storage.resetTour(tourId);
      expect(await storage.isTourCompleted(tourId), isFalse);
    });

    test('GuidedTourController navigates steps forwards and backwards', () {
      const storage = GuidedTourStorage();
      final controller = GuidedTourController(storage);

      expect(controller.state.isActive, isFalse);

      controller.startFirstRunTour();
      expect(controller.state.isActive, isTrue);
      expect(controller.state.currentIndex, equals(0));
      expect(controller.state.isFirstStep, isTrue);
      expect(controller.state.currentStep?.id, equals('step_welcome'));

      // Next step
      controller.nextStep();
      expect(controller.state.currentIndex, equals(1));
      expect(controller.state.isFirstStep, isFalse);
      expect(controller.state.currentStep?.id, equals('step_today'));

      // Previous step
      controller.previousStep();
      expect(controller.state.currentIndex, equals(0));
      expect(controller.state.isFirstStep, isTrue);

      // Skip tour terminates active state
      controller.skipTour();
      expect(controller.state.isActive, isFalse);
    });

    test('Advancing past final step concludes tour', () {
      const storage = GuidedTourStorage();
      final controller = GuidedTourController(storage);

      controller.startFirstRunTour();
      final total = controller.state.totalSteps;

      for (int i = 0; i < total - 1; i++) {
        expect(controller.state.isActive, isTrue);
        controller.nextStep();
      }

      expect(controller.state.isLastStep, isTrue);
      expect(controller.state.currentIndex, equals(total - 1));

      // Final step advance finishes tour
      controller.nextStep();
      expect(controller.state.isActive, isFalse);
      expect(controller.state.hasCompletedFirstRun, isTrue);
    });
  });
}
