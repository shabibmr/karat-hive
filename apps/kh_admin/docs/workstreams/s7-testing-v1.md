# S7 · Testing

> Work order derived from [`../comprehensive-review.md`](../comprehensive-review.md) §3.3.6. Line numbers are HEAD `8880298` artefacts.

| | |
|---|---|
| **Goal** | Close the test gaps; add goldens, an integration test, and a CI size budget. |
| **Owner** | 1 agent. |
| **Parallelism** | Fully parallel — **start in wave 0**. Additive-only, never conflicts. |
| **Depends on** | — (but goldens / integration tests for screens being restructured land **after** S2/S3 touch them). |
| **Blocks** | — |
| **Owns** | `test/**`, `integration_test/**` (new), `.github/workflows/frontend.yml` |

## Existing state (do not regress)
Present: API client, session, most query-params, most feature controller/repository/screen tests, shared widget tests, one responsive test. Hand fakes + `ProviderScope` overrides, no mocktail/mockito — keep that style. 352 tests passing. 3 pre-existing analyzer issues, all in `test/`.

## `E18` / `ADM-INS-39` — missing feature tests (cheap first)
| Missing | |
|---|---|
| `test/features/requests/request_list_screen_test.dart` | empty / error / loading — **do this first** |
| `request_detail_controller`, `offer_detail_controller`, `vendor_detail_controller` | untested |
| `audit`, `dashboard`, `reports` controllers | untested (repos are tested) |
| `taxonomy` repository | untested (controller + screen are) |
| `verification_query_params` | untested (other query-param helpers are) |
| Boolean-soup list controllers | no exclusive-state-transition test (loading→error, retry) — add against S1's kernel once it lands |

Also fix the 2 existing warnings: unused import in `announcements_screen_test.dart`; unused fake params in `platform_settings_controller_test.dart`.

## `E25` / `ADM-INS-01` — goldens
LTR + RTL + 200% text-scale goldens for `KhStatusChip`, `KhDataTable`, `KhMetricCard`, `KhScreenHeader`. Add goldens for S2's new detail primitives (`KhDetailCard`, `KhDetailRow`, `KhFeedbackBanner`) as they land.

## `E28` / `ADM-INS-80` / `ADM-INS-84` — integration test + CI budget
- One `integration_test`: login → dashboard → one list → detail, against a seeded Chrome.
- CI: track compressed main-js size in the `frontend.yml` `admin` job (it builds web today but does not measure). Fail on regression past a threshold.
- Fail CI on `flutter analyze` warnings scoped to `apps/kh_admin`.

## Sequencing note
Screen-level goldens and the integration test for `request_detail` / `offer_detail` / list screens should be written or re-baselined **after** S2 splits them and S3 virtualises the table — otherwise they get thrown away. The controller/repository tests above have no such dependency; do them now.

## Verification
`flutter test` + `flutter test integration_test` green; CI shows the size number; `flutter analyze` warning count for `apps/kh_admin` is 0.
