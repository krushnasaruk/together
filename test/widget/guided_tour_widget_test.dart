import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together/core/onboarding/guided_tour_controller.dart';
import 'package:together/core/onboarding/guided_tour_registry.dart';
import 'package:together/core/onboarding/guided_tour_step.dart';
import 'package:together/core/onboarding/widgets/comic_dialogue_bubble.dart';
import 'package:together/core/onboarding/widgets/guided_tour_overlay.dart';
import 'package:together/shared/widgets/mascot/together_mascot.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Guided Tour Widget Tests', () {
    testWidgets('TourTarget registers and unregisters with GuidedTourRegistry',
        (tester) async {
      const targetId = 'test_sample_target';

      expect(GuidedTourRegistry.getKey(targetId), isNull);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: TourTarget(
                id: targetId,
                child: Text('Target Button'),
              ),
            ),
          ),
        ),
      );

      expect(GuidedTourRegistry.getKey(targetId), isNotNull);
      final rect = GuidedTourRegistry.getTargetRect(targetId);
      expect(rect, isNotNull);
      expect(rect!.width, greaterThan(0));

      // Pump empty widget to test disposal
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SizedBox()),
        ),
      );

      expect(GuidedTourRegistry.getKey(targetId), isNull);
    });

    testWidgets('ComicDialogueBubble renders title, message, counter, and handles taps',
        (tester) async {
      bool nextTapped = false;
      bool prevTapped = false;
      bool closeTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComicDialogueBubble(
              title: 'Welcome to Miso!',
              message: 'This is a test speech bubble.',
              pose: MisoPose.wave,
              stepIndex: 1,
              totalSteps: 5,
              pointerPosition: SpeechPointerPosition.bottom,
              onNext: () => nextTapped = true,
              onPrevious: () => prevTapped = true,
              onClose: () => closeTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Welcome to Miso!'), findsOneWidget);
      expect(find.text('This is a test speech bubble.'), findsOneWidget);
      expect(find.text('2 / 5'), findsOneWidget);
      expect(find.text('Previous'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      await tester.tap(find.text('Next'));
      expect(nextTapped, isTrue);

      await tester.tap(find.text('Previous'));
      expect(prevTapped, isTrue);

      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(closeTapped, isTrue);
    });

    testWidgets('GuidedTourOverlay renders when controller is active',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: GuidedTourOverlay(
              child: Scaffold(
                body: Center(child: Text('Main Content Underneath')),
              ),
            ),
          ),
        ),
      );

      // Inactive initially
      expect(find.text('Main Content Underneath'), findsOneWidget);
      expect(find.byType(ComicDialogueBubble), findsNothing);

      // Activate tour
      container.read(guidedTourControllerProvider.notifier).startFirstRunTour();
      await tester.pump();

      // Comic dialogue bubble should now be visible
      expect(find.byType(ComicDialogueBubble), findsOneWidget);
      expect(find.text('Hey there! 🐱'), findsOneWidget);

      // Close tour
      container.read(guidedTourControllerProvider.notifier).skipTour();
      await tester.pump();

      expect(find.byType(ComicDialogueBubble), findsNothing);
    });
  });
}
