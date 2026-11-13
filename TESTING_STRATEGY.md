# Testing Strategy — Together

## 1. Testing Philosophy
Testing is a mandatory, continuous engineering discipline in Together. Every core business rule, permission boundary, and privacy invariant must have automated tests.

---

## 2. Test Pyramid & Execution Matrix

```
       / \
      /   \     E2E / Integration Tests (Firebase Emulators & Multi-User)
     /-----\
    /       \    Widget & Navigation Tests (Today, Calendar, Together, Profile)
   /---------\
  /           \  Unit & Domain Invariant Tests (Privacy masking, Free windows, RRULE)
 /-------------\
```

### Layer 1: Unit & Domain Tests
- **Target**: Entity invariants, recurrence date math, overlap detection algorithms, availability calculators, DTO serialization.
- **Tools**: Dart `test` package.
- **Execution**: `flutter test test/unit/`

### Layer 2: Widget & State Tests
- **Target**: Screen composition, 1-tap partner switching, modal bottom sheets, form input validation, empty states, error fallbacks.
- **Tools**: `flutter_test`, Riverpod `ProviderContainer`.
- **Execution**: `flutter test test/widget_test.dart`

### Layer 3: Security Rules Tests
- **Target**: Positive and negative authorization tests against Firestore rules.
- **Tools**: Firebase Emulator Suite, `@firebase/rules-unit-testing`.
- **Execution**: `firebase emulators:exec "npm test"`

---

## 3. Mandatory Invariant Test Cases

1. **Privacy Boundary Invariant**:
   - Partner B MUST NEVER receive the title, location, or notes of Partner A's private event.
   - Partner B receives only `startTime`, `endTime`, and synthetic title `"Busy (Private)"`.
2. **Notification Origin Invariant**:
   - The user who triggers an event change MUST NEVER receive their own notification.
3. **Availability Honesty Invariant**:
   - Missing schedule data is NEVER interpreted as confirmed free time.
   - Cancelled events are excluded from busy interval calculations.
   - Private events count as busy intervals.
4. **Schedule Overlap Invariant**:
   - Two concurrent events within the same time window must trigger an overlap warning banner without hiding either event.

---

## 4. Local Validation Commands

```bash
# Code formatting check
dart format .

# Static code analysis
flutter analyze

# Automated widget and unit tests
flutter test

# Production web build compilation test
flutter build web --no-tree-shake-icons
```

