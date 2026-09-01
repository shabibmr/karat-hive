# Karat Hive — UI Design Context
## Luxury Mobile Marketplace Design System & Motion Specification

**Product:** Karat Hive  
**Platform:** Flutter — iOS + Android  
**Application model:** One dual-mode mobile application: Customer mode + Vendor mode  
**Primary market:** UAE / AED  
**Design direction:** Luxury Art Deco + modern Material 3 discipline  
**Status:** UI design context for implementation and AI-assisted screen generation  
**Version:** 1.0 — 10 August 2026

---

## 1. Purpose

This document is the authoritative **visual and interaction context** for designing Karat Hive.

Every new screen, component, dialog, animation, empty state, loading state and navigation transition must feel as though it belongs to the same product.

The design must combine:

- premium jewellery aesthetics,
- dark sapphire surfaces,
- restrained metallic gold,
- warm cream typography,
- geometric Art Deco details,
- generous visual hierarchy,
- modern Material 3 usability,
- subtle physical-material motion,
- fast mobile interaction,
- accessibility,
- and performance suitable for ordinary Android and iOS devices.

The UI must **not** look like a generic gold-themed application.

It should feel like a **premium digital jewellery salon**.

---

# 2. Product Experience

Karat Hive is not a conventional catalogue-first e-commerce application.

The central interaction is:

```text
Customer creates Request
        ↓
Karat Hive matches eligible Vendors
        ↓
Vendors submit Offers
        ↓
Customer compares Offers
        ↓
Customer accepts one Offer
        ↓
Identities are revealed
        ↓
WhatsApp handoff
        ↓
Both parties may review each other
```

The UI must therefore communicate:

1. **Trust**
2. **Exclusivity**
3. **Value**
4. **Competition between verified vendors**
5. **Privacy before acceptance**
6. **Clarity after acceptance**
7. **Luxury without unnecessary decoration**

The most important product principle is:

> **The interface should make gold feel valuable without making the user work to understand the interface.**

---

# 3. Design Personality

### Desired

- Elegant
- Dark
- Warm
- Refined
- Cinematic
- Editorial
- Confident
- Tactile
- Quietly luxurious
- Premium but approachable

### Avoid

- Excessive gradients
- Cheap yellow gold
- Excessive glassmorphism
- Neon effects
- Generic banking-app appearance
- Excessive rounded cards
- Heavy shadows everywhere
- Flashing animations
- Mass-market discount styling
- Red urgency banners
- Dense ornamental borders around every component
- Overuse of gold text

Luxury should come from **composition, spacing, typography, material contrast and motion**, not from decorating every pixel.

---

# 4. Global Visual Language

## 4.1 Core palette

Use semantic design tokens rather than hardcoded colors.

### Primitive tokens

| Token | Value | Usage |
|---|---|---|
| `sapphire900` | `#0A1128` | Primary dark canvas |
| `sapphire800` | `#111A36` | Elevated dark surfaces |
| `sapphire700` | `#182344` | Secondary surfaces |
| `gold400` | `#D4AF37` | Primary gold |
| `gold300` | `#E3C65A` | Active gold |
| `gold200` | `#F1E5AC` | Highlight / reflected gold |
| `gold100` | `#FFF4C7` | Specular highlight |
| `cream100` | `#FDFBF7` | Primary light text |
| `cream200` | `#EDE8DC` | Secondary text |
| `mutedGold` | `#A58A2A` | Disabled / low emphasis gold |
| `success` | `#5FAF7B` | Positive status |
| `warning` | `#D9A441` | Warning |
| `error` | `#C96A6A` | Error |
| `info` | `#6D9BCB` | Informational |

### Semantic tokens

```text
background.primary       = sapphire900
background.elevated      = sapphire800
background.surface       = sapphire700

text.primary             = cream100
text.secondary           = cream200
text.muted               = mutedGold

accent.primary           = gold400
accent.highlight         = gold200
accent.specular          = gold100

border.subtle             = gold400 @ 18%
border.standard           = gold400 @ 35%
border.strong             = gold200 @ 65%
```

---

# 5. Gold Must Look Metallic

Do not treat gold as a flat yellow.

Gold surfaces should normally use a restrained metallic gradient:

```text
dark gold
    ↓
gold
    ↓
bright gold
    ↓
pale reflected gold
    ↓
gold
```

Example:

```text
LinearGradient(
  colors: [
    #8F731B,
    #D4AF37,
    #F1E5AC,
    #D4AF37,
    #9B7B20,
  ]
)
```

The gradient must be subtle.

Do not make buttons look like chrome.

---

# 6. Signature Gold-Light Animation

## 6.1 Core concept

Karat Hive should occasionally appear to be illuminated by a real light source.

A **soft specular light sweep** should travel across gold surfaces at random intervals.

This is a signature brand effect.

It should feel like:

> light from a jewellery showroom briefly catching a polished gold surface.

It must **never** feel like a loading animation.

---

## 6.2 Random interval behaviour

The effect must not run continuously.

Use randomized intervals so that the interface feels alive.

Recommended:

```text
minimum delay: 8 seconds
maximum delay: 22 seconds
```

For major hero surfaces:

```text
minimum delay: 12 seconds
maximum delay: 30 seconds
```

Suggested randomization:

```dart
Duration randomLightDelay(Random random) {
  final seconds = 8 + random.nextInt(15);
  return Duration(seconds: seconds);
}
```

Never synchronize every component.

Each eligible component should have its own timing seed.

---

## 6.3 Light sweep

The light should move across the gold surface:

```text
      ///////
     ///////
    ///////
   ///////
  ///////
```

Recommended duration:

```text
900ms – 1500ms
```

Recommended curve:

```text
Curves.easeInOutCubic
```

For premium components, a custom curve may be used.

---

## 6.4 Appearance

The moving highlight should be:

- narrow,
- soft,
- slightly warm,
- semi-transparent,
- blurred,
- directional,
- never pure white.

Example visual treatment:

```text
Gradient(
  colors: [
    transparent,
    gold100 @ 0.0,
    cream100 @ 0.22,
    gold100 @ 0.0,
    transparent,
  ]
)
```

The highlight should usually be around:

```text
8% – 18% of component width
```

---

## 6.5 Flutter implementation concept

Create a reusable component:

```dart
class GoldLightSweep extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final Duration minDelay;
  final Duration maxDelay;

  const GoldLightSweep({
    super.key,
    required this.child,
    this.enabled = true,
    this.minDelay = const Duration(seconds: 8),
    this.maxDelay = const Duration(seconds: 22),
  });
}
```

Internally:

1. wait for a random delay,
2. animate a gradient/shimmer,
3. reset,
4. generate another random delay,
5. repeat.

The animation should be disposed correctly when the widget leaves the tree.

Do not create an independent perpetual ticker for every tiny gold icon.

---

# 7. Where Gold-Light Animation Is Allowed

### High priority

- Home hero
- Primary CTA buttons
- Premium request-type cards
- Gold rate card
- Offer acceptance CTA
- Connection reveal card
- Vendor subscription cards
- Important empty-state illustrations

### Medium priority

- Gold borders
- Selected navigation item
- Profile header
- Offer cards
- Request cards

### Avoid

- Every icon
- Every list row
- Text labels
- Error states
- Forms
- Every button simultaneously
- High-frequency vendor feed rows

The user should notice the effect subconsciously rather than think:

> "Why is everything moving?"

---

# 8. Reduced Motion

If the platform reports reduced-motion preference:

```text
Disable:
- gold light sweep
- floating decorative particles
- large scale transitions
- parallax
- continuous 3D rotation

Keep:
- opacity changes
- state changes
- progress indication
- essential navigation transitions
```

Accessibility takes priority over visual spectacle.

---

# 9. Material 3 Foundation

Karat Hive should use **Material 3 as the behavioural foundation**, but not its default visual appearance.

Material 3 provides:

- accessibility semantics,
- buttons,
- navigation,
- dialogs,
- bottom sheets,
- text fields,
- focus handling,
- adaptive layouts,
- ripple/interaction behaviour.

The Karat Hive theme should replace the default visual language.

Do not blindly use default Material 3 cards, filled buttons and color schemes.

---

# 10. Shape Language

The application uses a mixture of:

### Primary shape

Soft editorial rectangle:

```text
12–18 px radius
```

### Secondary shape

Art Deco geometric framing:

```text
small corner cuts
thin gold lines
diamond accents
symmetrical geometry
```

### Avoid

```text
30–40 px pill-shaped everything
```

Pills are reserved for:

- statuses,
- filters,
- compact tags,
- request type badges.

---

# 11. Borders

Gold borders should be used sparingly.

Recommended:

```text
1 px gold @ 20–35%
```

For hero / premium sections:

```text
1 px gold @ 45–65%
```

Art Deco framing may use:

```text
outer border
+
inner hairline
+
small geometric corner motif
```

Never surround an entire screen with a decorative border.

---

# 12. Typography

Typography should feel editorial and luxurious.

Use a combination of:

### Display font

A refined geometric or high-contrast serif for:

- hero headings,
- major section titles,
- premium editorial statements.

### UI font

A highly legible modern sans-serif for:

- forms,
- prices,
- request details,
- navigation,
- notifications,
- vendor feeds.

Recommended hierarchy:

```text
Display XL
Display L
Headline
Title
Body
Label
Caption
```

Never use decorative typography for data-heavy Vendor screens.

---

# 13. Typography Rules

### Hero

Large:

```text
SHINE BRIGHTER
```

Use:

- uppercase,
- generous tracking,
- strong contrast,
- short lines.

### Prices

Prices should be highly legible.

Example:

```text
AED 14,850
```

Use cream or bright gold depending on background.

### Gold rate

Example:

```text
24K GOLD
AED 512.40 / g
```

The numeric rate is more important than the label.

### Status text

Never communicate state through color alone.

Example:

```text
● 3 Offers
Expires in 12h 24m
```

---

# 14. Photography

Photography should feel like luxury jewellery editorial photography.

Preferred characteristics:

- dark backgrounds,
- controlled studio lighting,
- warm highlights,
- realistic skin,
- high-resolution jewellery,
- macro details,
- shallow depth of field,
- restrained compositions.

Avoid:

- generic stock photos,
- oversaturated gold,
- unrealistic jewellery,
- bright white e-commerce backgrounds.

---

# 15. Imagery and Gold Interaction

Jewellery imagery should occasionally contain subtle light movement.

For static images:

- do not modify the actual jewellery image,
- use an overlay highlight,
- keep the sweep extremely subtle.

For high-end hero media:

```text
Image
+
soft radial glow
+
gold reflection
+
very subtle parallax
```

---

# 16. App Shell

The mobile application is one binary with two modes.

```text
Karat Hive App
│
├── Customer Mode
│
└── Vendor Mode
```

The visual identity remains shared.

Navigation structure can differ because the usage patterns differ.

---

# 17. Customer Experience

Customer behaviour is:

```text
low frequency
high intent
comparison driven
emotionally oriented
```

Customer UI should therefore prioritize:

- clarity,
- large touch targets,
- visual confidence,
- request creation,
- offer comparison,
- status visibility.

---

# 18. Customer Home

The Customer Home is the most important consumer screen.

### Recommended structure

```text
┌──────────────────────────────┐
│ KARAT HIVE          profile  │
│                              │
│ SHINE BRIGHTER               │
│ Your gold. Your choice.      │
│                              │
│ [ Create a Request ]         │
│                              │
├──────────────────────────────┤
│ What are you looking for?    │
│                              │
│ ┌────────┐ ┌────────┐        │
│ │ Find   │ │ Sell   │        │
│ │Ornament│ │Old Gold│        │
│ └────────┘ └────────┘        │
│                              │
│ ┌────────┐ ┌────────┐        │
│ │ Coins  │ │Bullion │        │
│ └────────┘ └────────┘        │
│                              │
├──────────────────────────────┤
│ My Requests                  │
│                              │
│ 2 active                     │
│ 5 offers waiting             │
│                              │
├──────────────────────────────┤
│ Gold Rate                    │
│ 24K  AED 512.40/g            │
│ 22K  AED 469.53/g            │
│                              │
└──────────────────────────────┘
```

The actual composition should remain more editorial and visually spacious than this wireframe.

---

# 19. Customer Home Hero

The hero should establish the brand immediately.

### Visual

- deep sapphire background,
- subtle Art Deco frame,
- jewellery / model photography,
- warm gold edge lighting,
- large editorial heading,
- restrained gold CTA.

Example:

```text
SHINE BRIGHTER

Find the right gold.
Compare verified offers.

[ FIND YOUR GOLD ]
```

A soft gold-light sweep may cross the border or CTA occasionally.

---

# 20. Customer Request Type Cards

There are four primary actions:

1. Find an Ornament
2. Sell Old Gold
3. Buy / Sell Gold Coins
4. Buy / Sell Gold Bullion

Cards should have:

- icon or jewellery illustration,
- title,
- one-line explanation,
- subtle gold outline,
- sapphire surface,
- selected-state gold glow.

On tap:

```text
scale: 1.00 → 1.03 → 1.00
duration: ~350ms
```

Use a slight overshoot, not a bounce-heavy animation.

---

# 21. Customer Request Creation

Request creation is the core conversion flow.

The user should be able to complete a returning-user Request quickly.

Design principles:

- one decision per step,
- clear progress,
- large controls,
- contextual gold-rate information,
- inline validation,
- image-first interaction for jewellery,
- save-as-draft support.

Never present a huge form on one screen.

---

# 22. Request Types

## Find An Ornament

Capture:

- reference image,
- ornament type,
- approximate weight,
- purity,
- gemstone information,
- budget,
- notes.

## Sell Old Gold

Capture:

- actual item images,
- weight,
- purity,
- condition,
- invoice/certificate information,
- notes.

## Gold Coins

Capture:

- Buy/Sell,
- denomination,
- quantity,
- purity,
- mint/brand,
- packaging condition.

## Gold Bullion

Capture:

- Buy/Sell,
- bar weight,
- quantity,
- purity,
- refiner/brand,
- certificate information.

Display the indicative value and enforce the configured minimum.

---

# 23. Gold Rate Card

Gold rates are a core trust element.

Example:

```text
LIVE REFERENCE RATE

24K      AED 512.40 / g
22K      AED 469.53 / g
21K      AED 448.35 / g
18K      AED 384.30 / g

Updated 3 min ago
Indicative only
```

The gold-rate card may have:

- metallic top border,
- subtle glow,
- tiny animated highlight,
- timestamp,
- stale-state treatment.

Never imply that the displayed rate is a guaranteed offer.

---

# 24. Request Detail

Show:

- Request type,
- status,
- reference,
- images,
- weight,
- purity,
- budget,
- indicative value,
- region,
- notes,
- Offer count,
- expiry countdown.

Primary action:

```text
VIEW OFFERS
```

Secondary:

```text
Edit
Cancel
```

Only allowed actions should appear for the current state.

---

# 25. Offers UI

Offers are the primary decision interface.

Each Offer Card should show:

```text
Verified Jeweller
Dubai

AED 14,850
★★★★☆ 4.6
128 connections

Making charges
AED 450

Ready
Within 2 days

Expires in 9h 42m

[ View Offer ]
```

Do not reveal Vendor identity before acceptance.

---

# 26. Offer Comparison

Comparison is a high-value screen.

The UI should make differences obvious.

Recommended:

```text
                 OFFER A     OFFER B     OFFER C

PRICE            AED 14,850  AED 15,100  AED 14,980
MAKING CHARGES   AED 450     AED 300     AED 400
RATING           4.6         4.8         4.4
READY            2 days      1 day       3 days
```

Highlight the best value with a restrained gold marker.

Do not use large green/red competition colours.

---

# 27. Acceptance

Accepting an Offer is irreversible.

The confirmation screen must visually communicate:

```text
YOU'RE CONNECTING

Accepting this offer will reveal
your identity and the Vendor's
identity to each other.

This action cannot be undone.

[ MARK AS INTERESTED ]
```

Use a calm premium dialog.

Do not use an alarming red warning aesthetic.

---

# 28. Identity Reveal Animation

This is one of the signature moments of the application.

Before acceptance:

```text
Verified Jeweller
Dubai
★★★★☆
```

After acceptance:

```text
Al Noor Jewellery
Ahmed
+971 XX XXX XXXX
Dubai
```

Transition:

1. Offer card settles.
2. Gold line expands horizontally.
3. Masked identity dissolves.
4. Revealed identity fades in.
5. Gold highlight passes across the card.
6. Haptic feedback occurs once.
7. Talk button becomes available.

Recommended total duration:

```text
700–1000ms
```

This animation must communicate **trust transition**, not celebration.

---

# 29. Connection Screen

After acceptance, the connection becomes the bridge to the real-world transaction.

Display:

- Vendor/customer identity,
- accepted Offer,
- Request reference,
- agreed terms,
- contact actions,
- WhatsApp Talk button,
- Call button where applicable,
- close connection,
- review action.

Primary CTA:

```text
TALK ON WHATSAPP
```

Use WhatsApp green only for the actual WhatsApp action if needed; do not recolor the entire screen green.

---

# 30. Customer Navigation

Customer navigation should prioritize:

```text
Home
Requests
Connections
Notifications
Profile
```

Do not copy a conventional e-commerce:

```text
Home / Shop / Cart / Wishlist / Account
```

The product is request-driven, not catalogue-driven.

---

# 31. Vendor Experience

Vendor behaviour:

```text
high frequency
task oriented
time sensitive
information dense
competitive
```

Vendor screens must be denser than Customer screens.

Luxury should remain in:

- typography,
- gold accents,
- hierarchy,
- surface treatment,

not in excessive whitespace.

---

# 32. Vendor Dashboard

The Vendor dashboard should immediately answer:

```text
What needs my attention?
```

Primary metrics:

```text
New Requests
Pending Offers
Active Connections
```

Example:

```text
GOOD EVENING, AL NOOR

Gold Reference
24K  AED 512.40/g

┌──────────────────────┐
│ 12                   │
│ NEW REQUESTS         │
│ View opportunities → │
└──────────────────────┘

┌──────────────────────┐
│ 4                    │
│ PENDING OFFERS       │
│ 2 expire today       │
└──────────────────────┘

┌──────────────────────┐
│ 18                   │
│ ACTIVE CONNECTIONS   │
└──────────────────────┘
```

Counters can animate subtly when changed.

---

# 33. Vendor Request Feed

The feed is a working tool.

Prioritize:

- scanning,
- filtering,
- sorting,
- rapid decision making.

Each row should expose:

```text
Request type
Buy/Sell
Weight / quantity
Purity
Budget
Region
Offer count
Time remaining
```

Primary flow:

```text
Feed
 ↓
Request
 ↓
Submit Offer
```

No more than two taps from the feed to Submit Offer.

---

# 34. Vendor Identity Masking

Before acceptance, Vendor sees:

```text
Customer
Dubai
3 previous connections
```

Never show:

- customer name,
- phone,
- email,
- exact address.

The UI should make masking feel intentional.

Example:

```text
PRIVATE CUSTOMER

Dubai
Verified request
3 previous connections
```

Use a subtle shield/lock motif.

---

# 35. Vendor Offer Creation

Offer entry should feel like a professional quotation tool.

Fields:

- offered price,
- making charges,
- rate per gram,
- readiness/delivery timeframe,
- warranty/buy-back terms,
- validity,
- images,
- note.

Show a live summary:

```text
YOUR OFFER

AED 14,850
Valid for 24 hours

Customer sees:
Price
Terms
Readiness
Rating
```

Never reveal competitor prices.

---

# 36. Vendor Subscription

Subscriptions are sold independently per Request type.

Design as premium service tiers rather than generic app purchases.

Example:

```text
REQUEST TYPES

Find An Ornament
ACTIVE

Sell Old Gold
ACTIVE

Gold Coins
NOT ACTIVE
[ SUBSCRIBE ]

Gold Bullion
NOT ACTIVE
[ SUBSCRIBE ]
```

Avoid aggressive sales styling.

---

# 37. Vendor Connections

Connection cards become less anonymous after acceptance.

Show:

- Customer identity,
- Request reference,
- accepted price,
- connection date,
- contact status.

Use:

```text
CONTACT NOT STARTED
```

as a subtle attention indicator.

---

# 38. Notifications

Notifications are important because Requests and Offers are asynchronous.

Notification categories:

### Customer

- New Offer
- Offer revised
- Offer withdrawn
- Request expiring
- Request expired
- Connection created
- Review reminder
- Announcement

### Vendor

- New matched Request
- Offer accepted
- Offer rejected
- Offer expiring
- Request cancelled
- Verification update
- Review received
- KYC expiry
- Announcement

Use gold for important unread indicators.

---

# 39. Notification Animation

New Offer:

```text
notification badge
↓
soft gold pulse
↓
settle
```

Do not continuously pulse.

One pulse is enough.

---

# 40. Status System

Use a consistent status language.

| State | Visual |
|---|---|
| Draft | muted gold / grey |
| Published | gold |
| Offers received | bright gold |
| Accepted | cream + gold |
| Closed | muted cream |
| Expired | muted |
| Cancelled | muted |
| Rejected | muted |
| Pending verification | amber |
| Active vendor | gold + small verification mark |
| Suspended | muted red |
| Error | restrained red |

Status must always include text.

---

# 41. Empty States

Empty states should feel editorial, not like technical errors.

Example:

```text
NO OFFERS YET

Your request is visible to
verified jewellers in your region.

We’ll let you know when
someone responds.

[ VIEW REQUEST ]
```

Use a subtle jewellery line illustration.

A small gold-light sweep may occur once after the empty state appears.

---

# 42. Loading States

Avoid generic spinning indicators where possible.

Use:

- skeleton cards,
- soft opacity transitions,
- restrained gold progress lines.

For gold-related loading:

```text
thin gold line
moving slowly
```

Do not use a bright spinning gold ring.

---

# 43. Pull to Refresh

Customer:

- soft gold ripple,
- minimal refresh indicator.

Vendor:

- faster, more functional refresh.

Never make refresh animation decorative enough to slow the user.

---

# 44. Navigation Transitions

Navigation should feel smooth and physical.

Recommended:

### Push

```text
fade + slight upward translation
200–300ms
```

### Modal

```text
fade background
sheet rises
250–350ms
```

### Major luxury transition

```text
fade
+
gold line reveal
+
content transition
```

Use major cinematic transitions only for important moments.

---

# 45. Micro-Interaction Principles

Every animation must have one of three purposes:

### 1. Feedback

The system confirms an action.

### 2. Orientation

The system explains where content came from or where it went.

### 3. Delight

The system creates a subtle luxury moment.

If an animation serves none of these purposes, remove it.

---

# 46. Animation Timing Tokens

```text
motion.instant       = 100ms
motion.fast          = 180ms
motion.standard      = 280ms
motion.emphasized    = 420ms
motion.luxury        = 700ms
motion.goldSweep     = 1100ms
motion.reveal        = 900ms
```

Do not use 1-second animations for ordinary buttons.

---

# 47. Animation Curves

Preferred:

```text
easeOut
easeInOut
easeInOutCubic
```

For tactile selection:

```text
cubic-bezier-like overshoot
```

Avoid:

```text
linear
large elastic bounce
cartoon bounce
```

Karat Hive should feel physically refined.

---

# 48. Haptics

Use haptic feedback selectively.

### Light haptic

- selection,
- filter change,
- toggle.

### Medium haptic

- offer submission,
- offer acceptance,
- connection creation.

### Success haptic

- identity reveal,
- successful publish.

Never vibrate for:

- every list item,
- every navigation action,
- gold-rate refresh.

---

# 49. Sound

Sound should be optional and extremely restrained.

If implemented:

- no generic click sounds,
- no loud success sounds,
- no notification chimes by default.

Potential premium interaction:

```text
very soft metallic resonance
```

Only for significant interactions.

---

# 50. Gold Material Effects

Create reusable visual primitives:

```text
GoldGradient
GoldBorder
GoldGlow
GoldLightSweep
GoldDivider
GoldIcon
GoldBadge
GoldSurface
```

This prevents individual screens from inventing their own gold styles.

---

# 51. Reusable Flutter Components

Recommended component library:

```text
KhScaffold
KhAppBar
KhSectionHeader
KhGoldButton
KhSecondaryButton
KhGoldOutlinedButton
KhGoldCard
KhLuxuryCard
KhRequestCard
KhOfferCard
KhGoldRateCard
KhStatusBadge
KhMaskedIdentity
KhConnectionCard
KhNotificationTile
KhImagePicker
KhImageGallery
KhGoldLightSweep
KhGoldShimmer
KhMetricCard
KhEmptyState
KhLoadingSkeleton
KhBottomNavigation
KhArtDecoDivider
KhArtDecoFrame
KhPriceText
KhCountdown
KhRating
KhVerifiedBadge
```

All reusable components should consume theme/design tokens.

---

# 52. Flutter Theme Architecture

Recommended structure:

```text
lib/
  core/
    design/
      theme/
        kh_colors.dart
        kh_typography.dart
        kh_spacing.dart
        kh_shapes.dart
        kh_motion.dart
        kh_theme.dart
      components/
        gold_light_sweep.dart
        kh_button.dart
        kh_card.dart
        ...
```

Do not place reusable design components inside feature folders.

Feature-specific composition belongs inside:

```text
features/
  customer/
  vendor/
  authentication/
  requests/
  offers/
  connections/
```

---

# 53. Design Tokens

Do not write:

```dart
color: Color(0xFFD4AF37)
```

throughout the project.

Prefer:

```dart
color: context.kh.colors.goldPrimary
```

or:

```dart
KhColors.gold400
```

Similarly:

```dart
context.kh.spacing.md
context.kh.motion.standard
context.kh.shapes.card
```

This makes global redesign possible without editing every screen.

---

# 54. Responsive Behaviour

The UI must work across:

- compact Android phones,
- standard Android phones,
- large Android phones,
- iPhones,
- tablets where appropriate.

Use adaptive layout principles.

Avoid designing only for one fixed screenshot size.

The visual hierarchy must remain stable even when:

```text
width changes
text scales
Arabic RTL is enabled
system font size increases
```

---

# 55. RTL

English and Arabic are first-class interfaces.

Arabic mode must:

- mirror layout where appropriate,
- preserve semantic ordering,
- correctly align text,
- mirror navigation icons where semantically required,
- preserve gold decorative geometry,
- avoid clipping.

Do not simply flip the entire screen blindly.

---

# 56. Accessibility

Target WCAG-inspired accessibility principles.

Requirements:

- minimum comfortable touch target around 44–48 logical pixels,
- sufficient text contrast,
- gold must not be the only state indicator,
- semantic labels for icons,
- screen-reader-friendly controls,
- scalable typography,
- reduced-motion support,
- clear focus states.

Gold on sapphire is visually beautiful but must be checked for actual contrast.

Use cream text where gold does not provide sufficient text contrast.

---

# 57. Performance

The luxury visual system must not sacrifice responsiveness.

Avoid:

- dozens of simultaneous AnimationControllers,
- full-screen blur everywhere,
- continuous shader effects,
- unnecessary 3D scenes,
- huge uncompressed images,
- rebuild-heavy animations.

Prefer:

- composited transforms,
- opacity,
- clipped gradient overlays,
- cached images,
- lazy lists,
- isolated animation widgets,
- controlled repaint boundaries.

---

# 58. Gold-Light Performance Strategy

For Flutter mobile, the preferred first implementation is **2D composited gradient movement**, not WebGL.

Recommended:

```text
Stack
 ├── child
 └── clipped animated gradient
```

Use `RepaintBoundary` around expensive animated areas when profiling confirms benefit.

Only use 3D/WebGL-like rendering for genuinely premium hero experiences where the device can support it.

The normal application should remain fast without GPU-heavy effects.

---

# 59. Gold-Light Animation State Machine

Conceptually:

```text
IDLE
  ↓ random delay
PREPARE
  ↓
SWEEP
  ↓
SETTLE
  ↓
RANDOM DELAY
  ↓
IDLE
```

Do not continuously loop the sweep.

---

# 60. Gold-Light Pseudocode

```dart
Future<void> runGoldSweep() async {
  while (mounted && enabled) {
    final delay = randomDuration(
      min: const Duration(seconds: 8),
      max: const Duration(seconds: 22),
    );

    await Future.delayed(delay);

    if (!mounted || !enabled) return;

    controller.forward(from: 0);

    await controller.forward();

    if (!mounted || !enabled) return;
  }
}
```

Implementation must ensure:

- no overlapping animations,
- cancellation on dispose,
- reduced-motion support,
- disabled state,
- no memory leaks.

---

# 61. Gold Sweep Geometry

The highlight should generally travel:

```text
-120% → +120%
```

relative to the component width.

This allows the light to begin completely outside the surface and leave completely outside it.

Use:

```text
Transform.translate
```

or an equivalent efficient composited transform.

Avoid repainting the entire screen.

---

# 62. Hero Parallax

Where supported, hero imagery may have extremely subtle parallax.

Maximum movement:

```text
4–8 px
```

Never use dramatic movement.

Jewellery must remain visually stable.

---

# 63. Cards Should Feel Like Objects

A premium card should appear to have a material presence.

Use:

```text
sapphire surface
+
thin gold edge
+
soft inner glow
+
controlled shadow
```

Do not use a huge floating shadow.

The card should feel like:

> a jewellery presentation tray

rather than a generic app card.

---

# 64. Iconography

Icons should be:

- thin,
- geometric,
- elegant,
- consistent stroke width.

Prefer:

- Material Symbols where appropriate,
- custom Art Deco icons for signature concepts.

Custom icons should use a consistent geometry.

---

# 65. Icon Interaction

On tap:

```text
scale 1.0 → 1.08 → 1.0
```

plus:

```text
soft gold highlight
```

Optional:

```text
light haptic
```

Do not rotate icons unnecessarily.

---

# 66. Art Deco Motifs

Use motifs inspired by:

- fan shapes,
- diamonds,
- sunbursts,
- stepped geometry,
- symmetrical lines,
- chevrons,
- thin framing.

Use these as **secondary visual language**.

Do not turn the application into a historical Art Deco museum.

Modern luxury remains the primary objective.

---

# 67. Screen Composition Rule

Every major screen should have:

```text
1 dominant visual hierarchy
1 primary action
1 secondary action group
1 clear content region
```

Avoid five competing CTAs.

---

# 68. Home Screen Composition Rule

The first viewport should communicate:

```text
Brand
+
What can I do?
+
My current activity
```

The user should understand the product within seconds.

---

# 69. Request Creation Composition Rule

Each step should answer one question.

Examples:

```text
What do you want to do?
↓
What are you looking for?
↓
How much gold?
↓
What purity?
↓
What is your budget?
↓
Add photos
↓
Review
↓
Publish
```

---

# 70. Offer Decision Composition Rule

The customer should immediately understand:

```text
How much?
How good is the Vendor?
What are the terms?
When does it expire?
```

The UI must never make the customer hunt for the price.

---

# 71. Vendor Feed Composition Rule

The Vendor should immediately understand:

```text
What is it?
Where?
How much?
How urgent?
Can I quote?
```

---

# 72. Error Handling

Errors should remain premium.

Example:

```text
WE COULDN'T PUBLISH YOUR REQUEST

Your gold rate could not be verified
right now.

Please try again shortly.

[ TRY AGAIN ]
```

Avoid:

```text
ERROR 500
Something went wrong!!!
```

Technical details belong in logs, not user-facing UI.

---

# 73. Network States

### Loading

Show skeleton.

### Slow network

Keep existing content visible.

### Offline

Show a small status:

```text
You're offline
Some information may be outdated.
```

### Server failure

Show recoverable action.

Never blank the whole screen unnecessarily.

---

# 74. Security UI

Identity masking is part of the visual design.

Use subtle cues:

```text
shield icon
"Identity protected"
"Revealed after acceptance"
```

Do not expose sensitive data in:

- previews,
- notification text,
- screenshots,
- cached UI state,
- analytics labels.

---

# 75. Customer History

History should feel archival.

Use:

```text
2026
 ├── Aug
 │   ├── Sell Old Gold
 │   └── Gold Coins
 ├── Jul
 ...
```

Use subtle separators rather than heavy cards.

---

# 76. Profile

Profile should be quiet.

Show:

- profile image,
- name,
- region,
- account status,
- request count,
- connection count,
- settings.

Avoid making the profile feel like a social network.

---

# 77. Settings

Settings should be standard and highly usable.

Sections:

```text
Account
Notifications
Language
Privacy
Terms
Support
Delete Account
App Version
```

Luxury styling should be restrained here.

---

# 78. Vendor Awaiting Approval

This is an important state.

The screen should feel reassuring rather than broken.

Example:

```text
YOUR APPLICATION IS UNDER REVIEW

Your business documents have been
received successfully.

We'll notify you when the review
is complete.

STATUS
● Verification in progress

[ VIEW SUBMITTED DOCUMENTS ]
[ CONTACT SUPPORT ]
```

No marketplace data should appear.

---

# 79. Admin Portal

Admin UI is not a luxury shopping interface.

It should share the brand identity but prioritize:

- productivity,
- density,
- queues,
- tables,
- filtering,
- analytics,
- keyboard interaction.

Use the same sapphire/gold/cream palette with significantly less decorative animation.

---

# 80. Admin Dashboard

Primary queues:

```text
Pending Vendor Verification
Reviews Awaiting Moderation
Open Abuse Reports
```

Metrics:

```text
Customers
Vendors
Requests
Offers
Connections
Liquidity
```

Charts should be clean and analytical.

Gold can identify primary metrics.

---

# 81. Admin Motion Rules

Admin should use approximately:

```text
20–40% of the decorative animation used in Customer mode.
```

No random gold sweeps in dense tables.

Animation should only communicate:

- state change,
- queue update,
- confirmation,
- loading.

---

# 82. Vendor Motion Rules

Vendor mode uses motion functionally.

Examples:

```text
New request → subtle row highlight
Offer accepted → gold confirmation
Offer expiring → countdown emphasis
Subscription active → confirmation
```

Avoid cinematic transitions while the Vendor is working.

---

# 83. Customer Motion Rules

Customer mode can be more expressive.

Allowed:

- hero light,
- gold sweep,
- image transitions,
- reveal animation,
- subtle parallax,
- elegant page transitions.

The experience should feel like entering a jewellery showroom.

---

# 84. Motion Hierarchy

### Tier 1 — Functional

Used everywhere.

```text
fade
slide
scale
state transitions
```

### Tier 2 — Brand

Used selectively.

```text
gold sweep
gold glow
Art Deco reveal
```

### Tier 3 — Signature

Rare.

```text
identity reveal
hero light
premium subscription activation
```

Never use Tier 3 repeatedly on one screen.

---

# 85. Do Not Over-animate

A luxury application should have **quiet moments**.

The screen should often remain still.

The occasional light sweep is effective precisely because it is unexpected.

Desired feeling:

> "Did the gold just catch the light?"

Not:

> "This app keeps animating."

---

# 86. Design Consistency Rules

Every screen must reuse:

- same gold,
- same sapphire,
- same spacing scale,
- same typography,
- same card radius,
- same button height,
- same status system,
- same motion tokens,
- same light-sweep behaviour.

No screen-specific visual invention without a design-system reason.

---

# 87. Recommended Spacing Scale

Use a consistent 4-point / 8-point derived system:

```text
4
8
12
16
20
24
32
40
48
64
80
```

Primary mobile page padding:

```text
16–24 px
```

Hero padding:

```text
24–32 px
```

---

# 88. Touch Targets

Interactive controls should generally be:

```text
minimum 44 × 44
preferred 48 × 48
```

Even when the visual icon is smaller.

---

# 89. Buttons

### Primary

Gold metallic / gold surface:

```text
[ VIEW OFFERS ]
```

Dark sapphire text.

### Secondary

Transparent sapphire surface:

```text
[ VIEW REQUEST ]
```

Gold border.

### Tertiary

Text-only:

```text
Cancel
```

Gold or cream depending on context.

Do not use bright blue Material defaults.

---

# 90. Bottom Sheets

Bottom sheets should use:

- sapphire surface,
- gold drag handle,
- 16–24 px radius,
- subtle elevation,
- strong title hierarchy.

Use them for:

- filters,
- sort,
- action menus,
- request type selection,
- image actions.

---

# 91. Dialogs

Dialogs should be used for important decisions only.

Examples:

- Accept Offer
- Cancel Request
- Withdraw Offer
- Delete Account
- Close Connection

Do not use dialogs for ordinary navigation.

---

# 92. Gold Countdown

For Request expiry:

```text
18h 42m remaining
```

Use gold when healthy.

Near expiry:

```text
6h 02m remaining
```

Use a warmer amber emphasis.

Never use a flashing countdown.

---

# 93. Images

Use progressive loading:

```text
blurred thumbnail
↓
high-resolution image
```

Hero images should be preloaded where practical.

All images must be safely clipped.

---

# 94. Image Gallery

Customer image gallery should feel tactile.

Tap:

```text
thumbnail → full-screen viewer
```

Use:

- dark sapphire backdrop,
- gold close icon,
- swipe gestures,
- subtle page indicator.

Do not add excessive controls over the jewellery.

---

# 95. Gold Rate Animation

When the rate updates:

```text
old value
↓
brief fade/number transition
↓
new value
```

Do not animate the entire card.

If the price changes significantly, a subtle gold highlight may cross the number.

---

# 96. Request Published Animation

After publishing:

```text
Publish button
↓
gold progress line
↓
gold geometric expansion
↓
"Request Published"
↓
reference number
```

Then transition to Request Detail.

---

# 97. Offer Submitted Animation

Vendor:

```text
Submit Offer
↓
confirmation
↓
gold line
↓
"Offer Sent"
```

Keep under 700ms.

---

# 98. Connection Created Animation

This should be one of the most refined animations in the application.

Sequence:

```text
Offer accepted
↓
background dims slightly
↓
gold line expands
↓
identity mask dissolves
↓
real identity appears
↓
gold light sweep
↓
Talk button appears
```

The user should understand immediately that a new relationship has been created.

---

# 99. Design Philosophy

Karat Hive should behave visually like:

```text
Luxury jewellery showroom
        +
private marketplace
        +
professional quotation system
```

It should NOT behave like:

```text
generic marketplace
        +
banking app
        +
social media
```

---

# 100. AI / UI Generation Context

When generating a Karat Hive screen, always infer:

1. Which actor is using the screen:
   - Customer
   - Vendor
   - Admin

2. Which product workflow it belongs to.

3. Which state the underlying entity is in.

4. What the primary action is.

5. Whether identity must be masked.

6. Whether the screen is:
   - consumer luxury,
   - operational vendor,
   - administrative.

7. Which design tokens apply.

8. Which motion tier applies.

9. Whether the gold-light animation is appropriate.

10. Whether reduced motion or accessibility changes the animation.

---

# 101. AI Generation Rules

When asked to "create a Karat Hive screen":

### Always

- use deep sapphire as the visual foundation,
- use restrained metallic gold,
- use cream typography,
- use Material 3 interaction principles,
- maintain Art Deco geometry,
- maintain premium spacing,
- use realistic jewellery imagery where applicable,
- make the primary action obvious,
- respect Customer/Vendor/Admin role,
- respect identity masking,
- respect Request/Offer states.

### Never

- invent conventional e-commerce cart behaviour,
- expose masked identities,
- use generic bright-yellow gold,
- add random decorative gradients everywhere,
- use excessive rounded pills,
- add fake payment flows,
- add in-app chat,
- invent vendor inventory browsing,
- add unrequested auctions,
- use flashing urgency,
- make every element animate.

---

# 102. Component-Level Animation Defaults

| Component | Animation |
|---|---|
| Gold CTA | optional light sweep |
| Request card | tap scale |
| Offer card | subtle entrance |
| Gold rate | number transition |
| Notification badge | one pulse |
| Hero | random light sweep |
| Identity reveal | signature animation |
| Bottom navigation | short selection transition |
| Filter sheet | slide + fade |
| Dialog | scale/fade |
| Vendor feed | functional highlight |
| Admin table | minimal |

---

# 103. Animation Randomization Rules

Randomness must be deterministic enough to avoid chaos.

Recommended:

```dart
final random = Random(seed);
```

Use a per-component or per-session seed where practical.

Do not use the same global timer for all gold surfaces.

Avoid:

```text
Hero sweep
Gold rate sweep
CTA sweep
Card sweep
navigation sweep
```

all occurring together.

That destroys the premium effect.

---

# 104. Animation Budget

At any given time:

### Customer

Maximum approximately:

```text
1–2 decorative animations
+
normal functional transitions
```

### Vendor

```text
0–1 decorative animations
+
functional transitions
```

### Admin

```text
0 decorative animations
+
functional transitions
```

This is a design guideline, not a hard runtime limit.

---

# 105. Visual Depth

Use three primary depth levels:

```text
Level 0
Sapphire canvas

Level 1
Sapphire elevated surfaces

Level 2
Gold-highlighted premium surfaces
```

Do not create 10 layers of shadows.

---

# 106. Premium Surface Example

```text
┌───────────────────────────────┐
│                               │
│  24K GOLD                     │
│                               │
│  AED 512.40 / g               │
│                               │
│  Updated 3 min ago            │
│                               │
└───────────────────────────────┘
```

Visual treatment:

```text
sapphire800
+
1px gold border
+
subtle inner gold glow
+
occasional light sweep
```

---

# 107. Trust Signals

Use:

- Verified badge,
- rating,
- connection count,
- request status,
- gold-rate timestamp,
- identity protection label.

Avoid meaningless decorative badges.

Every badge must communicate something useful.

---

# 108. Copywriting Style

Use short, confident language.

Good:

```text
Find your gold.
Compare verified offers.

Your request is live.

3 offers are waiting.

Identity revealed after acceptance.
```

Avoid:

```text
Congratulations!!! Your request has
successfully been posted into our
amazing marketplace.
```

Luxury language is concise.

---

# 109. Brand Voice

Karat Hive speaks:

- confidently,
- warmly,
- simply,
- professionally.

It does not shout.

Avoid excessive:

```text
!!!
LIMITED!!!
HURRY!!!
BEST DEAL!!!
```

---

# 110. Core Visual Test

Before approving a screen, ask:

### Does it look like Karat Hive with the logo removed?

If yes, it belongs.

If it could be mistaken for:

- a banking app,
- generic Flutter UI,
- generic Shopify UI,
- generic marketplace UI,

it needs redesign.

---

# 111. Final Design Principle

The defining visual signature of Karat Hive is:

> **Dark sapphire space, restrained metallic gold, editorial typography, geometric Art Deco precision, and occasional light moving across gold as though the jewellery has caught a real showroom light.**

The animation should be **rare enough to feel magical**.

The UI should be **clear enough to disappear behind the experience**.

The product should feel **expensive, trustworthy and effortless**.

---

## Source Alignment

This context is derived from:

- `Karat_Hive_Luxury_UI_Design_Analysis.md`
- `Requirements-Spec-v1.1.md`

The requirements establish the product workflows, role separation, masking, Request/Offer lifecycle, gold rates, subscriptions, WhatsApp handoff, and screen inventory. The luxury UI analysis establishes the Art Deco visual language, sapphire/gold/cream token hierarchy, material rendering direction, micro-interaction philosophy, accessibility considerations, and performance principles.

Important product constraints carried into UI:

- UAE / AED v1.0
- Customer + Vendor in one mobile binary
- Customer OAuth once before first Request publish
- Vendor marketplace access only when `VERIFIED` + `ACTIVE`
- Vendor subscription per Request type
- Requests hard-expire after 48 hours
- Customer/Vendor identities remain masked until Offer acceptance
- Post-acceptance communication uses WhatsApp
- Reviews are hold-for-approval
- Gold reference rates come from Yahoo Finance, subject to legal confirmation
- No in-app payment, escrow, logistics, or messaging in v1.0
