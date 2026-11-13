# Feature Inventory & Implementation Status — Together

Last Updated: 2026-11-13

| Feature ID | Feature Name | Layer | Status | Verification Evidence |
| :--- | :--- | :--- | :--- | :--- |
| **FEAT-01** | Multi-Platform Material 3 Theme Tokens | Core Theme | Completed | `AppColors`, `AppTypography`, `AppTheme` |
| **FEAT-02** | Declarative Stateful Navigation Shell | Core Router | Completed | `AppRouter` with 4 `StatefulShellBranch`es |
| **FEAT-03** | Demo Authentication & 1-Tap Persona Switcher | Auth Presentation | Completed | `AuthNotifier`, `PartnerSwitcherBadge` |
| **FEAT-04** | Couple Pairing & Single-Use Code Generator | Pairing Domain/UI | Completed | `CoupleModel`, `PairingSheet` (`TOG-789`) |
| **FEAT-05** | Event Domain Model & Taxonomy | Events Domain | Completed | `CalendarEvent`, 8 Categories, Versioning |
| **FEAT-06** | Strict Privacy Masking ("Busy" Blocks) | Events Domain/UI | Completed | `event.displayTitleFor(viewerId)` & tests |
| **FEAT-07** | Event CRUD & Lifecycle Management | Events Presentation | Completed | `EventFormSheet`, `EventDetailsSheet` |
| **FEAT-08** | Today Screen Dashboard | Calendar UI | Completed | `TodayScreen` with partner schedule |
| **FEAT-09** | Shared Calendar: 4-Way Views | Calendar UI | Completed | Month Grid, Week Strip, Day Timeline, Stream |
| **FEAT-10** | Schedule Overlap Detection Banner | Calendar UI | Completed | Real-time interval overlap warning |
| **FEAT-11** | Voluntary Quick Status Updates (6 Presets) | Availability UI | Completed | `StatusPickerSheet` (no GPS surveillance) |
| **FEAT-12** | In-App Notification Feed & Badge | Notifications UI | Completed | `NotificationsSheet`, unread badge counter |
| **FEAT-13** | Automated Partner Notification Dispatch | Notifications State | Completed | `NotificationNotifier.dispatchNotificationToPartner` |
| **FEAT-14** | Relationship Anniversary Counter | Together UI | Completed | `TogetherScreen` (Days elapsed calculation) |
| **FEAT-15** | Curated & Custom Date Night Planner | Together UI | Completed | `TogetherPlan`, `AddPlanSheet` |
| **FEAT-16** | Shared Bucket List with Completion Toggles | Together UI | Completed | Checkbox persistence & timestamping |
| **FEAT-17** | Potential Time Together (Free Windows) | Availability Engine | In Progress | Algorithms defined; engine integration |
| **FEAT-18** | Production Firebase Auth UI Screens | Auth Presentation | In Progress | Login, Register, Forgot Password |
| **FEAT-19** | Firebase Cloud Functions Push Triggers | Backend | In Progress | Cloud Functions project scaffolding |
| **FEAT-20** | Automated Test Suite | QA Testing | Completed | 4/4 passing widget and domain tests |

