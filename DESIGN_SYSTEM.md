# Design System — Together

**Product:** Together ("Two lives. One shared space.")  
**Brand Companion:** Miso the Cat 🐱  
**Design Philosophy:** Playful, expressive, warm, clean, hand-drawn, friendly and modern. Delightful without distraction.

---

## 1. Color Palette Tokens

### Light Theme (Warm Cream & Muted Sage)
| Token | Hex Value | Semantic Usage |
| :--- | :--- | :--- |
| `background` | `#F8F6F0` | Warm cream canvas background |
| `surface` | `#FFFFFF` | Primary card and sheet surface |
| `surfaceSecondary` | `#F2ECE1` | Secondary subtle background / chip fills |
| `surfaceElevated` | `#FCFAF6` | Slightly elevated card surface |
| `primary` | `#A8B99F` | Muted Sage Green (Brand Primary & Partner A accent) |
| `primaryDark` | `#536B54` | Primary button fill and high-contrast text |
| `secondary` | `#E8B9B0` | Subdued Rose (Partner B accent & heart highlights) |
| `accentBlue` | `#C4D8DF` | Slate / Dusty Blue (Together shared plans accent) |
| `sand` | `#E8DDCA` | Warm neutral container accent |
| `textPrimary` | `#343A36` | Charcoal heading and primary body text (contrast ratio > 7:1) |
| `textSecondary` | `#85877F` | Accessible neutral subtitle text (contrast ratio > 4.5:1) |
| `divider` | `#E8E5DC` | Subtle line dividers and sheet handles |
| `error` | `#D96B6B` | Accessible muted red for cancellations & delete actions |
| `success` | `#609966` | Accessible muted green for confirmations & completions |

### Dark Theme (Warm Charcoal & Muted Sage)
| Token | Hex Value | Semantic Usage |
| :--- | :--- | :--- |
| `darkBackground` | `#1F2220` | Cozy warm charcoal canvas |
| `darkSurface` | `#2A2E2B` | Slightly lighter charcoal card surface |
| `darkPrimary` | `#8EA885` | Muted sage in dark mode |
| `darkSecondary` | `#D99B90` | Subdued blush in dark mode |
| `darkTextPrimary` | `#F0EFEA` | Soft warm white text |
| `darkTextSecondary` | `#A5A9A4` | Accessible muted gray subtitle text |
| `darkDivider` | `#3A3F3B` | Dark mode borders and dividers |

---

## 2. Typography Hierarchy

Together pairs **Nunito Sans** for expressive, friendly headings with **DM Sans** for legible body text.

| Text Style | Font Family | Size | Weight | Tracking | Line Height | Usage |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `displayLarge` | Nunito Sans | 32pt | 800 | -0.6 | 1.25 | Onboarding hero titles, anniversary day counts |
| `displayMedium` | Nunito Sans | 26pt | 700 | -0.4 | 1.28 | Screen hero headers |
| `displaySmall` | Nunito Sans | 22pt | 700 | -0.3 | 1.30 | Section greetings, modal headers |
| `headlineMedium` | Nunito Sans | 18pt | 700 | -0.2 | 1.35 | Section headers, card titles |
| `titleLarge` | DM Sans | 16pt | 600 | -0.1 | 1.40 | Event titles, user display names |
| `titleMedium` | DM Sans | 14pt | 500 | 0.0 | 1.42 | Card subheadings, list item titles |
| `bodyLarge` | DM Sans | 15pt | 400 | 0.0 | 1.50 | Primary body text, descriptions |
| `bodyMedium` | DM Sans | 14pt | 400 | 0.0 | 1.45 | Standard body text, dialog messages |
| `bodySmall` | DM Sans | 12pt | 400 | 0.1 | 1.40 | Timestamps, secondary labels |
| `scheduleTime` | DM Sans (Tabular) | 12-14pt | 600 | -0.1 | 1.30 | Clock times with `FontFeature.tabularFigures()` |

---

## 3. Spatial System & Shape Tokens

- **Grid Base:** 4pt grid system (`space4`, `space8`, `space12`, `space16`, `space20`, `space24`, `space28`, `space32`, `space40`, `space48`).
- **Corner Radii:**
  - `radiusXs`: 6pt (tags, small badges)
  - `radiusSm`: 10pt (chips, small buttons)
  - `radiusMd`: 16pt (standard cards, event tiles, text fields)
  - `radiusLg`: 20pt (hero cards, dialogs, floating action sheets)
  - `radiusXl`: 28pt (modal bottom sheet top corners)
  - `radiusFull`: 999pt (pills, avatars, drag handles)
- **Shadows:** Restrained, natural light diffusion:
  - `softShadow`: `BoxShadow(color: Color(0x0A000000), offset: Offset(0, 2), blurRadius: 8)`
  - `cardShadow`: `BoxShadow(color: Color(0x0D000000), offset: Offset(0, 4), blurRadius: 12)`
