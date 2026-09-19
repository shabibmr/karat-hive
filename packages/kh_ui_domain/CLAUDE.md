# kh_ui_domain

Widgets that know the domain: request/offer/connection cards, `MaskedPartyLabel`, purity and karat pickers, money input and display, gold-rate strip, expiry countdown, rating views, notification lists.

This is the layer above `kh_design_system`: it may depend on `kh_domain`, `kh_core`, `kh_l10n` and the design system, and must not depend on any app or on `kh_api`. A widget that fetches is in the wrong package — these take domain objects in and emit callbacks out.

**Split test:** styling with no domain knowledge belongs in `kh_design_system`; anything that names a Request, an Offer, a Karat or a Party belongs here.

Identity widgets are the reason this package exists — `MaskedPartyLabel` and friends render `MaskedParty` and `RevealedParty` as separate cases. Keep them exhaustive over the union rather than reading optional fields.

Copy comes from `kh_l10n`; the hard-coded-string lint applies here too.

Add new widgets to the `lib/kh_ui_domain.dart` barrel and cover them under `test/`.
