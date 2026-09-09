# Vendor App Completion — Orchestrator DAG

| | |
|---|---|
| **Product** | Karat Hive |
| **Document** | Incomplete Vendor tasks as a ready-queue DAG |
| **Parents** | [`Vendor-App-Completion-Tasks.md`](Vendor-App-Completion-Tasks.md) |
| **Backend evidence** | [`Vendor-App-Backend-Followup-Tasks.md`](Vendor-App-Backend-Followup-Tasks.md) |
| **Date** | 8 September 2026 |

**Orchestrator:** a task is **ready** when every `depends_on` ID is `done`. Tasks in the **same wave** are independent after mutex is applied — run them in parallel up to concurrency. Never start a later wave until the current wave is done.

**Do not assign** (register `open`, code already landed): `CP4-A01`–`A05`, `CP4-A07`, `CP5-A01`, `CP5-A03`, `CP5-A06`–`A09`, `CP6-A04`, `CP6-A05`, `CP2-I01`.

**Mutex:** two tasks that share a `mutex` key must **not** run in the same wave (same file / barrel). Logical `depends_on` already serialises those pairs.

Child IDs are `Parent.n`. Never reuse. Tick the parent only when every child is `done`.

Do not invent routes, fields, error codes, or widget IDs.

---

## Orchestrator contract

```
level(task) = 0                         if depends_on is empty
level(task) = 1 + max(level(dep))       otherwise
```

Waves below **are** those levels after mutex edges were added (same-file pairs got an extra `depends_on`).

Ready queue:

1. Load the YAML `tasks` list.
2. `ready = [t for t in tasks if t.status == open and all deps done]`
3. From `ready`, take at most one task per `mutex` value.
4. Launch those in parallel.
5. On failure: skip transitive dependents; continue the rest.

Parse block: [Task DAG (YAML)](#task-dag-yaml) then [PR Plan](#pr-plan) (`### PR N` + `Dependencies:` — same shape as `/execute-plan`).

---

## Waves (parallel groups)

Canonical membership is the YAML `wave` field. Run **wave N** only after waves `0…N-1` are `done`. IDs in the same wave have no `depends_on` into that wave and unique `mutex` keys — launch them together.

| Wave | Parallelism | IDs |
|---|---|---|
| 0 | 14 | CP3-A08.1, CP3-B06.1, CP4-A06.1, CP5-A02.1, CP5-A04, CP5-A05.1, CP5-A05.2, CP5-B01.1, CP5-B03.1, CP5-B05.1, CP5-B06.1, CP5-B06.9, CP5-I01.1, CP6-A02 |
| 1 | 11 | CP3-A08.2, CP3-B06.2, CP4-A06.2, CP5-A02.2, CP5-B03.2, CP5-B06.2, CP5-I01.2, CP6-A01.1, CP6-A03.1, CP6-B03.1, CP6-B05.3 |
| 2 | 9 | CP3-B06.3, CP5-A02.3, CP5-B01.2, CP5-B06.3, CP5-I01.3, CP6-A01.2, CP6-B01.1, CP6-B04.1, CP6-B05.4 |
| 3 | 6 | CP5-B01.3, CP5-B06.4, CP5-B07.1, CP6-A06.1, CP6-B01.2, CP6-B05.5 |
| 4 | 6 | CP5-B01.4, CP5-B06.5, CP6-A06.2, CP6-B01.3, CP6-B02.1, CP6-B04.2 |
| 5 | 3 | CP5-B02, CP5-B06.6, CP6-A06.3 |
| 6 | 3 | CP5-B06.7, CP6-A06.4, CP6-B02.2 |
| 7 | 4 | CP5-B03.3, CP5-B04.1, CP5-B06.8, CP6-B02.3 |
| 8 | 5 | CP5-B03.4, CP5-B04.3, CP5-B05.2, CP6-B02.4, CP6-B05.1 |
| 9 | 5 | CP5-B04.4, CP5-B05.3, CP6-B03.2, CP6-B04.3, CP6-B05.2 |
| 10 | 3 | CP6-B03.3, CP6-B04.4, CP6-B05.6 |
| 11 | 3 | CP5-B04.2, CP6-B03.4, CP6-B04.5 |
| 12 | 1 | CP6-B03.5 |
| 13 | 1 | CP6-B03.6 |

**74 tasks. 14 waves (0–13). Max parallelism: 14.** Orchestrator concurrency cap this run: **5**.

### Live status board

| | |
|---|---|
| **Completion** | **74 / 74 done · 100.0%** |
| Run target | **Waves 0–13 — COMPLETE** · **74 / 74 · 100%** |
| In progress | 0 |
| Failed | 0 |
| Deferred | 0 |

| Wave | Progress | Notes |
|---|---|---|
| 0 | **14/14 · 100%** | Closed |
| 1 | **11/11 · 100%** | Closed |
| 2 | **9/9 · 100%** | Closed |
| 3 | **6/6 · 100%** | Closed |
| 4 | **6/6 · 100%** | Closed |
| 5 | **3/3 · 100%** | Closed |
| 6 | **3/3 · 100%** | Closed |
| 7 | **4/4 · 100%** | Closed |
| 8 | **5/5 · 100%** | Closed |
| 9 | **5/5 · 100%** | Closed |
| 10 | **3/3 · 100%** | Closed |
| 11 | **3/3 · 100%** | Closed |
| 12 | **1/1 · 100%** | Closed |
| 13 | **1/1 · 100%** | Closed |

| Final Wave 11–13 IDs | Status |
|---|---|
| CP5-B04.2 | **done** — VEN-S20 distribution + trend |
| CP6-B03.4 | **done** — VEN-S18 default filter preset |
| CP6-B04.5 | **done** — VEN-S14 CSV export |
| CP6-B03.5 | **done** — VEN-S18 password + sessions |
| CP6-B03.6 | **done** — VEN-S18 legal, version, logout |

---

## Task DAG (YAML)

Canonical. `wave` is precomputed. `mutex` values in the same wave are unique. `status`: `open` \| `in_progress` \| `done` \| `failed`.

```yaml
meta:
  total: 74
  waves: 14
  max_parallelism: 14
  orchestrator_concurrency: 5
  ready_rule: all depends_on done AND mutex free in this wave
  done_count: 74
  in_progress_count: 0
  completion_pct: 100.0
  stop_after_wave: 13
  in_scope_total: 74
  in_scope_done: 74

tasks:
  # ----- wave 0 -----
  - { id: CP4-A06.1, wave: 0, status: done, mutex: connection-service, depends_on: [], files: "backend/src/modules/connections/application/connection.service.ts", title: "Idempotent accept replay" }
  - { id: CP5-A02.1, wave: 0, status: done, mutex: prisma-schema, depends_on: [], files: "backend/prisma/schema.prisma", title: "abuse_report.priority column" }
  - { id: CP5-A04, wave: 0, status: done, mutex: reviews-service, depends_on: [], files: "backend/src/modules/reviews/application/review.service.ts", title: "Review response second POST CONFLICT" }
  - { id: CP5-A05.1, wave: 0, status: done, mutex: reviews-module, depends_on: [], files: "backend/src/modules/reviews/", title: "reviews:rating-recompute consumer" }
  - { id: CP5-A05.2, wave: 0, status: done, mutex: subscription-repo, depends_on: [], files: "backend/src/modules/subscription/repository/subscription.repository.ts", title: "ratingTrend on vendor performance" }
  - { id: CP6-A02, wave: 0, status: done, mutex: auth-backend, depends_on: [], files: "backend/src/modules/identity/controller/auth.controller.ts, backend/src/edge/errors/error-codes.ts", title: "POST /v1/auth/password" }
  - { id: CP3-A08.1, wave: 0, status: done, mutex: offers-int-spec, depends_on: [], files: "backend/test/integration/vendor-offers.spec.ts", title: "Live awardedElsewhere test" }
  - { id: CP3-B06.1, wave: 0, status: done, mutex: offers-vendor-tests, depends_on: [], files: "apps/kh_mobile/karat_hive/test/features/offers_vendor/", title: "VEN-S09 tests" }
  - { id: CP5-B03.1, wave: 0, status: done, mutex: kh-api-reviews, depends_on: [], files: "packages/kh_api/lib/src/clients/reviews_client.dart", title: "ReviewsClient list/response/flag" }
  - { id: CP5-B05.1, wave: 0, status: done, mutex: flutter-abuse, depends_on: [], files: "apps/kh_mobile/karat_hive/lib/features/abuse/", title: "Vendor abuse scaffold" }
  - { id: CP5-B06.1, wave: 0, status: done, mutex: kh-ui-domain, depends_on: [], files: "packages/kh_ui_domain/", title: "SH-NTF-01" }
  - { id: CP5-B06.9, wave: 0, status: done, mutex: kh-design-system, depends_on: [], files: "packages/kh_design_system/", title: "SH-FND-17" }
  - { id: CP5-B01.1, wave: 0, status: done, mutex: vendor-shell-router, depends_on: [], files: "apps/kh_mobile/karat_hive/lib/features/notifications/, apps/kh_mobile/karat_hive/lib/app/shells/vendor_shell.dart, apps/kh_mobile/karat_hive/lib/app/router.dart", title: "Vendor notifications scaffold" }
  - { id: CP5-I01.1, wave: 0, status: done, mutex: notification-catalogue, depends_on: [], files: "docs/Notification-Catalogue.md", title: "Catalogue skeleton" }

  # ----- wave 1 -----
  - { id: CP4-A06.2, wave: 1, status: done, mutex: accept-int-spec, depends_on: [CP4-A06.1], files: "backend/test/integration/acceptance-concurrency.spec.ts", title: "Accept concurrency HTTP spec" }
  - { id: CP5-A02.2, wave: 1, status: done, mutex: abuse-backend, depends_on: [CP5-A02.1], files: "backend/src/modules/abuse/application/abuse.service.ts, backend/src/modules/abuse/repository/abuse.repository.ts", title: "Three-Vendor auto-flag logic" }
  - { id: CP6-A01.1, wave: 1, status: done, mutex: prisma-schema, depends_on: [CP5-A02.1], files: "backend/prisma/schema.prisma, backend/src/modules/settings/", title: "Persist defaultFilterPresetId" }
  - { id: CP6-A03.1, wave: 1, status: done, mutex: subscription-repo, depends_on: [CP5-A05.2], files: "backend/src/modules/subscription/repository/subscription.repository.ts", title: "averageOfferedVsAccepted aggregate" }
  - { id: CP3-A08.2, wave: 1, status: done, mutex: offers-int-spec, depends_on: [CP3-A08.1], files: "backend/test/integration/vendor-offers.spec.ts", title: "Offer expiry sweep test" }
  - { id: CP3-B06.2, wave: 1, status: done, mutex: offers-vendor-tests, depends_on: [CP3-B06.1], files: "apps/kh_mobile/karat_hive/test/features/offers_vendor/", title: "VEN-S10 tests" }
  - { id: CP5-B06.2, wave: 1, status: done, mutex: kh-ui-domain, depends_on: [CP5-B06.1], files: "packages/kh_ui_domain/", title: "SH-NTF-02" }
  - { id: CP6-B05.3, wave: 1, status: done, mutex: kh-design-system, depends_on: [CP5-B06.9], files: "packages/kh_design_system/", title: "SH-FND-06 toggle" }
  - { id: CP5-B03.2, wave: 1, status: done, mutex: flutter-reviews, depends_on: [CP5-B03.1], files: "apps/kh_mobile/karat_hive/lib/features/reviews/", title: "Vendor reviews scaffold" }
  - { id: CP6-B03.1, wave: 1, status: done, mutex: kh-api-auth, depends_on: [CP6-A02], files: "packages/kh_api/lib/src/clients/auth_client.dart", title: "Sessions + password API client" }
  - { id: CP5-I01.2, wave: 1, status: done, mutex: notification-catalogue, depends_on: [CP5-I01.1], files: "docs/Notification-Catalogue.md", title: "Vendor-facing catalogue rows" }

  # ----- wave 2 -----
  - { id: CP5-A02.3, wave: 2, status: done, mutex: abuse-backend, depends_on: [CP5-A02.2], files: "backend/src/modules/abuse/application/abuse.service.spec.ts", title: "Auto-flag spec" }
  - { id: CP6-A01.2, wave: 2, status: done, mutex: settings-backend, depends_on: [CP6-A01.1], files: "backend/src/modules/settings/application/settings.service.ts", title: "Lock security-critical notification categories" }
  - { id: CP3-B06.3, wave: 2, status: done, mutex: offers-vendor-tests, depends_on: [CP3-B06.2], files: "apps/kh_mobile/karat_hive/test/features/offers_vendor/", title: "VEN-S11 tests" }
  - { id: CP5-B06.3, wave: 2, status: done, mutex: kh-ui-domain, depends_on: [CP5-B06.2], files: "packages/kh_ui_domain/", title: "SH-NTF-03" }
  - { id: CP6-B05.4, wave: 2, status: done, mutex: kh-design-system, depends_on: [CP6-B05.3], files: "packages/kh_design_system/", title: "SH-FND-09 + SH-FND-10" }
  - { id: CP5-B01.2, wave: 2, status: done, mutex: flutter-notifications, depends_on: [CP5-B01.1, CP5-B06.1, CP5-B06.2], files: "apps/kh_mobile/karat_hive/lib/features/notifications/presentation/", title: "VEN-S17 list screen" }
  - { id: CP6-B01.1, wave: 2, status: done, mutex: vendor-shell-router, depends_on: [CP5-B01.1], files: "apps/kh_mobile/karat_hive/lib/app/shells/vendor_shell.dart, apps/kh_mobile/karat_hive/lib/app/router.dart", title: "Enable Vendor Profile tab" }
  - { id: CP5-I01.3, wave: 2, status: done, mutex: notification-catalogue, depends_on: [CP5-I01.2], files: "docs/Notification-Catalogue.md", title: "Remaining catalogue rows" }
  - { id: CP6-B04.1, wave: 2, status: done, mutex: kh-api-performance, depends_on: [CP6-A03.1, CP5-A05.2], files: "packages/kh_api/", title: "Performance + export API client" }

  # ----- wave 3 -----
  - { id: CP6-A06.1, wave: 3, status: done, mutex: settings-int-spec, depends_on: [CP6-A01.1, CP6-A01.2], files: "backend/test/integration/vendor-settings.spec.ts", title: "Settings round-trip spec" }
  - { id: CP5-B06.4, wave: 3, status: done, mutex: kh-ui-domain, depends_on: [CP5-B06.3], files: "packages/kh_ui_domain/", title: "SH-ID-03" }
  - { id: CP6-B05.5, wave: 3, status: done, mutex: kh-design-system, depends_on: [CP6-B05.4], files: "packages/kh_design_system/", title: "SH-FND-23 + SH-FND-24" }
  - { id: CP5-B01.3, wave: 3, status: done, mutex: flutter-notifications, depends_on: [CP5-B01.2], files: "apps/kh_mobile/karat_hive/lib/features/notifications/, apps/kh_mobile/karat_hive/lib/app/", title: "Notification deep-link resolver" }
  - { id: CP6-B01.2, wave: 3, status: done, mutex: flutter-profile-settings, depends_on: [CP6-B01.1], files: "apps/kh_mobile/karat_hive/lib/features/profile_settings/", title: "Vendor profile_settings scaffold" }
  - { id: CP5-B07.1, wave: 3, status: done, mutex: ntf-mask-test, depends_on: [CP5-B01.2], files: "packages/kh_api/test/, apps/kh_mobile/karat_hive/test/", title: "No competitor price in notification payload" }

  # ----- wave 4 -----
  - { id: CP6-A06.2, wave: 4, status: done, mutex: settings-int-spec, depends_on: [CP6-A06.1], files: "backend/test/integration/vendor-settings.spec.ts", title: "Session revoke spec" }
  - { id: CP5-B06.5, wave: 4, status: done, mutex: kh-ui-domain, depends_on: [CP5-B06.4], files: "packages/kh_ui_domain/", title: "SH-ID-04" }
  - { id: CP5-B01.4, wave: 4, status: done, mutex: flutter-notifications, depends_on: [CP5-B01.3], files: "apps/kh_mobile/karat_hive/lib/features/notifications/", title: "Mark read / read-all" }
  - { id: CP6-B01.3, wave: 4, status: done, mutex: flutter-profile-settings, depends_on: [CP6-B01.2], files: "apps/kh_mobile/karat_hive/lib/features/profile_settings/, apps/kh_mobile/karat_hive/lib/features/onboarding/", title: "Re-home VEN-S16 Categories/Regions" }
  - { id: CP6-B02.1, wave: 4, status: done, mutex: business-profile-screen, depends_on: [CP6-B01.2, CP5-B06.4], files: "apps/kh_mobile/karat_hive/lib/features/profile_settings/presentation/business_profile_screen.dart", title: "VEN-S15 read-only header" }
  - { id: CP6-B04.2, wave: 4, status: done, mutex: offer-history-screen, depends_on: [CP6-B04.1, CP6-B05.4], files: "apps/kh_mobile/karat_hive/lib/features/offers_vendor/presentation/offer_history_screen.dart", title: "VEN-S14 filters" }

  # ----- remaining widget chain (kh_ui_domain is a single mutex) -----
  - { id: CP5-B06.6, wave: 5, status: done, mutex: kh-ui-domain, depends_on: [CP5-B06.5], files: "packages/kh_ui_domain/", title: "SH-ID-05" }
  - { id: CP6-A06.3, wave: 5, status: done, mutex: settings-int-spec, depends_on: [CP6-A06.2, CP6-A02], files: "backend/test/integration/vendor-settings.spec.ts", title: "Password policy spec" }
  - { id: CP5-B02, wave: 5, status: done, mutex: flutter-notifications, depends_on: [CP5-B01.4], files: "apps/kh_mobile/karat_hive/lib/core/firebase/firebase_notification_service.dart, apps/kh_mobile/karat_hive/lib/app/", title: "Push-triggered provider invalidation" }

  - { id: CP5-B06.7, wave: 6, status: done, mutex: kh-ui-domain, depends_on: [CP5-B06.6], files: "packages/kh_ui_domain/", title: "SH-ID-06" }
  - { id: CP6-A06.4, wave: 6, status: done, mutex: settings-int-spec, depends_on: [CP6-A06.3, CP6-A03.1, CP5-A05.2], files: "backend/test/integration/vendor-settings.spec.ts", title: "Performance + export masking spec" }
  - { id: CP6-B02.2, wave: 6, status: done, mutex: business-profile-screen, depends_on: [CP6-B02.1], files: "apps/kh_mobile/karat_hive/lib/features/profile_settings/presentation/business_profile_screen.dart", title: "VEN-S15 safe edits" }

  # ----- wave 7 -----
  - { id: CP5-B06.8, wave: 7, status: done, mutex: kh-ui-domain, depends_on: [CP5-B06.7], files: "packages/kh_ui_domain/", title: "SH-RPT-01" }
  - { id: CP6-B02.3, wave: 7, status: done, mutex: business-profile-screen, depends_on: [CP6-B02.2], files: "apps/kh_mobile/karat_hive/lib/features/profile_settings/presentation/business_profile_screen.dart", title: "VEN-S15 logo/shop photos or cite inventory gap" }
  - { id: CP5-B03.3, wave: 7, status: done, mutex: leave-review-screen, depends_on: [CP5-B03.2, CP5-B06.4, CP5-B06.5, CP5-B06.6], files: "apps/kh_mobile/karat_hive/lib/features/reviews/presentation/leave_review_screen.dart", title: "VEN-S19 leave review" }
  - { id: CP5-B04.1, wave: 7, status: done, mutex: my-reviews-screen, depends_on: [CP5-B03.2, CP5-B06.4], files: "apps/kh_mobile/karat_hive/lib/features/reviews/presentation/my_reviews_screen.dart", title: "VEN-S20 aggregate header" }

  # ----- wave 8 -----
  - { id: CP6-B05.1, wave: 8, status: done, mutex: kh-ui-domain, depends_on: [CP5-B06.8], files: "packages/kh_ui_domain/", title: "SH-SET-01" }
  - { id: CP6-B02.4, wave: 8, status: done, mutex: business-profile-screen, depends_on: [CP6-B02.3], files: "apps/kh_mobile/karat_hive/lib/features/profile_settings/presentation/business_profile_screen.dart", title: "VEN-S15 BR-004 legal identity" }
  - { id: CP5-B03.4, wave: 8, status: done, mutex: connection-detail, depends_on: [CP5-B03.3], files: "apps/kh_mobile/karat_hive/lib/features/connections/presentation/connection_detail_screen.dart", title: "Close Connection → VEN-S19" }
  - { id: CP5-B05.2, wave: 8, status: done, mutex: flutter-abuse, depends_on: [CP5-B05.1, CP5-B06.8], files: "apps/kh_mobile/karat_hive/lib/features/abuse/presentation/report_abuse_screen.dart", title: "VEN-S21 form" }
  - { id: CP5-B04.3, wave: 8, status: done, mutex: my-reviews-screen, depends_on: [CP5-B04.1, CP5-B03.1, CP5-B06.7, CP5-A04], files: "apps/kh_mobile/karat_hive/lib/features/reviews/presentation/my_reviews_screen.dart", title: "VEN-S20 list + response" }

  # ----- wave 9 -----
  - { id: CP6-B05.2, wave: 9, status: done, mutex: kh-ui-domain, depends_on: [CP6-B05.1], files: "packages/kh_ui_domain/", title: "SH-SET-02" }
  - { id: CP5-B05.3, wave: 9, status: done, mutex: connection-detail, depends_on: [CP5-B05.2, CP5-B03.4], files: "apps/kh_mobile/karat_hive/lib/features/request_feed/presentation/request_detail_screen.dart, apps/kh_mobile/karat_hive/lib/features/connections/presentation/connection_detail_screen.dart", title: "Report entry from S08/S13" }
  - { id: CP6-B03.2, wave: 9, status: done, mutex: settings-screen, depends_on: [CP6-B01.2, CP6-B05.1, CP6-B05.2], files: "apps/kh_mobile/karat_hive/lib/features/profile_settings/presentation/settings_screen.dart", title: "VEN-S18 language + RTL" }
  - { id: CP6-B04.3, wave: 9, status: done, mutex: offer-history-screen, depends_on: [CP6-B04.2], files: "apps/kh_mobile/karat_hive/lib/features/offers_vendor/presentation/offer_history_screen.dart", title: "VEN-S14 metric block" }
  - { id: CP5-B04.4, wave: 9, status: done, mutex: my-reviews-screen, depends_on: [CP5-B04.3], files: "apps/kh_mobile/karat_hive/lib/features/reviews/presentation/my_reviews_screen.dart", title: "VEN-S20 flag as unfair" }

  - { id: CP6-B05.6, wave: 10, status: done, mutex: kh-ui-domain, depends_on: [CP6-B05.2], files: "packages/kh_ui_domain/", title: "Rating-trend chart" }
  - { id: CP6-B03.3, wave: 10, status: done, mutex: settings-screen, depends_on: [CP6-B03.2, CP6-A01.2, CP5-B06.3, CP6-B05.3], files: "apps/kh_mobile/karat_hive/lib/features/profile_settings/presentation/settings_screen.dart", title: "VEN-S18 notification matrix + quiet hours" }
  - { id: CP6-B04.4, wave: 10, status: done, mutex: offer-history-screen, depends_on: [CP6-B04.3], files: "apps/kh_mobile/karat_hive/lib/features/offers_vendor/presentation/offer_history_screen.dart", title: "VEN-S14 terminal Offer history" }

  - { id: CP5-B04.2, wave: 11, status: done, mutex: my-reviews-screen, depends_on: [CP5-A05.2, CP5-B04.1, CP6-B05.6], files: "apps/kh_mobile/karat_hive/lib/features/reviews/presentation/my_reviews_screen.dart", title: "VEN-S20 distribution + trend" }
  - { id: CP6-B03.4, wave: 11, status: done, mutex: settings-screen, depends_on: [CP6-B03.3, CP6-A01.1], files: "apps/kh_mobile/karat_hive/lib/features/profile_settings/presentation/settings_screen.dart", title: "VEN-S18 default filter preset" }
  - { id: CP6-B04.5, wave: 11, status: done, mutex: offer-history-screen, depends_on: [CP6-B04.4, CP6-B04.1], files: "apps/kh_mobile/karat_hive/lib/features/offers_vendor/presentation/offer_history_screen.dart", title: "VEN-S14 CSV export" }

  - { id: CP6-B03.5, wave: 12, status: done, mutex: settings-screen, depends_on: [CP6-B03.4, CP6-B03.1], files: "apps/kh_mobile/karat_hive/lib/features/profile_settings/presentation/settings_screen.dart", title: "VEN-S18 password + sessions" }

  - { id: CP6-B03.6, wave: 13, status: done, mutex: settings-screen, depends_on: [CP6-B03.5, CP6-B05.5], files: "apps/kh_mobile/karat_hive/lib/features/profile_settings/presentation/settings_screen.dart", title: "VEN-S18 legal, version, logout" }
```

---

## Linearized order (single stack)

Dependencies are already satisfied if you emit this sequence. Within a wave, IDs are sorted lexicographically. Use this only when the orchestrator must produce a linear Graphite / git stack. Prefer waves for parallel execution.

```
W0  CP3-A08.1 CP3-B06.1 CP4-A06.1 CP5-A02.1 CP5-A04 CP5-A05.1 CP5-A05.2
    CP5-B01.1 CP5-B03.1 CP5-B05.1 CP5-B06.1 CP5-B06.9 CP5-I01.1 CP6-A02
W1  CP3-A08.2 CP3-B06.2 CP4-A06.2 CP5-A02.2 CP5-B03.2 CP5-B06.2 CP5-I01.2
    CP6-A01.1 CP6-A03.1 CP6-B03.1 CP6-B05.3
W2  CP3-B06.3 CP5-A02.3 CP5-B01.2 CP5-B06.3 CP5-I01.3 CP6-A01.2 CP6-B01.1
    CP6-B04.1 CP6-B05.4
W3  CP5-B01.3 CP5-B06.4 CP5-B07.1 CP6-A06.1 CP6-B01.2 CP6-B05.5
W4  CP5-B01.4 CP5-B06.5 CP6-A06.2 CP6-B01.3 CP6-B02.1 CP6-B04.2
W5  CP5-B02 CP5-B06.6 CP6-A06.3
W6  CP5-B06.7 CP6-A06.4 CP6-B02.2
W7  CP5-B03.3 CP5-B04.1 CP5-B06.8 CP6-B02.3
W8  CP5-B03.4 CP5-B04.3 CP5-B05.2 CP6-B02.4 CP6-B05.1
W9  CP5-B04.4 CP5-B05.3 CP6-B03.2 CP6-B04.3 CP6-B05.2
W10 CP6-B03.3 CP6-B04.4 CP6-B05.6
W11 CP5-B04.2 CP6-B03.4 CP6-B04.5
W12 CP6-B03.5
W13 CP6-B03.6
```

---

## PR Plan

Each YAML task is one PR. Number them in linearized order (`W0` first, left to right).

- **Title:** `{id}: {title}`
- **Description:** implement only that ID; do not invent routes, fields, or widget IDs; cite SRS / inventory / `ui-screens/`
- **Files/components affected:** YAML `files`
- **Dependencies:** YAML `depends_on` (write `None` when empty)
- **Parallel with:** every other ID that shares this task’s `wave`

Example:

### PR 1: CP3-A08.1 Live awardedElsewhere test
- **Description:** Two Vendors offer on one Request; Customer accepts A; B’s `GET /v1/me/offers?tab=CLOSED` has `awardedElsewhere: true` and no winning price or winner identity (`BR-008`).
- **Files/components affected:** `backend/test/integration/vendor-offers.spec.ts`
- **Dependencies:** None

### PR 2: CP4-A06.1 Idempotent accept replay
- **Description:** Second `POST /v1/offers/{id}/accept` with `REVEAL_AND_CONNECT` returns the first `{ offer, connection }`, not `OFFER_ALREADY_ACCEPTED`. Competitor accept still conflicts.
- **Files/components affected:** `backend/src/modules/connections/application/connection.service.ts`
- **Dependencies:** None

Remaining PRs: copy the YAML row. `PR N` = position in the linearized list (1-based).

---

## Acceptance (implementer)

| ID | Accept |
|---|---|
| CP4-A06.1 | Replay of the same Offer returns the first Connection |
| CP4-A06.2 | Two parallel accepts → one Connection, one ACCEPTED Offer |
| CP5-A02.1 | `priority` boolean on `abuse_report`, default false |
| CP5-A02.2 | 3 distinct Vendor reports on one Request set priority |
| CP5-A02.3 | Spec covers 3-distinct / same-vendor×3 / fourth idempotent |
| CP5-A04 | Second `POST /v1/reviews/{id}/response` → 409 CONFLICT |
| CP5-A05.1 | Consumer on `review.published` and `review.moderated` |
| CP5-A05.2 | Performance payload includes six `ratingTrend` points |
| CP6-A01.1 | `defaultFilterPresetId` round-trips; second default unsets first |
| CP6-A01.2 | Locked notification categories cannot be turned off |
| CP6-A02 | `POST /v1/auth/password`; violation → `PASSWORD_POLICY`; no new login path |
| CP6-A03.1 | `averageOfferedVsAccepted` is a period aggregate, never per-Request |
| CP3-A08.1 | Live awardedElsewhere; no winner price/identity |
| CP3-A08.2 | Expiry sweep + `expiry_warned_at` set once |
| CP3-B06.1–.3 | loading/empty/error/data per VEN-S09/S10/S11 |
| CP5-B06.* / CP6-B05.* | Widget + LTR and RTL golden; do not rebuild existing SH-FND-04/18 |
| CP5-B01.* | Vendor VEN-S17, not Customer `/alerts`; deep links through existing guards |
| CP5-B02 | Push invalidates Riverpod providers; no WebSocket |
| CP5-B03.* | VEN-S19; already-reviewed → `REVIEW_ALREADY_EXISTS` |
| CP5-B04.* | VEN-S20 header, trend, one response, flag stays visible |
| CP5-B05.* | VEN-S21 Vendor categories; prefill from S08/S13 |
| CP5-B07.1 | Loser/accepted notification fixture has no competitor price |
| CP5-I01.* | Catalogue only; events already in Async-Contract §7 |
| CP6-B01.* | Profile tab live; VEN-S16 re-homed; KYC stays in onboarding |
| CP6-B02.* | Safe edits vs BR-004 re-verify; no invented media columns |
| CP6-B03.* | VEN-S18 sections; platform-config URLs only |
| CP6-B04.* | VEN-S14 aggregates + own terminal history + signed CSV |
| CP6-A06.* | Integration spec against CI Postgres; export masking |
