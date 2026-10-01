# Customer Home implementation

Visual specification: [Home-1.png](Home-1.png). Earlier UI documents were not used as constraints.

Rendered Flutter preview: [Customer-Home-Flutter.png](Customer-Home-Flutter.png).

The screen uses a centered brand mark and wordmark, a notification bell with real unread state, a customer initial avatar, a photographic three-slide carousel, and a two-column grid of four service cards. Each card has a curved cream label panel, serif title, and circular arrow. Customer navigation shows Home, Requests, Connections, and Profile. The Alerts route remains reachable through the bell and existing deep links.

The service cards continue to open their corresponding request creation flows. The pending-publication retry banner remains available when needed. Content can scroll on smaller screens and with enlarged text.

The implementation reuses the existing carousel, service card, service grid, and bottom navigation with an optional photographic style. Other consumers retain their existing default appearance.

## Artwork

The four service photographs were copied from the supplied `find-ornament-img.png`, `sell-old-img.png`, `coin-img.png`, and `bullion-img.png` assets. They differ from the exact jewellery shown in the reference. The brand mark is drawn as a Flutter vector, and the typography uses the project's bundled Cormorant Garamond and DM Sans fonts. This is a working widget implementation, not the reference screenshot displayed as the UI.

The hero photograph was generated using the built-in image generation tool and the imagegen skill. Its project path is `apps/kh_mobile/karat_hive/assets/home/hero-bangle.png`.

Final generation prompt:

> Use case: product-mockup. Input image is a composition reference for ONLY the large hero photograph at x63,y201 to x806,y694 in this mobile screen. Generate a standalone landscape 3:2 high-resolution photographic background matching that hero photograph as closely as possible: a thin polished yellow-gold bangle tilted diagonally upward right, on a round ivory travertine stone pedestal at the bottom right, a tall rounded limestone stone behind at upper right, warm pale cream wall background, diagonal sunlight and gentle shadows. Match bracelet scale and position: bracelet occupies right half, centered around 70% x, 62% y; left 45% is empty soft cream stone wall with generous space for Flutter headline. This is just the photography asset. NO text, lettering, icons, dots, arrows, buttons, rounded outer corners, phone frame or UI. No dark vignette. Preserve delicate fine stone texture, refined warm-white palette and reference perspective.

## Verification

The Flutter visual regression test loads the real fonts and image assets and renders the actual Customer Home and Customer Shell at 390 × 870. Interaction tests cover the carousel, reduced motion, profile and bell actions, request creation, pending publication, four-tab routing, and Alerts deep links. Layout checks cover 320, 390, and 1024 logical pixels in English and Arabic, plus 200% text at 320 pixels.

The preview includes only app-rendered content. The operating system supplies the status bar and home indicator on a device.

Final result: 45 app regression tests and 21 shared foundation/navigation tests passed. Analysis of the changed implementation found no errors or warnings; existing informational import lints remain. The installed files were verified against the tested staging copy by checksum, and `git diff --check` passed.

Replaced source files were backed up under `/private/tmp/karat-home.5r5jgB/before-install`.
