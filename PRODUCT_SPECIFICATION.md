# Product Specification — Together

**Product:** Together  
**Tagline:** Two lives. One shared space.  
**Version:** 1.0.0 (Production Roadmap)

---

## 1. Problem Statement & User Persona

Busy partners struggle to coordinate daily activities, resulting in repetitive questioning ("Where are you?", "Are you free at 3?"), context-free waiting, and friction when plans change.

Together solves this problem through a private, calm, and relationship-aware shared calendar that prioritizes understanding over surveillance.

---

## 2. Non-Negotiable Product Boundaries

- **No Surveillance**: No continuous GPS tracking, no geofencing, no background location pinging.
- **No Artificial Pressure**: No relationship streaks, no gamification points, no engagement prompts.
- **Equal Partnership**: Neither partner possesses administrative hierarchy or monitoring control over the other.
- **Privacy by Default**: Every personal event can be marked Private, presenting only as a busy time block to the partner.

---

## 3. Four Core Destinations & Information Architecture

### Destination 1: Today (`/today`)
- **Primary Goal**: Answer *"What is happening in both of our lives today?"* with partner-first priority.
- **Hierarchy**:
  1. Header: Greeting, partner switcher, and unread notification bell.
  2. Partner Overview: Partner name, current activity (or busy state), next activity, and schedule freshness.
  3. Shared Availability / Potential Time Together: Calculated overlapping free intervals.
  4. Combined Chronological Timeline: Unified stream of both partners' daily events with current-time indicator and past-event subduing.
  5. Quick-add FAB for instant event scheduling.

### Destination 2: Calendar (`/calendar`)
- **Primary Goal**: Macro-planning and multi-date schedule exploration.
- **Views**:
  - Month: 35-day grid with dot indicators (Sage for Partner A, Rose for Partner B, Blue for Together).
  - Week: 7-day strip with event summary chips and free-day banners.
  - Day: Hour-by-hour timeline (7 AM – 10 PM) with automated schedule overlap detection.
  - Timeline: Chronological stream across dates.
- **Navigation**: Month/week/day selectors with date pagination and "Go to Today" action.

### Destination 3: Together Space (`/together`)
- **Primary Goal**: Dedicated relationship space for shared intentionality.
- **Core Features**:
  - Milestone & Anniversary Counter: Days elapsed together with milestone tracker.
  - Date Night Planner: Curated suggestions and custom shared experiences.
  - Shared Bucket List: Adventures, places to visit, books, and movies with completion checkboxes.
  - Occasions: Birthdays and anniversaries with proactive context.

### Destination 4: Profile & Settings (`/profile`)
- **Primary Goal**: Identity, partner pairing, and privacy controls.
- **Core Features**:
  - Personal identity card and avatar.
  - Couple workspace management & single-use invite codes (`TOG-789`).
  - Notification preference switches (New events, Rescheduled events, Status updates).
  - Default visibility controls (Default all new events to Private).
  - Safe disconnection and account deletion workflows.

