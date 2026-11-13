import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together/app.dart';
import 'package:together/features/events/domain/models/event_model.dart';
import 'package:together/features/events/presentation/providers/event_provider.dart';
import 'package:together/features/notifications/domain/models/notification_model.dart';
import 'package:together/features/notifications/presentation/providers/notification_provider.dart';
import 'package:together/shared/widgets/partner_switcher_badge.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
      'TogetherApp launches and displays personalized Today screen for Alex',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: TogetherApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Alex is the active user
    expect(find.text('Good day, Alex'), findsOneWidget);
    expect(find.text("Taylor's Schedule"), findsOneWidget);
    expect(find.text('Your Schedule'), findsOneWidget);
    expect(find.byType(PartnerSwitcherBadge), findsWidgets);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets(
      'Strict Privacy Rule: Private events are masked as Busy for partner',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TogetherApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Alex's view:
    // 1. Alex sees Alex's own private dentist appointment in full detail
    expect(find.text('Dentist Checkup & Routine Cleaning'), findsOneWidget);

    // 2. Alex sees Taylor's secret private shopping as masked "Busy (Private)"
    expect(find.text('Secret Anniversary Gift Shopping'), findsNothing);
    expect(find.text('Busy (Private)'), findsOneWidget);

    // Now switch active view to Taylor
    await tester.tap(find.byType(PartnerSwitcherBadge).first);
    await tester.pumpAndSettle();

    // Taylor's view:
    // 1. Taylor now sees own secret shopping in full detail
    expect(find.text('Good day, Taylor'), findsOneWidget);
    expect(find.text('Secret Anniversary Gift Shopping'), findsOneWidget);

    // 2. Taylor sees Alex's dentist appointment as masked "Busy (Private)"
    expect(find.text('Dentist Checkup & Routine Cleaning'), findsNothing);
    expect(find.text('Busy (Private)'), findsOneWidget);
  });

  testWidgets(
      'Bottom navigation switches seamlessly across all 4 destinations',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Day'), findsOneWidget);
    expect(find.text('Timeline'), findsOneWidget);

    // Test Calendar View switching (e.g., tap Timeline)
    await tester.tap(find.text('Timeline'));
    await tester.pumpAndSettle();

    // 2. Navigate to Together tab
    await tester.tap(find.byIcon(Icons.favorite_border_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Together Space'), findsOneWidget);
    expect(find.textContaining('Days'), findsOneWidget);
    expect(find.text('together'), findsOneWidget);
    expect(find.text('Date Night'), findsWidgets);
    expect(find.text('Bucket List'), findsOneWidget);

    // 3. Navigate to Profile tab
    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Profile & Settings'), findsOneWidget);
    expect(find.text('Couple Workspace'), findsOneWidget);
    expect(find.text('Notification Preferences'), findsOneWidget);
    expect(find.text('Privacy & Visibility'), findsOneWidget);

    // 4. Return to Today tab
    await tester.tap(find.byIcon(Icons.wb_sunny_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Good day, Alex'), findsOneWidget);
  });

  testWidgets('Adding an event dispatches notification to partner',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initial state check
    final initialNotifs = container.read(notificationProvider);
    final initialCount = initialNotifs.length;

    final now = DateTime.now();
    final newEvent = CalendarEvent(
      id: 'test_event_99',
      coupleId: 'couple_workspace_01',
      ownerId: 'user_alex',
      ownerName: 'Alex',
      title: 'Coffee at Blue Bottle',
      startTime: now.add(const Duration(hours: 1)),
      endTime: now.add(const Duration(hours: 2)),
      createdAt: now,
      updatedAt: now,
    );

    // Add event as Alex
    container.read(eventProvider.notifier).addEvent(newEvent);

    // Partner (Taylor) should have received a notification
    final updatedNotifs = container.read(notificationProvider);
    expect(updatedNotifs.length, equals(initialCount + 1));

    final latestNotif = updatedNotifs.first;
    expect(latestNotif.recipientId, equals('user_taylor'));
    expect(latestNotif.senderId, equals('user_alex'));
    expect(latestNotif.type, equals(NotificationType.eventCreated));
    expect(latestNotif.title, contains('Coffee at Blue Bottle'));
  });
}
