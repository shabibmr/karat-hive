import 'package:go_router/go_router.dart';
import '../../app/guards.dart';
import 'presentation/vendor_login_screen.dart';
import 'presentation/vendor_register_screen.dart';

final authRoutes = [
  GoRoute(
    path: AppGuards.login,
    builder: (_, __) => const VendorLoginScreen(),
  ),
  GoRoute(
    path: AppGuards.register,
    builder: (_, __) => const VendorRegisterScreen(),
  ),
];
