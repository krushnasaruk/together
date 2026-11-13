# Architectural & Product Decision Records (ADR) — Together

## ADR-001: Feature-First Layered Architecture
- **Date**: 2026-11-13
- **Status**: Approved
- **Context**: The app coordinates diverse life domains (calendar, pairing, notifications, romantic plans, voluntary status). A generic flat structure would lead to spaghetti code and poor separation of concerns.
- **Decision**: Adopt a feature-first architecture (`features/{feature}/{data,domain,presentation}`) with a shared `core/` for theme, router, and failures.
- **Consequences**: Strict modularity, independent feature development, simplified testing.

---

## ADR-002: Dual Persona Demo Authentication for Rapid Evaluation
- **Date**: 2026-11-13
- **Status**: Approved
- **Context**: Evaluating couples workflows requires two authenticated identities interacting simultaneously. On a single development simulator or during automated tests, logging out and logging in repeatedly introduces immense friction.
- **Decision**: Implement demo authentication with two pre-configured partners (Alex Rivers & Taylor Brooks) paired into `couple_workspace_01`, with a 1-tap persona switcher badge in the UI.
- **Consequences**: Enables immediate verification of private event masking, push notifications, and schedule overlaps on a single device without bypassing underlying security rules.

---

## ADR-003: Strict Server-Side Privacy Projection for Private Events
- **Date**: 2026-11-13
- **Status**: Approved
- **Context**: Fetching a complete private event document to the partner's client and hiding fields in the UI violates the non-negotiable privacy principle (malicious users or network proxies could inspect private fields).
- **Decision**: Firestore security rules restrict reading full private event documents to the owner only. The partner only receives masked busy blocks.
- **Consequences**: Absolute confidentiality for surprises, medical appointments, and personal therapy.

---

## ADR-004: Voluntary Status Updates Over Continuous GPS Surveillance
- **Date**: 2026-11-13
- **Status**: Approved
- **Context**: Relationship apps often devolve into invasive location trackers.
- **Decision**: Reject continuous background location tracking. Support voluntary, manual status broadcasts (e.g. "On my way", "Free now", "Running late") with a 2-hour auto-expiration.
- **Consequences**: Fosters trust, communication, and zero battery drain from GPS services.

---

## ADR-005: State Management with Riverpod 2.x
- **Date**: 2026-11-13
- **Status**: Approved
- **Context**: Complex real-time synchronization between couple members requires reactive, testable state management without boilerplate.
- **Decision**: Use Riverpod with `StateNotifier` and auto-disposing stream providers.
- **Consequences**: Clean separation between presentation widgets and domain state, easy mocking in unit tests.

