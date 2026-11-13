# Card & Content Design System — Together

**Purpose:** Eliminate "container fatigue" and establish deliberate, purposeful visual hierarchy across mobile screens.

---

## 1. Principles of Card Design in Together

1. **Containers Must Earn Their Existence:** Content should only be wrapped in a card if it represents an independent semantic unit that benefits from visual isolation.
2. **Whitespace Over Boxes:** Prefer 16–24pt whitespace and subtle 1pt `#E8E5DC` dividers to establish hierarchy rather than nesting rounded boxes inside rounded boxes.
3. **Restrained Shadows:** Never use heavy drop shadows. Rely on 1pt subtle borders and gentle 4% opacity ambient diffusion.
4. **Semantic Color Usage:** Use partner colors (Sage `#536B54`, Rose `#A45D5D`, Blue `#556F7A`) exclusively as intentional accents (vertical bars, pill badges), never as full loud card backgrounds.

---

## 2. Card Category Taxonomy

### Tier 1: Hero Panels (`HeroPanel`)
- **Usage:** Screen-defining primary cards (e.g. Partner Overview on Today, Milestone Anniversary Banner on Together).
- **Visuals:** 16–20pt padding, `radiusLg` (20pt), subtle dual-color gradient wash (`surface` to subtle partner tint), 1pt border, `softShadow`.
- **Content:** Partner avatar, status pill, next event preview, primary quick action.

### Tier 2: Compact Insight Ribbons (`InsightRibbon`)
- **Usage:** Contextual suggestions that should not push daily schedules below the fold (e.g. Potential Time Together, Daily Miso greeting).
- **Visuals:** 10–12pt vertical padding, `radiusMd` (16pt), soft tint fill (`#F2F6F1` / `#28342B` in dark mode), inline icon, tabular time badge, compact text button.

### Tier 3: Event Timeline Tiles (`EventTimelineTile`)
- **Usage:** Chronological list items across Today and Calendar screens.
- **Visuals:** 48pt height profile, 4pt vertical partner accent bar, tabular clock numerals (`FontFeature.tabularFigures()`), category icon badge, strikethrough for cancelled events, privacy lock badge.

### Tier 4: Interactive Action Cards (`ActionCard`)
- **Usage:** Settings triggers, couple pairing cards, date night planners.
- **Visuals:** Flat surface, circular icon container, title + subtitle, chevron navigation indicator or switch toggle.

### Tier 5: Mascot Message Cards (`MascotMessage`)
- **Usage:** Warm Miso greeting, onboarding dialogue bubbles, contextual tips.
- **Visuals:** Organic rounded bubble, Miso character illustration, speech pointer, dismiss button.

