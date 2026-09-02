# packages

Shared Dart/Flutter packages used by `apps/kh_mobile` and `apps/kh_admin`. Packages never depend on apps.

| Package | Owns |
|---|---|
| `kh_core` | Result, failures, logging, env, extensions |
| `kh_domain` | Entities, value objects, masking types, enums — no Flutter, no HTTP |
| `kh_api` | Generated OpenAPI client, interceptors, envelope |
| `kh_design_system` | Tokens, theme, foundation widgets — no domain types |
| `kh_ui_domain` | Domain-aware widgets (Request, Offer, Connection, identity) |
| `kh_l10n` | ARB files, delegates, formatters |

See `docs/Architecture-Frontend.md` §5.
