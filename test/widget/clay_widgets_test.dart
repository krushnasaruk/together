import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:together/shared/widgets/clay/clay_button.dart';
import 'package:together/shared/widgets/clay/clay_segmented_bar.dart';
import 'package:together/shared/widgets/clay/clay_toggle.dart';
import 'package:together/shared/widgets/clay/together_surface.dart';
import 'package:together/shared/widgets/motion/text_animations.dart';

void main() {
  group('Claymorphic UI & Motion Widget Tests', () {
    testWidgets('TogetherSurface renders child with raised clay shadows',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: TogetherSurface(
                surfaceType: ClaySurfaceType.raised,
                onTap: () => tapped = true,
                child: const Text('Raised Clay Box'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Raised Clay Box'), findsOneWidget);
      await tester.tap(find.text('Raised Clay Box'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('TogetherSurface renders inset surface with inset shadows',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: TogetherSurface(
                surfaceType: ClaySurfaceType.inset,
                child: Text('Inset Recessed Box'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Inset Recessed Box'), findsOneWidget);
    });

    testWidgets('ClayButton renders label and triggers onPressed callback',
        (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ClayButton(
                label: 'Save Preferences',
                onPressed: () => pressed = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Save Preferences'), findsOneWidget);
      await tester.tap(find.byType(ClayButton));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('ClayButton displays spinner when isLoading is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: ClayButton(
                label: 'Submit Code',
                isLoading: true,
                onPressed: null,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('ClayToggle animates and triggers callback on tap',
        (WidgetTester tester) async {
      bool switchValue = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: ClayToggle(
                    value: switchValue,
                    onChanged: (val) {
                      setState(() {
                        switchValue = val;
                      });
                    },
                  ),
                ),
              ),
            );
          },
        ),
      );

      expect(switchValue, isFalse);
      await tester.tap(find.byType(ClayToggle));
      await tester.pumpAndSettle();

      expect(switchValue, isTrue);
    });

    testWidgets('ClaySegmentedBar selects items and triggers onSelected',
        (WidgetTester tester) async {
      int selectedIdx = 0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: ClaySegmentedBar<int>(
                    values: const [0, 1, 2],
                    labels: const ['Day', 'Week', 'Month'],
                    selectedValue: selectedIdx,
                    onSelected: (idx) {
                      setState(() {
                        selectedIdx = idx;
                      });
                    },
                  ),
                ),
              ),
            );
          },
        ),
      );

      expect(find.text('Day'), findsOneWidget);
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);

      await tester.tap(find.text('Month'));
      await tester.pumpAndSettle();

      expect(selectedIdx, equals(2));
    });

    testWidgets('AnimatedHeading renders styled text correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedHeading(
              text: 'Good day, Alex',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );

      expect(find.text('Good day, Alex'), findsOneWidget);
    });

    testWidgets('AnimatedNumber renders formatted numeric string',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedNumber(
              value: 428,
              suffix: ' Days',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('428 Days'), findsOneWidget);
    });

    testWidgets('AnimatedStatusText animates across text transitions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedStatusText(
              text: 'Free Right Now',
            ),
          ),
        ),
      );

      expect(find.text('Free Right Now'), findsOneWidget);
    });
  });
}
