import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:together/app.dart';

void main() {
  testWidgets('TogetherApp launches and displays Today screen by default',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TogetherApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Today screen elements are visible
    expect(find.text('Good day'), findsOneWidget);
    expect(find.text("Partner's Schedule"), findsOneWidget);
    expect(find.text('Your Schedule'), findsOneWidget);
    expect(find.text('Connected & In Sync'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('Bottom navigation switches between all 4 core destinations',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TogetherApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Navigate to Calendar tab
    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Shared Calendar'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);
    expect(find.text('Timeline'), findsOneWidget);

    // 2. Navigate to Together tab
    await tester.tap(find.byIcon(Icons.favorite_border_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Together Space'), findsOneWidget);
    expect(find.text('Shared Moments'), findsOneWidget);
    expect(find.text('Date Night Ideas'), findsOneWidget);

    // 3. Navigate to Profile tab
    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Profile & Settings'), findsOneWidget);
    expect(find.text('Couple Workspace'), findsOneWidget);

    // 4. Return to Today tab
    await tester.tap(find.byIcon(Icons.wb_sunny_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Good day'), findsOneWidget);
  });
}
