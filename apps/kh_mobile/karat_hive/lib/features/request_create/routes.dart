import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../app/guards.dart';
import '../../app/session/session_controller.dart';
import 'presentation/find_ornament_screen.dart';
import 'presentation/request_image_capture_screen.dart';
import 'presentation/request_review_publish_screen.dart';
import 'presentation/request_type_screen.dart';

/// Create-compose paths (CUS-S03…S09). Mounted under UnauthShell so Guest
/// can compose without a token (`adr/0011`); signed-in Customers use the same.
abstract final class RequestCreatePaths {
  static const type = '/customer/requests/create';
  static const ornament = '/customer/requests/create/ornament';
  static const sellGold = '/customer/requests/create/sell-gold';
  static const coins = '/customer/requests/create/coins';
  static const bullion = '/customer/requests/create/bullion';
  static const images = '/customer/requests/create/images';
  static const review = '/customer/requests/create/review';

  static String composeFor(RequestType type) => switch (type) {
        RequestType.findOrnament => ornament,
        RequestType.sellOldGold => sellGold,
        RequestType.goldCoin => coins,
        RequestType.goldBullion => bullion,
        RequestType.unknown => RequestCreatePaths.type,
      };
}

/// Safety net for entering this flow with no wizard history behind it
/// (a deep link, or the post-login redirect landing straight on review) —
/// `go_router` exits the app outright rather than popping when every nested
/// Navigator's history is empty. Send the user somewhere sensible instead.
Future<bool> _handleWizardRootExit(BuildContext context) async {
  final session = ProviderScope.containerOf(context).read(sessionProvider);
  context.go(
    session is SignedIn ? AppGuards.homeFor(session) : AppGuards.customerGuest,
  );
  return false;
}

final List<GoRoute> requestCreateRoutes = [
  GoRoute(
    path: RequestCreatePaths.type,
    builder: (_, __) => const RequestTypeScreen(),
    onExit: (context, state) => _handleWizardRootExit(context),
  ),
  GoRoute(
    path: RequestCreatePaths.ornament,
    builder: (_, __) => const FindOrnamentScreen(),
  ),
  GoRoute(
    path: RequestCreatePaths.sellGold,
    builder: (_, __) => const SellOldGoldScreen(),
  ),
  GoRoute(
    path: RequestCreatePaths.coins,
    builder: (_, __) => const GoldCoinsScreen(),
  ),
  GoRoute(
    path: RequestCreatePaths.bullion,
    builder: (_, __) => const GoldBullionScreen(),
  ),
  GoRoute(
    path: RequestCreatePaths.images,
    builder: (_, __) => const RequestImageCaptureScreen(),
  ),
  GoRoute(
    // No onExit here (unlike `type`): this screen's own success paths call
    // `context.go()` to leave the wizard, which would itself trigger
    // `onExit` as an "exiting" route and race against that navigation.
    path: RequestCreatePaths.review,
    builder: (_, __) => const RequestReviewPublishScreen(),
  ),
];
