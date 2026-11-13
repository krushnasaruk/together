# Architecture Documentation — Together

## 1. Overview and Core Philosophy

**Together** is a relationship-focused scheduling and life-coordination mobile application built for couples. Its architecture is guided by the following principles:

1. **Equal Participation & Autonomy**: Both partners have equal rights within their shared space while retaining strict control over personal and private events.
2. **Zero-Trust Client Authorization**: All sensitive operations (pairing, membership verification, notification dispatch) are verified against server-side authorization and Firestore security rules.
3. **Data Privacy by Design**: Private events never expose titles, descriptions, or locations to a partner. The partner only receives a masked "Busy" time block.
4. **Resilient Synchronization**: Real-time Firestore listeners, optimistic UI updates, conflict resolution via event versioning, and offline caching.
5. **Clean, Maintainable Layering**: Feature-first, layered architecture with strict separation between Presentation, Domain, and Data layers.

---

## 2. Layered Architecture

The application strictly separates responsibilities into three distinct layers per feature:

```
lib/
├── core/                         # Cross-cutting foundational modules
│   ├── constants/                # App-wide constants, strings, timing
│   ├── errors/                   # Custom failure classes and error mappers
│   ├── router/                   # GoRouter configuration and route definitions
│   ├── services/                 # Global services (Analytics, Crashlytics, Local storage)
│   ├── theme/                    # Material 3 design tokens, typography, palettes
│   └── utils/                    # Date formatters, validators, extensions
│
├── features/                     # Feature modules (Feature-First)
│   ├── authentication/           # Sign-in, sign-up, password reset, session
│   ├── pairing/                  # Couple invitations, code generation, pairing flow
│   ├── calendar/                 # Shared calendar views (Day, Week, Month, Timeline)
│   ├── events/                   # Event creation, editing, deletion, recurring rules
│   ├── notifications/            # Push notification handling, token mgmt, in-app feed
│   ├── availability/             # Real-time availability computation & conflict detection
│   ├── together_time/            # Date nights, shared bucket lists, anniversaries
│   ├── profile/                  # User profile and partner profile details
│   └── settings/                 # Notification preferences, privacy controls
│
└── shared/                       # Reusable domain models, UI components, extensions
    ├── models/
    └── widgets/
```

### Detailed Layer Breakdown

#### A. Presentation Layer
- **Screens**: Top-level views navigated to by `GoRouter`. Responsible only for layout composition and binding to Riverpod providers.
- **Widgets**: Reusable, atomic or composed UI elements with no direct repository access.
- **Controllers / Notifiers**: Riverpod `AsyncNotifier` or `Notifier` classes that hold UI state, handle user actions, and communicate with Domain use cases/repositories.

#### B. Domain Layer
- **Entities**: Pure Dart objects representing core business entities (e.g., `User`, `Couple`, `CalendarEvent`, `Invitation`). Fully immutable, with copyWith and validation logic.
- **Value Objects**: Types encapsulating business rules (e.g., `EventVisibility`, `EventCategory`, `RecurrenceRule`).
- **Repository Interfaces**: Abstract contracts defining operations required by the business logic, independent of any backend or database technology.

#### C. Data Layer
- **Data Sources**: Low-level communication with Firebase Auth, Cloud Firestore, Firebase Cloud Messaging, and local storage (Hive/Isar/SharedPreferences).
- **DTOs (Data Transfer Objects)**: Serializable models with `fromJson` and `toJson` (or `fromFirestore` and `toFirestore`) converting Firestore timestamps and field maps into domain entities.
- **Repository Implementations**: Concrete classes implementing the domain repository interfaces. They orchestrate data sources, perform data mapping, cache results, and translate raw exceptions into domain `Failure` instances.

---

## 3. State Management Strategy (Riverpod)

- **State Management Engine**: Riverpod 2.x with code generation / typed providers (`flutter_riverpod`).
- **Unidirectional Data Flow**:
  1. User triggers an action in the UI.
  2. The UI invokes a method on a Riverpod controller/notifier.
  3. The controller performs optimistic updates or sets state to `AsyncLoading`.
  4. The repository executes the data operation and returns a `Result<T, Failure>`.
  5. The controller updates state with `AsyncData` or `AsyncError`.
  6. The UI reacts declaratively via `ref.watch()`.
- **Stream Providers**: Firestore real-time queries (events, couple status, notifications) are exposed through `StreamProvider.autoDispose` or family providers to ensure automatic resource cleanup when views unmount.

---

## 4. Routing and Navigation (GoRouter)

- **Declarative Router**: Managed via a central `appRouterProvider`.
- **Navigation Redirection (Guards)**:
  - Unauthenticated users $\to$ `/login` or `/register`.
  - Authenticated users without a paired couple $\to$ `/pairing`.
  - Authenticated and paired users $\to$ `/today` (Primary destination).
- **Core Navigation Destinations**:
  1. `/today`: Overview of today's schedule for both partners, quick status updates, next event.
  2. `/calendar`: Day, week, month, and combined timeline views.
  3. `/together`: Shared plans, date nights, anniversaries, bucket lists.
  4. `/profile`: Personal profile, partner settings, notifications, privacy.
- **Deep Linking**: Configured to parse FCM notification payloads and route directly to event details (e.g., `/events/:id`) or invitation acceptance (`/pairing?code=ABCDEF`).

---

## 5. Design System & Theming

- **Material 3 Foundation**: Custom `ColorScheme` adhering to the product design direction:
  - **Backgrounds**: Warm cream (`#FBF9F5`) and warm off-white (`#F5F2EB`).
  - **Primary / Partner A**: Muted Sage Green (`#4D6A56` / `#364E3E`).
  - **Secondary / Partner B**: Dusty Rose / Terracotta (`#A45D5D` / `#8B4B4B`).
  - **Neutral & Borders**: Restrained sand/charcoal tones with 1px hairline borders (`#E5E0D8`).
  - **Typography**: Clean, mature, human sans-serif typography with generous line heights and whitespace.

---

## 6. Testing Strategy

1. **Unit Tests**:
   - Domain entity invariants (event overlapping, date calculations, recurrence rules).
   - DTO serialization and deserialization.
   - Riverpod controller business logic using mock repositories.
2. **Widget Tests**:
   - Component rendering, loading indicators, empty states, error handling.
   - Form validation on login, registration, and event authoring.
3. **Integration Tests & Firebase Emulators**:
   - Firestore security rules verification using `@firebase/rules-unit-testing`.
   - Full flow testing from authentication to event creation and calendar rendering.
