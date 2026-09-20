# Fix admin runtime failure modes (from review v1)

Approved by user: "Fix them all".

## [MODIFY] Session / API / Firebase
- `lib/core/api/api_client.dart` — stable client; listen flavor → `updateBaseUrl`
- `lib/core/auth/session_controller.dart` — sync mutex; Firebase-ready bootstrap; auth-only logout; don't watch apiClient
- `lib/core/auth/auth_repository.dart` + `auth_models.dart` — `asMap`/`unwrapEntity`
- `lib/main.dart` — bootstrap session after Firebase init; ErrorRetry reload
- `lib/core/error/error_retry_widget.dart` — wire retry
- `lib/core/shell/kh_admin_scaffold.dart` — mount IdleTimeoutListener
- `lib/core/router/app_router.dart` — preserve `from` / hold URL while loading
- `lib/features/contract_version/...` — same-tab reload + clear mismatch flag

## [MODIFY] List kernel
- `lib/core/list/cursor_paginated_notifier.dart` — epoch bump on filter/refresh; fix retry (loadMore vs nextPage)
- Align search controllers to set-query-local + submit where needed

## [MODIFY] Features
- Verification: catch Object; signed-URL detection / disable broken open
- Detail controllers: mutation success ≠ reload; invalidate lists
- Announcements: throw or only pop on success
- Moderation/abuse: surface ApiException.message
- Taxonomy: keep data + action error
- Customer accountState: unknown enum / no Active default for missing
- Request detail: processing + mounted guards
