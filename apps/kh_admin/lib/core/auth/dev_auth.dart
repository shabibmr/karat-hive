import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Development-only auto-login configuration.
///
/// The Admin Portal normally gates every route behind [SessionController].
/// During local development that gate is noise: the seeded admin
/// (`backend/prisma/seed/admin.seed.ts`) is the only account that exists, and
/// re-typing its credentials on every hot restart slows the loop down.
///
/// When [autoLogin] is set the session controller performs a real
/// `POST /v1/auth/login/password` on boot, so the portal lands straight on the
/// dashboard **with genuine tokens** — admin API calls keep working. This is
/// deliberately not a fake session: a stubbed session would 401 on every
/// `/v1/admin/*` call.
///
/// Enable with:
/// ```
/// flutter run -d chrome \
///   --dart-define=KH_API_BASE=http://localhost:3000 \
///   --dart-define=KH_DEV_AUTOLOGIN=true
/// ```
///
/// [autoLogin] defaults to `false`, so release builds are unaffected unless the
/// define is passed explicitly. When it is on, the shell renders a
/// `DEV AUTO-LOGIN` badge so the flag cannot ship unnoticed.
class DevAuthConfig {
  const DevAuthConfig({
    required this.autoLogin,
    required this.email,
    required this.password,
  });

  final bool autoLogin;
  final String email;
  final String password;

  /// Production default: the normal login screen is shown.
  static const DevAuthConfig disabled = DevAuthConfig(
    autoLogin: false,
    email: '',
    password: '',
  );
}

const bool _kDevAutoLogin = bool.fromEnvironment('KH_DEV_AUTOLOGIN');

/// Defaults mirror `SEED_ADMIN_EMAIL` / `SEED_ADMIN_PASSWORD`
/// in `backend/prisma/seed/admin.seed.ts`.
const String _kDevAdminEmail = String.fromEnvironment(
  'KH_DEV_ADMIN_EMAIL',
  defaultValue: 'admin@karathive.ae',
);
const String _kDevAdminPassword = String.fromEnvironment(
  'KH_DEV_ADMIN_PASSWORD',
  defaultValue: 'AdminSecret123!',
);

/// Injectable so widget tests can flip auto-login without a compile-time
/// define (`bool.fromEnvironment` is const and cannot be varied at runtime).
final Provider<DevAuthConfig> devAuthConfigProvider = Provider<DevAuthConfig>(
  (ref) => const DevAuthConfig(
    autoLogin: _kDevAutoLogin,
    email: _kDevAdminEmail,
    password: _kDevAdminPassword,
  ),
);
