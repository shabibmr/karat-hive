# Archived documents

Superseded versions, kept for history. **Do not edit, and do not treat as current.**

The authoritative specification is [`docs/Requirements-Spec-v1.6.md`](../Requirements-Spec-v1.6.md).

| File | Version | Superseded by | Reason |
|---|---|---|---|
| `Requirements-Spec.md` | 1.0 — 10 Aug 2026 | v1.1 | Product Owner walk decisions |
| `Requirements-Spec-v1.1.md` | 1.1 — 10 Aug 2026 | v1.2 | Technology stack added to `Requirements-raw.txt` (L96–L103) |
| `Requirements-Spec-v1.2.md` | 1.2 — 10 Aug 2026 | v1.3 | C-10 confirmed (Admin Portal = Flutter Web); C-13 resolved (object storage → Cloudflare R2 + MinIO); new ADR `0008` |
| `Requirements-Spec-v1.3.md` | 1.3 — 1 Sep 2026 | v1.4 | `FR-CUS-006` AC3 relaxed — ornament type and purity karat are now optional on a *Find An Ornament* Request |
| `Requirements-Spec-v1.4.md` | 1.4 — 20 Sep 2026 | v1.5 | Complete removal of Category taxonomy entity (ADR 0014); matching simplified to Type Subscription only; Region retained as display filter; unconditional Vendor activation on VERIFIED |
| `Requirements-Spec-v1.5.md` | 1.5 — 26 Sep 2026 | v1.6 | ADRs 0010, 0011, 0013, 0014 and 0015 folded in: Google-only login, Guest-first launch, Oracle object storage, Category removal completed, Offers live with their Request (no revision, no `OFFERS_RECEIVED`) |

## Other superseded documents

| File | Originally at | Superseded by | Reason |
|---|---|---|---|
| `Karat_Hive_UI_Design_Context.md` | `ui-screens/` | [`UI-Design-Context-1a-Classic.md`](UI-Design-Context-1a-Classic.md) (then at `apps/kh_mobile/karat_hive/docs/UI-Design-Context.md`) — 26 Sep 2026 | Dark sapphire / `#D4AF37` Art Deco direction replaced by the light ivory / ink / `#C8A046` "1a Classic" direction from the design handoff. Superseded for `kh_mobile` only: `kh_admin` deliberately keeps its own theme (`lib/core/design/theme/`), built from this version (decided 26 Sep 2026). `ui-mock/` was also built from it and has not yet been re-based |
| `UI-Design-Context-1a-Classic.md` | `apps/kh_mobile/karat_hive/docs/UI-Design-Context.md` | [`apps/kh_mobile/karat_hive/docs/UI-Design-Context.md`](../../apps/kh_mobile/karat_hive/docs/UI-Design-Context.md) — 30 Sep 2026 | Direction 1a "Classic" (from the 1a design handoff, since removed) replaced by the "Modern Luxury Jewellery Editorial" system from `apps/kh_mobile/designs/design-System.md`, with the champagne visual-pass locks (now its §0) on top: `gold` `#D8A858`, `ctaFill` CTAs at radius 10, `goldDark` nav selection, `formSurface` create screens. Its relative links are left as written and no longer resolve from this folder |

`docs/Requirements-raw.txt` is **not** archived: it is the original brief and remains the live traceability source that every requirement's `Source` field and Appendix B cite.
