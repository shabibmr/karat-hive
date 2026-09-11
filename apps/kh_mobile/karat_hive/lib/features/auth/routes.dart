import 'package:go_router/go_router.dart';

import '../../app/guards.dart';
import 'presentation/account_blocked_screen.dart';
import 'presentation/auth_completer_screen.dart';
import 'presentation/customer_onboarding_screen.dart';
import 'presentation/customer_register_screen.dart';
import 'presentation/guest_landing_screen.dart';
import 'presentation/vendor_login_screen.dart';
import 'presentation/vendor_register_screen.dart';

final authRoutes = [
  GoRoute(
    path: AppGuards.guestLanding,
    builder: (_, __) => const GuestLandingScreen(),
  ),
  GoRoute(
    path: AppGuards.customerOnboarding,
    builder: (_, __) => const CustomerOnboardingScreen(),
  ),
  GoRoute(
    path: AppGuards.authComplete,
    builder: (_, __) => const AuthCompleterScreen(),
  ),
  GoRoute(
    path: AppGuards.customerRegister,
    builder: (_, __) => const CustomerRegisterScreen(),
  ),
  GoRoute(
    path: AppGuards.customerBlocked,
    builder: (_, __) => const AccountBlockedScreen(),
  ),
  GoRoute(path: AppGuards.login, builder: (_, __) => const VendorLoginScreen()),
  GoRoute(
    path: AppGuards.register,
    builder: (_, __) => const VendorRegisterScreen(),
  ),
];
