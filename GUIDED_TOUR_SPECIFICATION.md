# Guided Tour Specification — Miso's Little Guide

**Engine Name:** Miso's Little Guide  
**Mascot Guide:** Miso the Cat 🐱  
**Visual Motif:** Comic & Manga-inspired speech bubbles, glowing spotlight cutouts, animated mascot gestures.

---

## 1. Architectural Overview

The guided-tour system is built as a completely decoupled overlay layer above the root navigator, ensuring that:
1. Normal screen widget trees do not have invasive tutorial state mixed into presentation logic.
2. Targets register themselves via `TourTarget` with unique string identifiers (`TourTargetId`).
3. Positions are calculated reactively via `RenderBox.localToGlobal`.
4. Tour completion flags are persisted in `SharedPreferences` without coupling to user account credentials.
5. Tours can be restarted anytime from the Profile / Help screen.

---

## 2. Directory Structure

```text
lib/core/onboarding/
  guided_tour_step.dart         // Tour step model (title, text, pose, target, pointer)
  guided_tour_registry.dart     // Target key registry mapping target IDs to GlobalKeys
  guided_tour_storage.dart      // SharedPreferences persistence for tour completion
  guided_tour_controller.dart   // Riverpod state notifier managing active step, next/back/skip
  guided_tour_overlay.dart      // Root overlay managing dimming, spotlight cutout & animations
  widgets/
    spotlight_target.dart       // CustomPainter drawing the darkened backdrop with hole cutout
    comic_dialogue_bubble.dart  // Comic speech bubble with speech tail arrow & border
    miso_guide_character.dart   // Animated Miso character positioning beside bubble
    tour_progress_indicator.dart// "Step 1 of 5" dot/counter indicator
    tour_controls.dart          // Previous, Next, Skip, and Finish action buttons
```

---

## 3. First-Run Tour Sequence

| Step # | Target Widget ID | Miso Pose | Dialogue Title | Dialogue Body | Speech Tail |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1** | None (Centered) | `MisoPose.wave` | "Hey there!" | "I'm Miso! Welcome to Together. Let me show you around your new shared space." | Bottom-right |
| **2** | `tour_nav_today` | `MisoPose.curious` | "Today: Your Daily Anchor" | "Here's your shared daily view. You can see your partner's activities, upcoming plans, and free windows." | Bottom pointing down |
| **3** | `tour_nav_calendar` | `MisoPose.relaxed` | "Shared Calendar" | "Need the bigger picture? Explore whole months, check overlapping commitments, and plan ahead." | Bottom pointing down |
| **4** | `tour_nav_together` | `MisoPose.message` | "Together Space" | "This is your relationship's sanctuary for date night ideas, anniversaries, and shared bucket lists!" | Bottom pointing down |
| **5** | `tour_nav_profile` | `MisoPose.reassuring`| "Profile & Privacy" | "Control pairing, notifications, and dark mode. Remember: private events always stay strictly confidential." | Bottom pointing down |
| **6** | None (Centered) | `MisoPose.celebrating`| "You're all set! ✨" | "That's the tour! Go ahead and create your first shared plan together." | None |

---

## 4. Spotlight Cutout Geometry

The overlay draws a full-screen semi-transparent backdrop (`Color(0x99000000)`) with an inverted rounded rectangle cutout around the target widget's bounding box plus 8pt padding. A soft pulsing primary-colored border (`Color(0xFF536B54)`) surrounds the target to draw user attention.
