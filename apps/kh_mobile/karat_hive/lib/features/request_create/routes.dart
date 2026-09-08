import 'package:go_router/go_router.dart';
import 'package:kh_domain/kh_domain.dart';

import 'presentation/find_ornament_screen.dart';
import 'presentation/gold_bullion_screen.dart';
import 'presentation/gold_coins_screen.dart';
import 'presentation/image_capture_screen.dart';
import 'presentation/request_type_screen.dart';
import 'presentation/review_publish_screen.dart';
import 'presentation/sell_old_gold_screen.dart';

/// Paths for Agent 1 to mount under the Customer shell. This file is not
/// registered in `app/router.dart` from this track.
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
        RequestType.unknown => type,
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
    builder: (_, __) => const ImageCaptureScreen(),
  ),
  GoRoute(
    path: RequestCreatePaths.review,
    builder: (_, __) => const ReviewPublishScreen(),
  ),
];
