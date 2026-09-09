import 'package:go_router/go_router.dart';
import '../../app/guards.dart';
import '../profile_settings/routes.dart' show categoriesRegionsAwaitingRoute;
import 'presentation/awaiting_approval_screen.dart';
import 'presentation/kyc_upload_screen.dart';

final onboardingRoutes = [
  GoRoute(
    path: AppGuards.awaiting,
    builder: (_, __) => const AwaitingApprovalScreen(),
  ),
  GoRoute(
    path: AppGuards.kyc,
    builder: (_, __) => const KycUploadScreen(),
  ),
  categoriesRegionsAwaitingRoute,
];
