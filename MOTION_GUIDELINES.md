# Motion Guidelines — Together

**Purpose:** Provide consistent, purposeful, and lightweight motion design that reinforces user mental models without creating distraction, lag, or motion sickness.

---

## 1. Motion Principles

1. **Purpose Over Decoration:** Every animation must answer a user need (e.g. spatial continuity, state confirmation, feedback).
2. **Snappy & Light:** Primary interface transitions should never exceed 250–300ms. Primary user actions must never be blocked by ongoing animations.
3. **Reduced Motion Respect:** When the system reduced-motion accessibility preference is active, replace spatial slides with instant cuts or soft fades.

---

## 2. Motion Tokens & Easing Curves

Defined in `AppMotion`:

| Token | Duration | Curve | Usage |
| :--- | :--- | :--- | :--- |
| `AppMotion.fast` | 150ms | `Curves.easeOut` | Button press scale, checkbox toggles |
| `AppMotion.normal` | 250ms | `Curves.easeInOutCubic` | Screen route transitions, modal sheet entrances |
| `AppMotion.slow` | 400ms | `Curves.easeOutBack` | Mascot micro-bounce on tap, celebration reactions |
| `AppMotion.relaxed`| 600ms | `Curves.easeInOut` | Shimmer gradient sliding, breathing animations |

---

## 3. Screen Transition Archetypes

### A. Persistent Bottom Navigation Tabs (Today ↔ Calendar ↔ Together ↔ Profile)
- **Type:** Gentle fade-through with subtle 4pt horizontal slide.
- **Duration:** 200ms.
- **State Preservation:** Managed by GoRouter's `StatefulShellRoute.indexedStack`.

### B. Secondary Sub-Routes (Welcome → Login / Register / Forgot Password)
- **Type:** Forward horizontal slide & fade from right.
- **Duration:** 250ms.
- **Reverse:** Slide & fade back to left on pop.

### C. Modal Bottom Sheets (Event Form, Event Details, Pairing, Quick Status)
- **Type:** Vertical slide up with cubic deceleration curve.
- **Duration:** 280ms.
- **Dismissal:** Interactive drag-to-dismiss with velocity tracking.

### D. Mascot's Guided Tour Spotlight
- **Type:** Smooth spotlight tween with spring scale bubble appearance.
- **Duration:** 350ms.
