# System Architecture Note: Dynamic Environment Config via Firestore

## Summary
Both `karat_hive` (mobile) and `kh_admin` (web) dynamically resolve their backend API base URL (`KH_API_BASE_URL` / `KH_API_BASE`) from a Firestore document at runtime, while maintaining static `--dart-define` values as offline fallbacks.

## Firestore Contract
- **Collection**: `app_config`
- **Document**: `environment`
- **Security Rule**: Unauthenticated read allowed (`allow read: if true;`, `allow write: if false;`).
- **Fields Supported**:
  - Flat keys: `api_base_url_dev`, `api_base_url_staging`, `api_base_url_prod`
  - Nested keys: `dev: { api_base_url: "..." }` or `dev: "..."`
  - Global fallback: `api_base_url`

## Implementation Pattern
1. **`packages/kh_core/lib/src/env.dart`**:
   - `Env` contains `flavor` and `apiBaseUrl`.
   - `Env.copyWith({Flavor? flavor, String? apiBaseUrl})` allows runtime immutability updates.
2. **Mobile (`apps/kh_mobile/karat_hive`)**:
   - `FirestoreConfigService` fetches `app_config/environment` with a 3-second timeout.
   - `bootstrap.dart` resolves the remote URL after `Firebase.initializeApp()` and overrides `envProvider` in `ProviderScope`.
3. **Web Admin (`apps/kh_admin`)**:
   - `FirestoreConfigService` fetches `app_config/environment` with a 3-second timeout.
   - `flavorConfigProvider` is a `StateProvider<FlavorConfig>`.
   - `apiClientProvider` watches `flavorConfigProvider` and updates `Dio` `baseUrl`.
   - `initializeFirebaseNonBlocking` triggers `_syncRemoteEnvironmentConfig` post-frame to keep initial web rendering non-blocking.
