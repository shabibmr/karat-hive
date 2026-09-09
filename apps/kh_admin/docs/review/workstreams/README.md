# Admin Portal — workstream work orders (v1)

Per-stream work orders for the parallel-execution cut of the admin review. Master plan (streams, conflict hot-spots, file ownership, sequencing, identifier index): [`../implementation-workstreams-v1.md`](../implementation-workstreams-v1.md).

Findings are not reworded — each file pulls the relevant `E*` / `ADM-SMP-*` / `ADM-INS-*` items out of [`../comprehensive-review.md`](../comprehensive-review.md) and states files touched, action, dependencies and done-when.

| File | Stream | Owner shape | Depends on |
|---|---|---|---|
| [`s0-foundation-v1.md`](s0-foundation-v1.md) | S0 · Foundation | 1 agent, 2 PRs, serial | — |
| [`s1-list-data-spine-v1.md`](s1-list-data-spine-v1.md) | S1 · List-data spine | 1 agent, sequential, ~50% of effort | S0 |
| [`s2-detail-screens-v1.md`](s2-detail-screens-v1.md) | S2 · Detail screens | primitives, then 1 agent/screen | S0 |
| [`s3-shared-widgets-perf-v1.md`](s3-shared-widgets-perf-v1.md) | S3 · Shared widgets & perf | 1 agent; per-list after S1 | S0, then S1 per-list |
| [`s4-app-shell-platform-v1.md`](s4-app-shell-platform-v1.md) | S4 · App-shell / bootstrap / platform | 1 agent | S0; S1 for `pubspec` |
| [`s5-i18n-a11y-v1.md`](s5-i18n-a11y-v1.md) | S5 · i18n & a11y sweep | 1 agent, per-screen, merges last | S1, S2 |
| [`s6-feature-completion-v1.md`](s6-feature-completion-v1.md) | S6 · Feature completion | 1–2 agents | S0; S1 for abuse |
| [`s7-testing-v1.md`](s7-testing-v1.md) | S7 · Testing | 1 agent, start wave 0 | — |
| [`s8-docs-carve-v1.md`](s8-docs-carve-v1.md) | S8 · Docs carve | 1 agent, no code | confirm `SDC-07`/`SDC-08` |

**Waves:** 0 → S0 + S7 + S8 · 1 → S1, S2, S4, S3 (build only), S6 (dashboard) · 2 → S3 per-list, S5 sweep, S6 abuse, S7 goldens/e2e.
