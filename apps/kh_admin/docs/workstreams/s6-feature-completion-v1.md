# S6 · Feature completion

> Work order derived from [`../comprehensive-review.md`](../comprehensive-review.md) §3.3.12 and §3.4 (E4, E21, E22). Line numbers are HEAD `8880298` artefacts.

| | |
|---|---|
| **Goal** | Close the three feature gaps that are product-visible but architecture-local. |
| **Owner** | 1–2 agents (dashboard/reports vs abuse). |
| **Parallelism** | Isolated feature folders. |
| **Depends on** | S0. Dashboard is already `AsyncNotifier` and can start in wave 1. **Abuse waits for S1** to migrate `features/abuse` (Family B) onto the kernel. |
| **Blocks** | — |
| **Owns** | `lib/features/dashboard/`, `lib/features/reports/`, `lib/features/abuse/` (behaviour, after S1) |

## `E4` / `ADM-INS-61` — dashboard queues fail closed
- **Now:** dashboard queue sources return `[]` on any throw, so a down verification API looks like an empty queue. (`catch` without `on` swallows the failure — `ADM-INS-61`.)
- **Do:** each queue source carries its own state — a per-source error chip with a retry, not a vanished section. Use the S0 `E3` error helper for the message.
- **Done when:** killing the verification endpoint shows an error chip on that queue, not "0 pending".

## `E21` / `ADM-INS-32` — dashboard depth
- **Now:** dashboard is a static snapshot — no date range, no trends, no drill-down.
- **Do:** date-range selector, trend series, and a drill-down query that deep-links into the relevant filtered list (uses S1's query codec).
- **Done when:** the admin can pick a range, see a trend, and click through to the underlying list pre-filtered.

## `E22` / `ADM-INS-38` — abuse actions
- **Now:** the abuse queue lists reports but has no actions.
- **Do:** warn / suspend / deactivate actions on an abuse report, wired to the admin API (coordinate with `docs/admin-backend-api-gaps.md` for any missing routes). Confirm the action set against `FR-ADM-032` (`[ASSUMED]` — may need Product sign-off).
- **Depends on:** `features/abuse` on the S1 kernel first.
- **Done when:** an admin can action a report and the list reflects the new state.

## Verification
`flutter analyze && flutter test`; exercise each feature against a seeded backend; narrow + wide viewport.
