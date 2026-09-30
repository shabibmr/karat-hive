\# HIVE — Mobile UI Design System for Flutter



This is the \*\*design system behind the HIVE / Karat Hive UI we've been developing\*\*: premium jewellery aesthetic, generous whitespace, editorial typography, soft neutral surfaces, restrained pink accents, borderless components, and photography-led cards.



The important principle is:



> \*\*The screens should feel like one luxury brand, but each screen can have its own composition.\*\*



So this is a \*\*design system\*\*, not a rigid component template.



\---



\# 1. Design Philosophy



\### Core characteristics



1\. \*\*Luxury but understated\*\*

2\. \*\*Large amounts of whitespace\*\*

3\. \*\*Photography is the primary visual element\*\*

4\. \*\*Editorial typography\*\*

5\. \*\*Very few UI borders\*\*

6\. \*\*Soft surfaces instead of outlined containers\*\*

7\. \*\*Rounded but not excessively rounded\*\*

8\. \*\*Minimal text\*\*

9\. \*\*Warm neutral backgrounds\*\*

10\. \*\*Pink used as an accent, not as the primary surface\*\*

11\. \*\*Gold comes primarily from photography, not UI decoration\*\*

12\. \*\*Asymmetric/editorial compositions are encouraged\*\*

13\. \*\*Dark theme uses the same visual language rather than simply inverting colors\*\*



\---



\# 2. Brand Identity



\## Brand



\*\*HIVE\*\*



The logo consists of:



\* Organic vertical emblem

\* Black/dark outline

\* Pink `HIVE` wordmark



The logo should generally remain visually quiet.



\### Logo usage



```text

Light Theme

Logo emblem: Dark

Wordmark: HIVE Pink



Dark Theme

Logo emblem: Light

Wordmark: HIVE Pink

```



Avoid:



\* Gold-colored logo

\* Gradient logo

\* Heavy shadows

\* Logo inside a large card

\* Excessive surrounding decoration



\---



\# 3. Color System



\## 3.1 Light Theme



\### Primary Background



```dart

backgroundPrimary = #FCF9F6

```



Very warm off-white rather than pure white.



\### Secondary Surface



```dart

surfacePrimary = #F7F0EB

```



Used for subtle areas and cards.



\### Soft Pink



```dart

accentPink = #F8DDE7

```



Used for:



\* Action circles

\* Selected navigation

\* Small indicators

\* Notification indicators

\* Secondary highlights



\### Strong Accent



```dart

accentPinkStrong = #F43F83

```



Used sparingly for:



\* Active navigation icon

\* Active carousel indicator

\* Important interactive states



\### Primary Text



```dart

textPrimary = #242326

```



\### Secondary Text



```dart

textSecondary = #777276

```



\### Muted Text



```dart

textMuted = #A7A1A2

```



\### Divider



Dividers are generally avoided.



When required:



```dart

divider = #EAE3DF

```



with very low visual prominence.



\---



\# 4. Dark Theme



The dark theme should \*\*not\*\* simply invert the light theme.



\### Background



```dart

darkBackground = #101010

```



\### Surface



```dart

darkSurface = #191717

```



\### Elevated Surface



```dart

darkSurfaceElevated = #211D1F

```



\### Primary Text



```dart

darkTextPrimary = #F7F1EE

```



\### Secondary Text



```dart

darkTextSecondary = #AAA3A5

```



\### Pink Accent



```dart

darkAccentPink = #F75A94

```



\### Soft Pink Surface



```dart

darkPinkSurface = #34232B

```



The generated dark Home screen follows this principle:



```text

BLACK / CHARCOAL

&#x20;      +

WARM GOLD PHOTOGRAPHY

&#x20;      +

SOFT PINK ACCENTS

&#x20;      +

IVORY TYPOGRAPHY

```



\---



\# 5. Gold Is Not a UI Color



This is an important design decision.



Don't create a UI palette full of:



```text

Gold

Dark Gold

Light Gold

Champagne Gold

Metallic Gold

```



The gold should primarily come from the \*\*photography\*\*.



This makes the interface more sophisticated.



The UI itself remains:



\*\*Ivory + Charcoal + Pink\*\*



while the jewellery provides:



\*\*Gold + Warm Metallic Tones\*\*



\---



\# 6. Typography



The visual identity uses two typography personalities.



\## 6.1 Display Typeface



A high-contrast editorial serif.



Recommended Flutter implementation:



\*\*Cormorant Garamond\*\*



or a similar editorial serif.



Used for:



\* Hero headlines

\* Large page titles

\* Request type names

\* Major numerical values

\* Important promotional text



Example:



```text

Gold

for your

story

```



\### Display sizes



| Style          |  Size | Weight  |

| -------------- | ----: | ------- |

| Display XL     | 44–48 | Regular |

| Display Large  | 38–42 | Regular |

| Display Medium | 32–36 | Regular |

| Heading Large  | 28–32 | Regular |

| Heading Medium | 24–28 | Regular |



\---



\# 7. UI Typeface



Use a clean modern sans-serif.



Recommended:



\*\*Inter\*\*



Used for:



\* Navigation

\* Buttons

\* Form labels

\* Supporting text

\* Status

\* Metadata

\* Error messages

\* Numbers where clarity is important



\### UI typography



| Style      |  Size |

| ---------- | ----: |

| Body Large |    17 |

| Body       | 15–16 |

| Body Small | 13–14 |

| Caption    | 11–12 |

| Button     | 14–16 |

| Navigation | 12–13 |



\---



\# 8. Typography Rules



\### Don't overuse bold



The design relies on:



\*\*size + whitespace + contrast\*\*



rather than:



\*\*bold + borders + boxes\*\*



For example:



```text

Sell My

Gold

```



is more appropriate than:



```text

SELL MY GOLD

```



for major customer-facing titles.



\---



\# 9. Spacing System



Use an \*\*8-point base spacing system\*\*.



```dart

space1 = 4

space2 = 8

space3 = 12

space4 = 16

space5 = 20

space6 = 24

space7 = 32

space8 = 40

space9 = 48

space10 = 64

```



\### Common usage



```text

Screen horizontal padding    20–24

Card gap                     16

Section gap                  24–32

Large section gap            40–48

Hero internal padding        24–32

Button horizontal padding    20–24

```



\---



\# 10. Screen Margins



Default mobile screen:



```dart

horizontalPadding = 20

```



For larger devices:



```dart

horizontalPadding = 24

```



Avoid edge-to-edge content unless intentionally used for photography.



\---



\# 11. Border Radius



We deliberately reduced the excessive rounded-card appearance.



\### Standard radius



```dart

radiusSmall = 10

radiusMedium = 14

radiusLarge = 18

```



\### Primary card



```dart

cardRadius = 16

```



\### Hero



```dart

heroRadius = 18

```



\### Buttons



```dart

buttonRadius = 10

```



\### Circular controls



Use true circles:



```dart

radius = 999

```



The important principle:



> \*\*The corner radius should feel like the radius of a physical card, not a pill.\*\*



\---



\# 12. Borders



\### Default



\*\*No border.\*\*



Cards should normally be separated through:



\* background contrast

\* spacing

\* photography

\* shadows



rather than strokes.



\### If a border is necessary



```dart

borderWidth = 1

borderColor = #EAE3DF

```



Dark:



```dart

borderColor = #302A2C

```



Very subtle.



\---



\# 13. Shadows



Shadows should be extremely soft.



Avoid:



```text

heavy black shadow

hard drop shadow

large elevation

floating Material cards

```



Preferred:



```dart

blurRadius = 18–24

spreadRadius = 0

opacity ≈ 0.04–0.08

```



In many screens, \*\*no shadow is even better\*\*.



\---



\# 14. Photography System



Photography is one of the most important parts of HIVE.



\## Style



Images should feel:



\* editorial

\* warm

\* natural

\* premium

\* minimal

\* tactile

\* softly lit



\### Background



Prefer:



\* ivory stone

\* cream marble

\* beige surfaces

\* warm neutral backgrounds

\* subtle shadows



Avoid:



\* busy jewellery-store backgrounds

\* strong saturated colors

\* excessive props

\* black backgrounds in light theme

\* artificial cut-out products



\---



\# 15. Customer Uploaded Images



These are different from marketing imagery.



For customer requests:



> \*\*Use the customer's actual photograph.\*\*



It may be:



\* taken with a phone

\* poorly framed

\* on a home table

\* against an ordinary background

\* slightly dark

\* imperfect



\*\*Do not make the uploaded image look like a professional catalogue photograph.\*\*



This distinction is important for the marketplace.



\---



\# 16. Image Aspect Ratios



\### Hero



```text

16:9 approximately

```



\### Request cards



```text

4:3

```



\### Product/action cards



```text

4:3

```



\### User-uploaded request images



Preserve original aspect ratio where possible, but use controlled cropping for thumbnails.



\---



\# 17. Image Treatment



Use:



```dart

BoxFit.cover

```



for promotional cards.



For customer photographs:



```dart

BoxFit.cover

```



in cards, but:



```dart

BoxFit.contain

```



when the user needs to inspect the actual object.



\---



\# 18. Hero Carousel



The Home hero follows:



```text

┌───────────────────────────┐

│                           │

│  Editorial image          │

│                           │

│  Large serif message      │

│                           │

│                   →       │

│                           │

│       ●  ○  ○             │

└───────────────────────────┘

```



\### Characteristics



\* Large image

\* Minimal text

\* 16:9-ish composition

\* Rounded corners

\* Side navigation buttons

\* Small pagination indicators

\* No heavy overlay

\* Text integrated into negative space



\---



\# 19. Request Type Cards



The four primary actions:



1\. Find an Ornament

2\. Sell My Gold

3\. Gold Coins

4\. Gold Bullion



They use the same \*\*design language\*\*, but don't need to have identical internal compositions.



\### Card structure



```text

┌─────────────────────┐

│                     │

│      PHOTO          │

│                     │

│                     │

├─────────────────────┤

│ Find an             │

│ Ornament       →    │

└─────────────────────┘

```



The photograph should occupy the majority of the card.



\---



\# 20. Action Circle



The arrow action is a recurring HIVE component.



```text

&#x20;    ┌───────┐

&#x20;    │   →   │

&#x20;    └───────┘

```



Light theme:



```dart

background = #F8DDE7

icon = #242326

```



Active/important state:



```dart

icon = #F43F83

```



Dark theme:



```dart

background = #34232B

icon = #F75A94

```



\---



\# 21. Buttons



Buttons should be \*\*flat\*\*.



This is something we refined repeatedly during the mockups.



\### Do not use



\* gradients

\* glossy effects

\* strong elevation

\* metallic effects

\* excessive shadows



\### Primary button



```dart

background: accentPinkStrong

foreground: white

radius: 10

height: 52

```



\### Secondary button



```dart

background: softPink

foreground: textPrimary

radius: 10

height: 48

```



\---



\# 22. Bottom Navigation



The bottom navigation is a distinctive part of the UI.



\### Structure



```text

┌───────────────────────────────────┐

│                                   │

│   Home   Requests Connections Profile

│                                   │

└───────────────────────────────────┘

```



It should appear as a \*\*soft floating surface\*\*, not the standard Material navigation bar.



\### Light



```dart

background = #FFF2F7

```



\### Dark



```dart

background = #2A2024

```



\### Selected



```dart

icon = accentPinkStrong

label = accentPinkStrong

```



\### Unselected



```dart

icon = #8F898C

label = #8F898C

```



\### Shape



```dart

radius = 28–32

```



The navigation bar has more rounding than normal cards because it is intentionally a floating control surface.



\---



\# 23. Navigation Items



Customer application:



```text

Home

Requests

Connections

Profile

```



The selected item gets:



\* Pink icon

\* Pink label

\* No heavy pill/background

\* Slightly stronger visual weight



\---



\# 24. Header



The Home header is intentionally minimal.



```text

&#x20;       HIVE                🔔   S

```



Possible structure:



```text

Logo

&#x20;       Notification

&#x20;       Profile

```



\### Profile avatar



Use a soft circular background.



Light:



```dart

background = #F9DCE7

```



Dark:



```dart

background = #6A4052

```



\---



\# 25. Notification Indicator



Small pink dot:



```text

&#x20;     •

&#x20;    🔔

```



No large red badge unless an actual count needs to be displayed.



\---



\# 26. Forms



Request creation screens should follow the same visual language but \*\*should not look like the Home page\*\*.



Forms use:



\* large section spacing

\* borderless fields

\* soft surfaces

\* editorial headings

\* photography where appropriate

\* minimal labels



Example:



```text

PHOTOS



┌───────────────┐

│               │

│      +        │

│               │

└───────────────┘

```



Avoid dozens of outlined Material `TextField`s.



\---



\# 27. Input Fields



Default field:



```dart

background = #F7F0EB

border = none

radius = 12

height = 52–56

```



Focused:



```dart

background = #F4E8E3

```



or a very subtle accent indicator.



\---



\# 28. Selection Controls



For things like:



\* Purity

\* Ornament type

\* Condition

\* Direction



prefer:



\### Chips



```text

22K   21K   18K

```



rather than dropdowns wherever the number of options is small.



Selected:



```text

Pink background

Dark text

```



Unselected:



```text

Soft neutral background

```



\---



\# 29. Cards



There are \*\*three different card categories\*\*.



\### A. Editorial Card



Used for:



\* Home actions

\* Hero content



Large image + minimal text.



\### B. Transaction Card



Used for:



\* Requests

\* Offers

\* Vendor interactions



More information, but still visually clean.



\### C. Information Card



Used for:



\* Gold rate

\* Indicative valuation

\* Important information



Mostly typography and whitespace.



Don't make all three look identical.



\---



\# 30. Request Cards



The vendor/customer request cards should be compact.



For example:



```text

┌─────────────────────────────────┐

│ \[photo]                         │

│                                 │

│  22K Gold Bangle                │

│  25g · BUY                      │

│                                 │

│  4 Offers             18h left  │

└─────────────────────────────────┘

```



The photograph remains the strongest element.



\---



\# 31. Vendor UI



Vendor screens can be \*\*denser\*\* than Customer screens.



Customer:



```text

large

airy

editorial

```



Vendor:



```text

compact

information-rich

action-oriented

```



But both use:



\* same typography

\* same colors

\* same radii

\* same photography language

\* same interaction language



\---



\# 32. Offer Cards



Offer information should be easy to compare.



Use typography hierarchy:



```text

AED 8,450

&#x20;     ↑

&#x20;  primary



22K · 18.5g

&#x20;     ↑

&#x20;  secondary



Vendor name

&#x20;     ↑

&#x20;  tertiary

```



Avoid putting every value into a separate outlined box.



\---



\# 33. Indicative Valuation



The valuation component should feel special.



```text

INDICATIVE VALUE



AED 5,850



Based on current reference gold rate

```



Large number.



Large whitespace.



No heavy card.



This is especially important in \*\*Sell My Gold\*\*.



\---



\# 34. Abstract Background System



The background shapes we've used are part of the identity.



Use:



\* oversized organic circles

\* soft arcs

\* blurred forms

\* subtle beige shapes

\* translucent pink shapes

\* jewellery-inspired curves



They should sit \*\*behind\*\* content.



Opacity:



```text

5–15%

```



They should be felt rather than noticed.



\---



\# 35. Dark Theme Background Shapes



Dark theme should use:



```text

deep charcoal

\+

brown/bronze atmospheric shapes

\+

very subtle pink glow

```



Avoid neon gradients.



The generated dark Home follows this concept.



\---



\# 36. Icons



Use a consistent \*\*thin-line icon style\*\*.



Recommended:



```text

Lucide

```



or another thin outline icon set.



Characteristics:



\* 1.5–2px stroke

\* rounded joins

\* simple geometry

\* no filled decorative icons except active states



\---



\# 37. Icon Sizes



```dart

small = 18

medium = 22

large = 24

heroAction = 20

navigation = 24

```



\---



\# 38. Interaction States



Every interactive component should support:



\### Default



Normal opacity.



\### Pressed



```text

scale ≈ 0.97

```



or subtle surface change.



\### Disabled



```text

opacity ≈ 0.45

```



\### Selected



Pink accent.



\### Loading



Use subtle skeleton/loading indicators rather than aggressive spinners where possible.



\---



\# 39. Motion



Animation should be \*\*slow and elegant\*\*.



\### Page transition



```text

200–300ms

```



\### Card interaction



```text

150–200ms

```



\### Hero carousel



```text

350–500ms

```



\### Recommended curves



```dart

Curves.easeOutCubic

Curves.easeInOutCubic

```



Avoid:



\* bounce

\* elastic

\* excessive scaling

\* flashy transitions



\---



\# 40. Scroll Behaviour



The UI is designed around \*\*scrollable pages\*\*, not forcing everything to fit on one screen.



For example:



```text

Request Create

&#x20;     ↓

Scrollable content

&#x20;     ↓

Sticky bottom action

```



The Home can also scroll, but the first viewport should contain the important actions.



\---



\# 41. Responsive Rules



Design around a baseline:



```text

Width: 390

Height: 844

```



but don't hard-code those dimensions.



Use:



```dart

MediaQuery

LayoutBuilder

SafeArea

AspectRatio

Expanded

Flexible

```



rather than fixed pixel positioning.



\---



\# 42. Flutter Architecture



I would translate the design system into:



```text

lib/

└── core/

&#x20;   └── theme/

&#x20;       ├── hive\_colors.dart

&#x20;       ├── hive\_typography.dart

&#x20;       ├── hive\_spacing.dart

&#x20;       ├── hive\_radii.dart

&#x20;       ├── hive\_shadows.dart

&#x20;       ├── hive\_theme.dart

&#x20;       └── hive\_icons.dart

```



Then:



```text

features/

├── customer/

├── vendor/

└── admin/

```



\---



\# 43. Flutter Theme Tokens



Conceptually:



```dart

class HiveTheme {

&#x20; static const colors = HiveColors();

&#x20; static const spacing = HiveSpacing();

&#x20; static const radii = HiveRadii();

&#x20; static const typography = HiveTypography();

}

```



The actual widgets should consume these tokens instead of hard-coding values.



For example:



```dart

Container(

&#x20; padding: EdgeInsets.all(HiveSpacing.md),

&#x20; decoration: BoxDecoration(

&#x20;   color: HiveColors.surface,

&#x20;   borderRadius: HiveRadii.card,

&#x20; ),

)

```



\---



\# 44. Component Library



Create reusable components around \*\*visual roles\*\*, not individual screens.



```text

HiveScaffold

HiveAppBar

HiveLogo

HiveHeroCarousel

HiveActionCard

HiveImageCard

HiveRequestCard

HiveOfferCard

HiveSectionHeader

HivePrimaryButton

HiveSecondaryButton

HiveIconButton

HiveActionCircle

HiveChip

HiveTextField

HiveAmountField

HiveImagePicker

HiveBottomNavigation

HiveValuationCard

HiveStatusBadge

HiveEmptyState

HiveLoading

```



This allows the four Request editors to be different while still belonging to the same design system.



\---



\# 45. Design Principle for the Four Request Pages



This is particularly important given what we established earlier.



\*\*Do not do this:\*\*



```text

Request Editor

&#x20;├── Type A

&#x20;├── Type B

&#x20;├── Type C

&#x20;└── Type D



Same layout

Different fields

```



Instead:



```text

&#x20;                HIVE DESIGN SYSTEM

&#x20;                       │

&#x20;            ┌──────────┴──────────┐

&#x20;            │                     │

&#x20;      Shared Components      Shared Tokens

&#x20;            │

&#x20;      ┌─────┼─────┬─────┐

&#x20;      │     │     │     │

&#x20;  Ornament Gold  Coins Bullion

```



Each editor gets its own \*\*visual composition\*\*, while using the same:



\* typography

\* spacing

\* colors

\* buttons

\* image treatment

\* interaction patterns

\* cards

\* navigation



That is what will make the application feel \*\*designed\*\*, rather than generated from one form template.



\---



\# 46. Design System Summary



| Area        | HIVE Principle                        |

| ----------- | ------------------------------------- |

| Overall     | Luxury editorial                      |

| Background  | Warm ivory / deep charcoal            |

| Accent      | Soft pink                             |

| Gold        | Primarily through photography         |

| Typography  | Editorial serif + clean sans          |

| Cards       | Borderless                            |

| Radius      | Moderate, not excessive               |

| Shadows     | Very subtle                           |

| Images      | Large and dominant                    |

| Text        | Minimal                               |

| Layout      | Generous whitespace                   |

| Buttons     | Flat, no gradient                     |

| Icons       | Thin line                             |

| Navigation  | Floating soft surface                 |

| Forms       | Borderless / soft surfaces            |

| Home        | Image-led                             |

| Customer UI | Spacious                              |

| Vendor UI   | Denser                                |

| Dark Mode   | Warm charcoal + gold photography      |

| Animation   | Subtle and elegant                    |

| Components  | Reusable but compositionally flexible |



\## The core rule



> \*\*HIVE should feel like a luxury jewellery magazine that happens to be an application—not an ERP application with jewellery imagery.\*\*



That should be the guiding principle when implementing the Flutter UI.



