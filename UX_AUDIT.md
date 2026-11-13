# UX Audit — Together Mobile Platform

**Date:** 2026-11-13  
**Auditor:** Senior Mobile UX Engineer, Product Designer & Motion Designer  
**Platform:** Flutter (Android, iOS, Web)  
**Visual Identity:** Miso the Cat Mascot, Warm Cream, Muted Sage Green, Subdued Rose  

---

## 1. Executive Summary

Together is a private shared calendar and daily coordination platform designed for two partners ("Two lives. One shared space."). 
Following the visual identity integration with Miso, this audit reviews the application from a product design and interaction engineering perspective to elevate it to a tier-one consumer mobile application.

The core diagnosis:
- **Strengths:** Robust zero-trust architecture, strict privacy masking ("Busy" blocks only), 100% test pass rate, and charming mascot assets.
- **Key UX Gaps:**
  1. *Container Fatigue:* Excessive use of boxed cards for every piece of content, leading to repetitive visual weight.
  2. *Missing Guided Tour System:* Users currently lack an intuitive, delightful walkthrough showing how two-person scheduling and privacy masking work.
  3. *Navigation & Motion Transitions:* Screen transitions are standard platform cuts rather than purposeful spatial movements.
  4. *Interaction Micro-Feedback:* Buttons and cards lack physical spring responsiveness and tactile depth.

---

## 2. Comprehensive UX Audit Matrix

| Area / Screen | Existing Problem | Why It Is a Problem | Proposed UX Improvement | Expected User Benefit | Implementation Complexity | Regression Risk |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Global UI: Card Architecture** | Every section (Partner overview, Time together, Schedules) is enclosed in identical bordered rectangle containers. | Causes cognitive monotony ("container fatigue"). The user cannot immediately distinguish hero information from secondary data. | Introduce a 4-tier Card System: 1. Hero Panels, 2. Insight Ribbons, 3. Event Timeline Tiles, 4. Action Cards. Replace unnecessary nested containers with clean whitespace and subtle dividers. | Immediate visual scanability; hierarchy guides the eye to partner status first. | Moderate | Low |
| **Today: Greeting & Partner Overview** | Partner status card is visually similar to event cards below it. | Fails the "Partner-First" design principle; user's attention is not immediately drawn to the partner's current state. | Redesign Partner Overview as an expressive Hero Card with partner avatar, voluntary status emoji badge, and "Up next" schedule preview. | Partner's availability is understood in < 2 seconds. | Low | Low |
| **Today: Shared Availability** | Displayed as a large standalone card that pushes schedule items down. | Takes up vertical space even when the schedule has only 1 free window. | Convert into a compact "Insight Ribbon" with a subtle sun/star icon, quick time range pill, and inline "Plan" action. | Keeps timeline visible above the fold while encouraging intentional time together. | Low | Low |
| **Calendar: Month & Day Views** | Hour slots in Day view have heavy rectangular boxes around every single hour. View switcher tabs are flat. | Creates visual clutter and looks like a spreadsheet rather than a calming relationship tool. | Inspired by modern schedule design (Image 1): clean date strip with rounded day cards, streamlined timeline slots with overlap warning banners. | Calmer, more intuitive planning experience across weeks and months. | Moderate | Low |
| **Onboarding & Walkthrough** | No interactive guide explaining the 4 destinations or privacy rules. | New users must guess what "Busy (Private)" means or where shared bucket lists live. | Implement "Miso's Little Guide" (Part 5): A spotlight guided-tour engine with comic dialogue speech bubbles pointing to real UI widgets. | Delighted, educated users who understand privacy boundaries from day 1. | High | Low (decoupled overlay) |
| **Motion & Transitions** | Screen transitions between tabs and detail sheets are abrupt. | The app feels static and lacks physical continuity. | Implement standardized motion tokens (`AppMotion`): shared-axis tab transitions, spring bottom-sheet entrances, and scale micro-feedback on buttons. | Tactile, fluid feel that reinforces brand maturity. | Moderate | Very Low |
| **Together Space: Bucket List** | Checking off an item only strikes through text without celebration. | Missing emotional reward for completing shared couple experiences. | Add celebrating Miso micro-reaction, confetti or toast badge, and celebratory completion sound/haptic. | Deepens emotional connection and shared joy. | Low | None |
| **Profile & Settings** | Settings lists are long and unsectioned. | Difficult to scan account, appearance, and pairing settings. | Group into distinct cards: 1. Couple Workspace, 2. Appearance (Light/Dark/System), 3. Notifications, 4. Privacy & Data. | Clean, functional settings hierarchy. | Low | None |
| **Accessibility & Text Scaling** | Fixed container heights risk clipping on large system font scales (e.g. 1.3x). | Users with visual accessibility needs may experience text truncation. | Enforce dynamic sizing, `Flexible`/`Expanded` wrappers, and minimum 48x48 touch targets. | Full WCAG AA compliance across text scale factors. | Moderate | Low |

---

## 3. Prioritized Implementation Roadmap

1. **Phase 1: UX Audit Documentation & Verification** (This document).
2. **Phase 2: Card & Design System Overhaul:**
   - Establish `CARD_SYSTEM.md` and `DESIGN_SYSTEM.md`.
   - Implement `HeroCard`, `InsightRibbon`, `ActionCard`, and refined `EventTimelineTile`.
3. **Phase 3: Screen Transitions & Motion Design:**
   - Establish `MOTION_GUIDELINES.md`.
   - Implement custom GoRouter transitions and modal bottom sheet springs.
4. **Phase 4: Miso's Little Guide (Guided Tour Engine):**
   - Establish `GUIDED_TOUR_SPECIFICATION.md`.
   - Build `GuidedTourController`, `ComicDialogueBubble`, `SpotlightTarget`, `TourProgressIndicator`.
   - Implement First-Run Tour and Contextual Feature Tips.
5. **Phase 5: Screen-by-Screen UX Engineering:**
   - Refine Today, Calendar, Together, Profile, and Auth screens.
6. **Phase 6: Micro-interactions & Multi-State Resilience:**
   - Skeletons, empty states, error recovery, offline badges.
7. **Phase 7: Accessibility, Quality & Git Deployment:**
   - Complete `ACCESSIBILITY_CHECKLIST.md` and `UX_IMPLEMENTATION_STATUS.md`.
   - Verify 100% test pass rate and push to `https://github.com/krushnasaruk/together.git`.
