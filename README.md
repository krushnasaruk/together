# Together
**Two lives. One shared space.**

A private relationship-aware shared calendar and daily coordination platform designed for couples.

---

## 1. Product Overview

People with busy schedules often struggle to keep their partners informed about daily activities, changing plans, and availability. Together solves this through:
- **Personal and Shared Schedules**: Clear separation between individual commitments and shared time.
- **Strict Privacy by Default**: Private events display only as reserved *"Busy"* blocks to the partner; personal details, notes, and locations are strictly masked.
- **Partner-First Daily Dashboard (Today)**: Instant visibility into your partner's current activity, next commitment, and schedule freshness.
- **Potential Time Together Engine**: Automated detection of overlapping free windows without presenting assumptions as confirmed facts.
- **Shared Calendar**: Month, Week, Day (with overlap detection), and Chronological Timeline views.
- **Voluntary Quick Status Updates**: Non-surveillance availability updates (🏃 On my way, ⏳ Running late, 💼 Meeting extended, 🌿 Free now, ☕ Taking a break, 🎧 Need focus time).
- **Together Space**: Anniversary and milestone tracker, curated date nights, and shared romantic bucket list.

---

## 2. Architecture & Tech Stack

- **Mobile Client**: Flutter 3.24 (Dart 3.5), Material 3 custom design system
- **State Management**: Riverpod 2.6 (`StateNotifier`, `Provider`, `Provider.family`)
- **Routing**: GoRouter 14.8 with `StatefulShellRoute` across 4 persistent destinations
- **Backend & Database**: Google Cloud Firestore, Firebase Authentication, Cloud Functions
- **Local Persistence**: `SharedPreferences` cached state with offline support
- **Design Palette**: Warm cream (`#FBF9F5`), muted sage green (`#4D6A56`), dusty rose (`#A45D5D`), slate blue (`#556F7A`)

---

## 3. Getting Started & Commands

### Prerequisites
- Flutter SDK 3.24+
- Dart SDK 3.5+
- Node.js 20+ and npm (for Cloud Functions and Firebase Emulators)

### Dependency Installation
```bash
flutter pub get
```

### Running the Application
```bash
# Run on Windows Desktop
flutter run -d windows

# Run on Chrome Web
flutter run -d chrome

# Run with Firebase Local Emulators
flutter run --dart-define=USE_FIREBASE_EMULATOR=true
```

### Firebase Emulator Suite
```bash
# Start Auth and Firestore emulators
npx firebase emulators:start
```

---

## 4. Testing & Code Quality

```bash
# Format code
dart format .

# Static analysis
flutter analyze

# Run unit and widget test suite
flutter test

# Production build verification
flutter build web --no-tree-shake-icons
```

---

## 5. Architectural Documentation Reference

- [ARCHITECTURE.md](file:///c:/Users/Krushna/OneDrive/Documents/personal%20projects/Together/ARCHITECTURE.md): System layers, dependencies, state management rules.
- [DATABASE_SCHEMA.md](file:///c:/Users/Krushna/OneDrive/Documents/personal%20projects/Together/DATABASE_SCHEMA.md): Firestore collections, document structures, index definitions.
- [SECURITY.md](file:///c:/Users/Krushna/OneDrive/Documents/personal%20projects/Together/SECURITY.md): Zero-trust client boundaries, private event projection, security rules.
- [PRODUCT_SPECIFICATION.md](file:///c:/Users/Krushna/OneDrive/Documents/personal%20projects/Together/PRODUCT_SPECIFICATION.md): Core user personas, principles, and feature rules.
- [FEATURES.md](file:///c:/Users/Krushna/OneDrive/Documents/personal%20projects/Together/FEATURES.md): Traceability matrix of all features and implementation status.
- [TESTING_STRATEGY.md](file:///c:/Users/Krushna/OneDrive/Documents/personal%20projects/Together/TESTING_STRATEGY.md): Invariant testing requirements, test pyramid, commands.
- [DECISIONS.md](file:///c:/Users/Krushna/OneDrive/Documents/personal%20projects/Together/DECISIONS.md): Architectural Decision Records (ADRs).
- [DEVELOPMENT_LOG.md](file:///c:/Users/Krushna/OneDrive/Documents/personal%20projects/Together/DEVELOPMENT_LOG.md): Chronological engineering log.
- [IMPLEMENTATION_STATUS.md](file:///c:/Users/Krushna/OneDrive/Documents/personal%20projects/Together/IMPLEMENTATION_STATUS.md): Roadmap tracker across all milestones.
