import 'package:go_router/go_router.dart';
import 'package:kh_domain/kh_domain.dart';

import 'presentation/find_ornament_screen.dart';
import 'presentation/request_type_screen.dart';
import 'presentation/stubs.dart' hide RequestTypeScreen;

/// Paths for Agent 1 to mount under the Customer shell.
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
        RequestType.unknown => type.name,
      };
}

final List<GoRoute> requestCreateRoutes = [
  GoRoute(
    path: RequestCreatePaths.type,
    builder: (_, __) => const RequestTypeScreen(),
  ),
  GoRoute(
    path: RequestCreatePaths.ornament,
    builder: (_, __) => const FindOrnamentScreen(),
  ),
  GoRoute(
    path: RequestCreatePaths.sellGold,
    builder: (_, __) => const CreateSellOldGoldScreen(),
  ),
  GoRoute(
    path: RequestCreatePaths.coins,
    builder: (_, __) => const CreateGoldCoinsScreen(),
  ),
  GoRoute(
    path: RequestCreatePaths.bullion,
    builder: (_, __) => const CreateGoldBullionScreen(),
  ),
  GoRoute(
    path: RequestCreatePaths.images,
    builder: (_, __) => const RequestImageCaptureScreen(),
  ),
  GoRoute(
    path: RequestCreatePaths.review,
    builder: (_, __) => const RequestReviewPublishScreen(),
  ),
];
