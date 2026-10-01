\# Karat Hive — Mobile UI Design System



This is the \*\*design system I would use as the implementation standard for the Flutter project\*\*, based on the generated Karat Hive UI direction and the requirements. The original design analysis established the luxury foundation of sapphire, gold and cream; the newer direction refines it toward \*\*lighter surfaces, simpler ornaments, much more whitespace, and significantly less text\*\*. 



The key principle is:



> \*\*Luxury through restraint — not decoration.\*\*



The jewellery itself should be the visual focus. The UI should almost disappear around it.



\---



\# 1. Design Philosophy



\### 1.1 Core principles



| Principle                 | Rule                                                                                          |

| ------------------------- | --------------------------------------------------------------------------------------------- |

| \*\*Minimalism\*\*            | Remove anything that does not help the user act or understand.                                |

| \*\*Whitespace\*\*            | Generous spacing is intentional, not wasted space.                                            |

| \*\*Jewellery first\*\*       | Product imagery gets more visual weight than UI decoration.                                   |

| \*\*Quiet luxury\*\*          | Gold is an accent, never the dominant UI color.                                               |

| \*\*Simple ornaments\*\*      | Use very thin geometric lines and subtle jewellery motifs.                                    |

| \*\*Short copy\*\*            | Prefer 1–3 word labels over sentences.                                                        |

| \*\*Flat design\*\*           | No heavy gradients, glassmorphism or excessive shadows.                                       |

| \*\*Soft geometry\*\*         | Moderate corner rounding rather than highly rounded "app" aesthetics.                         |

| \*\*Editorial feel\*\*        | Typography and spacing should feel closer to a luxury catalogue than a marketplace dashboard. |

| \*\*Material 3 foundation\*\* | Use Flutter Material 3 components and semantics, but customize their visual language.         |



The generated direction should therefore \*\*not\*\* be treated as a conventional e-commerce UI full of cards, badges and explanatory text.



\---



\# 2. Visual Character



The visual language can be summarized as:



\*\*Ivory + warm white + champagne gold + charcoal + jewellery photography + generous whitespace.\*\*



Avoid making the application look:



\* overly Art Deco

\* excessively golden

\* dark and heavy

\* crowded

\* card-heavy

\* overly ornamental

\* like a generic shopping application



The original analysis proposed a much stronger Art Deco/sapphire treatment.  The current system deliberately \*\*softens that direction\*\* to achieve the cleaner luxury aesthetic you requested.



\---



\# 3. Color System



\## 3.1 Primitive colors



```dart

abstract final class KhColors {

&#x20; // Neutrals

&#x20; static const ivory = Color(0xFFFAF8F3);

&#x20; static const warmWhite = Color(0xFFFFFDFC);

&#x20; static const white = Color(0xFFFFFFFF);



&#x20; static const stone50 = Color(0xFFF7F5F0);

&#x20; static const stone100 = Color(0xFFEDEAE3);

&#x20; static const stone200 = Color(0xFFDCD8CF);

&#x20; static const stone400 = Color(0xFFA8A39A);

&#x20; static const stone600 = Color(0xFF706C65);



&#x20; // Typography

&#x20; static const charcoal = Color(0xFF242320);

&#x20; static const mutedText = Color(0xFF77736B);



&#x20; // Brand

&#x20; static const champagne = Color(0xFFC6A15B);

&#x20; static const gold = Color(0xFFD4AF37);

&#x20; static const goldLight = Color(0xFFE8D6A5);



&#x20; // Optional legacy brand tone

&#x20; static const sapphire = Color(0xFF0A1128);



&#x20; // Semantic

&#x20; static const success = Color(0xFF557A62);

&#x20; static const error = Color(0xFF9B514A);

&#x20; static const warning = Color(0xFFA5793E);

}

```



\### Important rule



\*\*Gold should not become the background of the application.\*\*



Gold is used for:



\* selected states

\* tiny separators

\* icons

\* borders

\* prices

\* important actions

\* brand details



It should generally occupy \*\*less than 10% of a screen's visual area\*\*.



\---



\# 4. Semantic Color Tokens



Flutter components should never directly reference primitive colors.



Instead:



```dart

abstract final class KhSemanticColors {

&#x20; static const background = KhColors.ivory;

&#x20; static const surface = KhColors.white;

&#x20; static const surfaceSubtle = KhColors.stone50;



&#x20; static const textPrimary = KhColors.charcoal;

&#x20; static const textSecondary = KhColors.mutedText;

&#x20; static const textDisabled = KhColors.stone400;



&#x20; static const border = KhColors.stone200;

&#x20; static const divider = KhColors.stone100;



&#x20; static const accent = KhColors.champagne;

&#x20; static const accentStrong = KhColors.gold;



&#x20; static const success = KhColors.success;

&#x20; static const error = KhColors.error;

&#x20; static const warning = KhColors.warning;

}

```



This gives us the ability to change the entire theme later without touching individual widgets.



\---



\# 5. Dark Sapphire Usage



The original Karat Hive system defines sapphire `#0A1128` as a primary brand color. 



In the \*\*new simplified UI\*\*, sapphire becomes a \*\*secondary luxury surface\*\*, not the application background.



Use it for:



\* occasional hero sections

\* special promotional banners

\* premium collection sections

\* authentication moments

\* selected premium states



Example:



```text

Main Application

────────────────────────

Ivory background



Product pages

────────────────────────

White / Ivory



Premium banner

────────────────────────

Sapphire + Champagne



CTA

────────────────────────

Charcoal / Champagne

```



This creates contrast without making the entire application visually heavy.



\---



\# 6. Typography



Typography should feel \*\*editorial, elegant and quiet\*\*.



\## 6.1 Font pairing



Recommended:



\### Display



\*\*Cormorant Garamond\*\*



Used for:



\* major page titles

\* collection names

\* luxury promotional headlines

\* selected hero typography



\### UI



\*\*Inter\*\*



Used for:



\* buttons

\* labels

\* prices

\* forms

\* navigation

\* metadata

\* body text



Flutter example:



```dart

ThemeData(

&#x20; fontFamily: 'Inter',

);

```



And explicitly use the display family:



```dart

Text(

&#x20; 'Timeless',

&#x20; style: Theme.of(context).textTheme.displaySmall?.copyWith(

&#x20;   fontFamily: 'Cormorant Garamond',

&#x20; ),

);

```



\---



\# 7. Type Scale



Keep the typography restrained.



| Token           | Size | Weight | Usage                 |

| --------------- | ---: | ------ | --------------------- |

| Display Large   |   40 | 400    | Hero                  |

| Display Medium  |   32 | 400    | Major editorial title |

| Display Small   |   28 | 400    | Collection title      |

| Headline Large  |   24 | 500    | Screen title          |

| Headline Medium |   20 | 500    | Section title         |

| Title Large     |   18 | 500    | Product title         |

| Body Large      |   16 | 400    | Main content          |

| Body Medium     |   14 | 400    | Secondary content     |

| Body Small      |   12 | 400    | Metadata              |

| Label Large     |   14 | 500    | Buttons               |

| Label Medium    |   12 | 500    | Small labels          |

| Label Small     |   11 | 500    | Micro metadata        |



\### Typography rule



Do not use bold everywhere.



Luxury comes from:



\*\*scale + whitespace + contrast\*\*



rather than:



\*\*bold + gold + borders + shadows.\*\*



\---



\# 8. Letter Spacing



Editorial headings:



```text

\-0.5 to 0

```



Uppercase labels:



```text

+1.2 to +2.0

```



Normal UI text:



```text

0

```



Example:



```dart

TextStyle(

&#x20; fontSize: 12,

&#x20; letterSpacing: 1.6,

&#x20; fontWeight: FontWeight.w500,

)

```



This is particularly useful for small labels such as:



```text

NEW ARRIVALS

COLLECTION

GOLD RATE

```



\---



\# 9. Spacing System



Use an \*\*8-point spacing system\*\*.



```dart

abstract final class KhSpacing {

&#x20; static const xxs = 4.0;

&#x20; static const xs = 8.0;

&#x20; static const sm = 12.0;

&#x20; static const md = 16.0;

&#x20; static const lg = 24.0;

&#x20; static const xl = 32.0;

&#x20; static const xxl = 40.0;

&#x20; static const xxxl = 48.0;

&#x20; static const huge = 64.0;

&#x20; static const massive = 80.0;

}

```



\### Recommended usage



```text

4   micro spacing

8   icon → text

12  compact component

16  standard component padding

24  section spacing

32  major section spacing

40  page separation

48  hero separation

64+ luxury whitespace

```



\---



\# 10. Page Margins



Mobile:



```text

16–20 px

```



Preferred:



```dart

EdgeInsets.symmetric(horizontal: 20)

```



For editorial/hero sections:



```text

24 px

```



Do not fill every available pixel.



\---



\# 11. Grid



Base grid:



\*\*8 px\*\*



Mobile layout:



```text

20 px page margin

8 px grid

16 px component gap

24 px section gap

```



Product grid:



```text

2 columns

8–12 px gap

```



Collection cards:



```text

Horizontal scrolling

12–16 px gap

```



\---



\# 12. Corner Radius



The system should use \*\*soft but restrained corners\*\*.



```dart

abstract final class KhRadius {

&#x20; static const xs = 4.0;

&#x20; static const sm = 8.0;

&#x20; static const md = 12.0;

&#x20; static const lg = 16.0;

&#x20; static const xl = 20.0;

&#x20; static const pill = 999.0;

}

```



\### Usage



| Component     |   Radius |

| ------------- | -------: |

| Input         |       10 |

| Product image |       12 |

| Card          |    12–16 |

| Bottom sheet  |       20 |

| Button        |       10 |

| Chip          |      999 |

| Avatar        | circular |



Avoid:



```text

Everything = 24/28/32 radius

```



That makes the interface look like a generic modern SaaS app rather than jewellery luxury.



\---



\# 13. Borders



Borders should be extremely subtle.



Default:



```dart

BorderSide(

&#x20; color: KhColors.stone200,

&#x20; width: 1,

)

```



Gold borders should be reserved for:



\* selected item

\* premium state

\* active category

\* important CTA

\* special collection



Never put gold borders around everything.



\---



\# 14. Shadows



The design should be \*\*mostly shadowless\*\*.



Default elevation:



```text

0

```



For floating surfaces:



```dart

BoxShadow(

&#x20; blurRadius: 20,

&#x20; offset: Offset(0, 6),

&#x20; color: Colors.black12,

)

```



But shadows should be:



\* soft

\* large blur

\* low opacity



Avoid dark hard shadows.



\---



\# 15. Images



Jewellery imagery is the primary visual element.



\## Image rules



\### Product images



\* large

\* clean background

\* consistent crop

\* high resolution

\* minimal UI over the image



\### Preferred background



```text

Warm white

Ivory

Very light neutral

```



\### Avoid



\* excessive badges over products

\* text over jewellery

\* multiple competing decorative elements

\* heavy image borders



\---



\# 16. Ornament Decoration System



This is one of the biggest changes from the original Art Deco design.



The new rule:



> \*\*Ornaments are accents, not content.\*\*



Use:



\* thin curved line

\* small ring outline

\* subtle geometric arc

\* tiny four-point diamond

\* thin gold divider

\* miniature jewellery silhouette



Avoid:



\* heavy filigree

\* large decorative borders

\* repeated patterns

\* ornate corners

\* excessive Art Deco geometry



Example:



```text

────────────────────────

&#x20;      ✦

&#x20;  NEW COLLECTION

────────────────────────

```



rather than:



```text

╔══════════════════════╗

║ ✦ ❖ ✦ ❖ ✦ ❖ ✦ ❖   ║

║    NEW COLLECTION    ║

║ ✦ ❖ ✦ ❖ ✦ ❖ ✦ ❖   ║

╚══════════════════════╝

```



\---



\# 17. Icons



Use a \*\*single icon family\*\* throughout the application.



Recommended:



\*\*Material Symbols / Material Icons\*\*



Style:



```text

Outlined

Thin

Simple

Geometric

```



Avoid mixing:



```text

Material + FontAwesome + custom filled icons + emoji

```



Icon size:



```text

20 px  standard

24 px  primary action

28 px  feature icon

32 px  empty-state icon

```



Gold icons should be used sparingly.



\---



\# 18. App Bar



The app bar should be extremely clean.



\### Default



```text

┌──────────────────────────────────┐

│  ☰          KARAT HIVE       ♡  │

└──────────────────────────────────┘

```



or:



```text

┌──────────────────────────────────┐

│  ←       Collection          ♡   │

└──────────────────────────────────┘

```



\### Rules



\* White/ivory background

\* No heavy elevation

\* Minimal icons

\* Logo has breathing room

\* Height approximately 56–64 px



The earlier design analysis also emphasized giving the brand mark visual breathing room rather than surrounding it with unnecessary utility elements. 



\---



\# 19. Bottom Navigation



Keep it simple.



Recommended:



```text

Home     Requests     Explore     Profile

```



or, depending on the actual Customer flow:



```text

Home     Requests     Activity     Profile

```



\### Navigation styling



Inactive:



```text

Stone 400

```



Active:



```text

Charcoal

\+

small champagne indicator

```



Do \*\*not\*\* make the entire active navigation item gold.



\---



\# 20. Buttons



\## Primary button



```text

┌──────────────────────────┐

│       Continue           │

└──────────────────────────┘

```



Characteristics:



\* Charcoal background

\* White text

\* 48–52 px height

\* 10 px radius



```dart

FilledButton(

&#x20; onPressed: () {},

&#x20; child: const Text('Continue'),

);

```



\---



\## Luxury CTA



For special actions:



```text

┌──────────────────────────┐

│     MARK AS INTERESTED   │

└──────────────────────────┘

```



Use:



```text

Champagne / gold

Dark text

```



Only for high-value actions.



\---



\## Secondary button



```text

┌──────────────────────────┐

│        View All          │

└──────────────────────────┘

```



Outlined or text-based.



\---



\# 21. Text Buttons



Prefer text actions where possible:



```text

View all →

Compare

Edit

Remove

```



This reduces visual noise.



\---



\# 22. Cards



Cards should \*\*not be everywhere\*\*.



Use cards only when information needs grouping.



\### Product card



```text

┌─────────────────────┐

│                     │

│      PRODUCT        │

│       IMAGE         │

│                     │

├─────────────────────┤

│ GOLD RING           │

│ 22K                 │

│ AED 4,850           │

└─────────────────────┘

```



No unnecessary:



\* shadows

\* badges

\* decorative borders

\* multiple metadata rows



\---



\# 23. Product Card Typography



Example:



```text

22K GOLD

Classic Band



AED 4,850

```



The product name should be the strongest text.



Price:



```text

AED 4,850

```



should be visually prominent but not oversized.



\---



\# 24. Category Selector



Use simple circular or rounded-square imagery.



Example:



```text

&#x20;  ○       ○       ○       ○

&#x20;Ring    Chain   Bangle  Earrings

```



Selected:



```text

gold outline

```



Unselected:



```text

stone outline

```



The original analysis proposed circular jewellery category navigation; that structure remains useful, but the interaction should now be visually quieter. 



\---



\# 25. Search



Search should feel like part of the content rather than a large app-control block.



```text

┌────────────────────────────────┐

│  ⌕  Search jewellery           │

└────────────────────────────────┘

```



Properties:



```text

Height: 48

Radius: 12

Background: stone50

Border: none

```



Focus:



```text

1 px champagne border

```



\---



\# 26. Chips



Use chips for:



\* purity

\* category

\* region

\* request type

\* filters



Example:



```text

\[ 22K ] \[ 24K ] \[ 18K ]

```



Selected:



```text

Charcoal background

White text

```



or a subtle champagne outline.



Avoid colorful chips.



\---



\# 27. Forms



Forms should be extremely clean.



\### Input



```text

Jewellery Type



┌──────────────────────────────┐

│ Select jewellery type     ˅  │

└──────────────────────────────┘

```



Label:



```text

12–13 px

medium

charcoal

```



Input:



```text

16 px

```



Error:



```text

12 px

error color

```



\---



\# 28. Request Creation UX



For Karat Hive specifically, the request flow should feel like a \*\*guided luxury concierge experience\*\*, not an ERP form.



Instead of:



```text

Jewellery Type

Weight

Purity

Budget

Region

Category

Notes

Images

...

```



Use progressive disclosure.



\### Step 1



```text

What are you looking for?



\[ Find an Ornament ]



\[ Sell Old Gold ]



\[ Gold Coins ]



\[ Gold Bullion ]

```



\### Step 2



Only then reveal relevant fields.



This follows the SRS's requirement for type-specific guided Request creation. 



\---



\# 29. Offer Cards



Offer comparison is one of the most important screens.



Keep it highly readable.



```text

Verified Jeweller

Dubai



AED 4,850



22K · 8.4g



Making     AED 320

Ready      2 days



★ 4.8



&#x20;            \[ View Offer ]

```



The Vendor identity remains masked until acceptance, as required by the marketplace flow. 



\---



\# 30. Offer Comparison



The comparison screen should use a \*\*clean comparison table\*\*, not huge cards.



```text

&#x20;             Offer A     Offer B     Offer C



Price         AED 4,850   AED 4,920   AED 5,010

Making        320         280         350

Ready         2 days      1 day       3 days

Rating        4.8         4.6         4.9



&#x20;            \[ Mark as Interested ]

```



Use subtle highlighting for differences.



\---



\# 31. Status System



Status should use \*\*semantic colors\*\*, not arbitrary colors.



| Status               | Treatment       |

| -------------------- | --------------- |

| Active               | muted green     |

| Pending              | muted amber     |

| Expired              | muted grey      |

| Rejected             | muted red       |

| Accepted             | champagne/green |

| Draft                | grey            |

| Cancelled            | grey            |

| Verification pending | amber           |



Keep status badges small.



\---



\# 32. Empty States



Do not fill empty states with illustrations and paragraphs.



Use:



```text

&#x20;       ♢



No offers yet



Your request is still open.



```



That's enough.



\---



\# 33. Loading States



Use skeleton loading rather than spinners wherever possible.



Example:



```text

████████████████

████████



████████████

██████

```



Skeleton color:



```text

stone100

```



Animation:



```text

subtle shimmer

```



\---



\# 34. Error States



Keep errors calm.



Instead of:



> Something went terribly wrong!



Use:



```text

Couldn't load offers



Please try again.



\[ Retry ]

```



\---



\# 35. Dialogs



Dialogs should be used only for:



\* destructive actions

\* irreversible actions

\* confirmation

\* important decisions



Example:



```text

Mark as Interested?



Your identity will be revealed

to this jeweller.



This cannot be undone.



Cancel       Continue

```



This is especially important for the Offer acceptance flow because acceptance triggers mutual identity reveal and is irreversible. 



\---



\# 36. Bottom Sheets



Prefer bottom sheets for:



\* filters

\* sorting

\* selecting categories

\* choosing purity

\* choosing region



Example:



```text

Filters



Purity

\[22K] \[24K] \[18K]



Price

────────●────────



Region

Dubai

Abu Dhabi

Sharjah



&#x20;             \[ Apply ]

```



\---



\# 37. Motion



Motion should be \*\*slow, subtle and deliberate\*\*.



Default:



```dart

Duration(milliseconds: 200)

```



Luxury transitions:



```dart

Duration(milliseconds: 300)

```



Avoid:



\* bouncing cards

\* excessive scaling

\* dramatic parallax

\* spinning jewellery

\* flashy animations



The original analysis discussed sophisticated Bézier-based micro-interactions; the simplified system keeps the principle of smooth easing while deliberately reducing visual movement. 



\---



\# 38. Interaction Feedback



Every interaction should have a response:



```text

Tap

&#x20;↓

Subtle state change

&#x20;↓

Action confirmation

```



Examples:



\* button → slight opacity change

\* card → subtle scale 0.99

\* selection → champagne border

\* favorite → icon transition

\* submission → success confirmation



No exaggerated animations.



\---



\# 39. Accessibility



The system should target \*\*WCAG 2.2 AA principles\*\* where applicable.



Important rules:



```text

Minimum touch target: 44 × 44

```



Do not rely on gold alone to communicate state.



For example:



```text

Selected

✓ + gold border

```



rather than:



```text

gold border only

```



The design analysis specifically calls out contrast requirements for text and interactive elements. 



\---



\# 40. Arabic / RTL



Karat Hive supports English and Arabic.



The UI system must therefore support:



```dart

Directionality(

&#x20; textDirection: TextDirection.rtl,

&#x20; child: ...

)

```



Do not simply mirror screenshots.



The following should automatically adapt:



\* padding

\* navigation

\* arrows

\* alignment

\* icon placement

\* text direction

\* horizontal lists

\* forms



The SRS explicitly requires immediate English/Arabic switching with correct RTL layout. 



\---



\# 41. Responsive Rules



The system should not rely on fixed screen sizes.



Use adaptive layouts:



```text

Compact

< 600dp



Medium

600–840dp



Expanded

> 840dp

```



Mobile remains the primary experience.



For Flutter:



```dart

LayoutBuilder(

&#x20; builder: (context, constraints) {

&#x20;   if (constraints.maxWidth < 600) {

&#x20;     return const CompactLayout();

&#x20;   }



&#x20;   return const ExpandedLayout();

&#x20; },

);

```



\---



\# 42. Material 3 Configuration



Use Material 3 as the technical foundation.



```dart

ThemeData(

&#x20; useMaterial3: true,

&#x20; colorScheme: ColorScheme.fromSeed(

&#x20;   seedColor: KhColors.champagne,

&#x20;   brightness: Brightness.light,

&#x20; ),

&#x20; scaffoldBackgroundColor: KhColors.ivory,

);

```



But don't rely on the generated Material theme blindly.



Override:



\* typography

\* button styles

\* input decoration

\* navigation bar

\* cards

\* dialogs

\* chips

\* app bars



\---



\# 43. Flutter Theme Architecture



I would structure it like this:



```text

lib/

└── core/

&#x20;   └── theme/

&#x20;       ├── kh\_colors.dart

&#x20;       ├── kh\_typography.dart

&#x20;       ├── kh\_spacing.dart

&#x20;       ├── kh\_radius.dart

&#x20;       ├── kh\_elevation.dart

&#x20;       ├── kh\_theme.dart

&#x20;       ├── kh\_component\_theme.dart

&#x20;       └── kh\_theme\_extensions.dart

```



Then:



```dart

MaterialApp.router(

&#x20; theme: KhTheme.light,

&#x20; darkTheme: KhTheme.dark,

&#x20; themeMode: ThemeMode.system,

);

```



\---



\# 44. Component Library



Create reusable components rather than styling screens individually.



```text

KhAppBar

KhButton

KhSecondaryButton

KhTextButton

KhIconButton

KhSearchField

KhTextField

KhDropdown

KhChip

KhStatusChip

KhProductCard

KhCollectionCard

KhVendorCard

KhOfferCard

KhRating

KhPrice

KhSectionHeader

KhEmptyState

KhErrorState

KhLoadingState

KhBottomSheet

KhConfirmationDialog

KhAvatar

KhDivider

KhImage

```



This is important for maintaining consistency across the Customer and Vendor modes.



\---



\# 45. Design Token Naming



Use semantic names rather than visual names.



\### Bad



```dart

goldButtonColor

darkTextColor

lightCardColor

```



\### Good



```dart

colorActionPrimary

colorTextPrimary

colorSurface

colorBorder

```



This makes future redesigns dramatically easier.



\---



\# 46. Screen-Level Composition



A typical screen should follow:



```text

Scaffold

│

├── AppBar

│

└── CustomScrollView

&#x20;   │

&#x20;   ├── Hero / Intro

&#x20;   │

&#x20;   ├── Section

&#x20;   │

&#x20;   ├── Content

&#x20;   │

&#x20;   ├── Section

&#x20;   │

&#x20;   └── Content

```



Do \*\*not\*\* build screens as:



```text

Container

&#x20; Container

&#x20;   Card

&#x20;     Container

&#x20;       Card

&#x20;         Container

```



That creates the crowded UI we are deliberately trying to avoid.



\---



\# 47. Content Density



This is one of the most important rules.



\### Customer



\*\*Low density\*\*



```text

Large imagery

Large whitespace

Few decisions

Short text

```



\### Vendor



\*\*Medium/high density\*\*



Because the Vendor monitors Requests and Offers frequently, the UI can become denser:



```text

More information

More filters

More status

More compact rows

```



This is consistent with the SRS distinction between the Customer's occasional, intent-driven use and the Vendor's frequent working-tool usage. 



\---



\# 48. Customer vs Vendor Visual Density



|            | Customer  | Vendor      |

| ---------- | --------- | ----------- |

| Whitespace | High      | Medium      |

| Images     | High      | Medium      |

| Text       | Low       | Medium      |

| Filters    | Minimal   | Extensive   |

| Cards      | Large     | Compact     |

| Metadata   | Minimal   | More        |

| Navigation | Simple    | Functional  |

| Dashboard  | Editorial | Operational |



This allows both modes to live in the same application without forcing identical layouts.



\---



\# 49. Photography Rules



Photography should carry the luxury feeling.



Use:



```text

Soft lighting

Neutral backgrounds

High detail

Natural shadows

Close-up jewellery

Editorial composition

```



Avoid:



```text

Busy backgrounds

Stock-photo feel

Oversaturated gold

Heavy props

Text embedded into images

```



\---



\# 50. The "Tiffany Principle"



For this new direction, I would define a specific rule:



> \*\*If removing a decorative element makes the jewellery more prominent, remove it.\*\*



Therefore:



```text

More whitespace

\+

Less ornament

\+

Less text

\+

Better photography

\+

Precise typography

=

Luxury

```



Not:



```text

More gold

\+

More borders

\+

More ornaments

\+

More gradients

=

Luxury

```



\---



\# 51. Screen Composition Rule



Every screen should have a \*\*single visual priority\*\*.



For example:



\### Home



```text

Brand

↓

Hero

↓

Request actions

↓

Featured content

```



\### Request Detail



```text

Request

↓

Jewellery

↓

Specifications

↓

Offers

```



\### Offer Detail



```text

Price

↓

Terms

↓

Vendor trust signals

↓

Action

```



\### Profile



```text

Identity

↓

Account

↓

Preferences

```



\---



\# 52. The 70/20/10 Visual Rule



A useful implementation guideline:



```text

70%  Neutral space / surfaces

20%  Content / imagery

10%  Brand accent

```



Gold should normally live inside that final 10%.



This keeps the interface sophisticated rather than decorative.



\---



\# 53. What We Should Explicitly Avoid



The Flutter implementation should \*\*not\*\* introduce these unless specifically required:



```text

❌ Excessive gold backgrounds

❌ Heavy Art Deco borders

❌ Filigree everywhere

❌ Large gradients

❌ Glassmorphism

❌ Excessive shadows

❌ Giant text blocks

❌ Long descriptions

❌ Too many badges

❌ Too many pills

❌ Rainbow status colors

❌ Dense dashboards for customers

❌ Every section inside a Card

❌ Decorative icons with no function

❌ Excessive animations

```



\---



\# 54. Final Design Language



The complete Karat Hive visual language can be expressed as:



> \*\*Modern Luxury Jewellery Editorial\*\*



\### Color



\*\*Ivory + Warm White + Charcoal + Champagne Gold\*\*



\### Typography



\*\*Cormorant Garamond + Inter\*\*



\### Geometry



\*\*Soft 8–16 px corners + thin borders\*\*



\### Layout



\*\*Large whitespace + strong alignment\*\*



\### Imagery



\*\*Large, clean jewellery photography\*\*



\### Ornament



\*\*Minimal, thin, geometric\*\*



\### Interaction



\*\*Subtle and tactile\*\*



\### Content



\*\*Short and purposeful\*\*



\### Architecture



\*\*Material 3 + semantic design tokens + reusable Flutter components\*\*



\### Overall feeling



\*\*Quiet, premium, confident, uncluttered.\*\*



\---



\## Recommended Flutter foundation



I would make the design system a \*\*first-class package inside the project\*\*, rather than styling individual screens:



```text

packages/

└── karat\_hive\_design/

&#x20;   ├── lib/

&#x20;   │   ├── src/

&#x20;   │   │   ├── tokens/

&#x20;   │   │   │   ├── colors.dart

&#x20;   │   │   │   ├── typography.dart

&#x20;   │   │   │   ├── spacing.dart

&#x20;   │   │   │   ├── radius.dart

&#x20;   │   │   │   └── motion.dart

&#x20;   │   │   │

&#x20;   │   │   ├── theme/

&#x20;   │   │   │   ├── theme.dart

&#x20;   │   │   │   └── component\_theme.dart

&#x20;   │   │   │

&#x20;   │   │   └── components/

&#x20;   │   │       ├── buttons/

&#x20;   │   │       ├── cards/

&#x20;   │   │       ├── inputs/

&#x20;   │   │       ├── navigation/

&#x20;   │   │       ├── feedback/

&#x20;   │   │       └── jewellery/

&#x20;   │   │

&#x20;   │   └── karat\_hive\_design.dart

```



That gives us a \*\*single source of truth\*\* for the entire Customer/Vendor application. If we later decide to make the UI even lighter, change the palette, adjust corner radii, or introduce dark mode, we can do it at the design-system level rather than rewriting screens.



\*\*This should be treated as the UI contract for the Flutter implementation.\*\*



