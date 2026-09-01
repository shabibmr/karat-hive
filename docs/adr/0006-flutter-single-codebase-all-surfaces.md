# Flutter as the single client framework across all surfaces

All three user surfaces are built in Flutter from one toolchain: the dual-mode mobile app (iOS + Android) and the Admin Portal as a Flutter Web target. There is no separate DOM-based web application. Prescribed by `docs/Requirements-raw.txt` L97–L98; recorded as constraint C-10.

**Why.** One language, one widget model, and one set of domain models across every surface: the Request, Offer, and Connection types, the masking rules, and the AED/karat formatting are written once. With a small team this matters more than per-surface optimality, and the Admin Portal is an internal tool for single-digit staff — its user count does not justify a second frontend stack.

**Consequences.** Admin is the weakest fit. Flutter Web renders to canvas rather than DOM, so browser text selection, find-in-page, screen-reader semantics, and native table affordances are not free — `NFR-023` keyboard operability becomes an explicit test gate rather than an assumption. There is no first-party data grid, so the dense list screens (`ADM-S03`…`ADM-S12`, widget `SH-ADM-02`) need a build-or-buy decision early. Initial web payload size is larger than a DOM app, which is acceptable for an authenticated internal tool and would not be for a public site.

**Assumed, not stated.** The source says Flutter targets "IOS/Android/Web" but never binds the Admin Portal to that web target. This ADR assumes it does. If the Product Owner intends a separate DOM-based Admin application, this decision and the §7.1 / `NFR-023` caveats revert, and Admin delivery becomes materially lower-risk.

**Considered options.** Flutter mobile + React/DOM Admin (better Admin ergonomics, second stack to staff and maintain); React Native + web (contradicts the prescribed stack); native iOS + native Android (three codebases, rejected outright).
