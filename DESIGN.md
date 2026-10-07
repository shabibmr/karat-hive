# Karat Hive — Design System & Visual Specification (DESIGN.md)

## 1. Visual Identity & Brand Philosophy
**Karat Hive** is a luxury gold trading and bespoke jewellery platform. The visual language embodies **Dark Luxury / Refined Opulence** for splash & marketing reveals, transitioning gracefully into an editorial ivory & champagne gold atmosphere for core trading and catalog views.

> **Core Philosophy**: Luxury through restraint, geometric precision, and luminous depth — not excessive decoration.

---

## 2. Core Color Palette & Design Tokens

| Token | Hex / Value | Role / Usage |
|---|---|---|
| **Deep Ink** | `#1C1B1A` | Canvas background for splash screens, dark hero stages, and high-contrast surfaces. |
| **Karat Gold** | `#C8A046` / `0xFFC8A046` | Primary accent: geometric lines, specular glints, active status indicators, and hairline loaders. |
| **Deep Antique Gold** | `#8A6A1F` / `0xFF8A6A1F` | Secondary accent: facet shadows, borders, ambient depth, and subtle bevels. |
| **Ivory White** | `#FDFBF7` / `0xFFFDFBF7` | Typography (headlines, wordmark, body copy on dark surfaces) and light surface backgrounds. |
| **Brand Motif Accent** | `#E11D74` / `#FF2E93` | Reserved exclusively as a subtle vibrant pink accent on the inner logo motif. |
| **Radial Gold Glow** | `radial-gradient(ellipse at center, rgba(200,160,70,0.12) 0%, #1C1B1A 70%)` | Ambient light blooming behind the central lockup. |
| **Hexagonal Dust** | `rgba(200, 160, 70, 0.05)` | Micro-ambient floating dust particles drifting subtly in the background. |

---

## 3. Typography Hierarchy

| Role | Font Family | Size | Weight | Tracking / Letter Spacing | Color |
|---|---|---|---|---|---|
| **Brand Wordmark** | `Cormorant Garamond` | 24px - 32px | SemiBold (600) | `+3.2px` to `+4.0px` | Ivory White (`#FDFBF7`) |
| **Sub-tagline** | `DM Sans` | 12px (Uppercase) | Medium (500) | `+2.4px` (0.20em) | Ivory White @ 70% opacity |
| **Status / Microcopy** | `DM Sans` | 11px - 13px | Regular / Medium (400-500) | Normal | Ivory White / Karat Gold |

---

## 4. Splash Screen Architecture & Motion Choreography

### 4.1 Page Layout
1. **Background Canvas**:
   - Fullscreen edge-to-edge Deep Ink (`#1C1B1A`).
   - Center-focused radial gold glow (`0.12` alpha gold diffusing to ink at 70% radius).
   - Micro-ambient hexagonal particle dust drifting upward with subtle oscillation.

2. **Central Hero Stage**:
   - Centered at ~40% vertical height.
   - **Hexagonal Hive Emblem**: Geometric facets drawn with razor-sharp gold hairline strokes (`#C8A046`), inner diamond/hex facets, subtle pink accent motif, and a 45° specular light sweep glint.
   - **Logotype ("KARAT HIVE")**: 20px below emblem in Cormorant Garamond serif with tracked uppercase letters.
   - **Sub-tagline ("THE MODERN GOLD STANDARD")**: 10px below logotype in DM Sans uppercase Ivory White (70% opacity).

3. **Footer Status / Loader**:
   - Minimalist 32px gold hairline loader (pill-shaped with 999px radius) positioned 60px from the bottom safe-area edge.
   - Breathing pulse / progress shimmer.

### 4.2 Keyframe Choreography Timeline

| Timestamp | Element | Motion / Property | Curve / Easing |
|---|---|---|---|
| **0.00s – 0.65s** | Hive / Hexagon Emblem | Stroke draw-in + Scale 0.85 → 1.0 + Opacity 0% → 100% | `cubic-bezier(0.2, 0.7, 0.2, 1.0)` |
| **0.65s – 1.10s** | Emblem Surface | Specular gold sheen / glint (`#FDFBF7` / `#C8A046`) sweep across at 45° | `easeOutQuad` |
| **0.80s – 1.40s** | "Karat Hive" Wordmark | Staggered Y-offset +16px → 0px, Opacity 0% → 100%, letter-spacing expansion | `cubic-bezier(0.16, 1.0, 0.3, 1.0)` |
| **1.40s – 2.20s** | Entire Lockup & Tagline | Tagline fades in (0% → 70%); ambient pulse / micro-float (scale 1.00 ↔ 1.018), soft glow breathing | `easeInOutSine` |
| **2.20s – 2.50s** | Exit Transition / Main Handoff | Scale 1.00 → 1.05 and gentle dissolution into the authenticated/guest shell | `easeInCubic` |

---

## 5. Implementation Strategy in Flutter

- **Pure Flutter Vector Rendering**: Custom-crafted `CustomPainter` rendering high-precision geometric hexagonal facets with specular sweep shaders and particle systems.
- **Zero Heavy Bundle Overhead**: Runs at 60/120 FPS natively without requiring external heavy asset parsing, fully responsive across all device densities and aspect ratios.
- **Safe Area Aware**: Automatically respects status bars and device notches.
