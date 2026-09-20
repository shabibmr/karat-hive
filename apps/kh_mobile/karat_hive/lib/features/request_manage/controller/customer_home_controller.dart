import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../../app/session/session_controller.dart';
import '../repository/request_manage_repository.dart';

/// Dashboard activity strip for CUS-S02 Home.
class CustomerHomeSummary {
  const CustomerHomeSummary({
    required this.openRequests,
    required this.offersWaiting,
    required this.connections,
  });

  final int openRequests;
  final int offersWaiting;
  final int connections;
}

class CustomerHomeController
    extends AutoDisposeAsyncNotifier<CustomerHomeSummary> {
  @override
  Future<CustomerHomeSummary> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<CustomerHomeSummary> _load() async {
    final session = ref.read(sessionProvider);
    final signedIn = session is SignedIn ? session : null;
    final open = signedIn?.user.liveRequestCount ?? 0;
    final connections = signedIn?.customerProfile?.connectionCount ?? 0;

    final repo = ref.read(requestManageRepositoryProvider);
    final res = await repo.listMine();
    final offersWaiting = res.when(
      ok: (page) => page.items.fold<int>(
        0,
        (sum, r) => sum + (r.unreadOfferCount ?? 0),
      ),
      err: (_) => 0,
    );

    return CustomerHomeSummary(
      openRequests: open,
      offersWaiting: offersWaiting,
      connections: connections,
    );
  }
}

final customerHomeControllerProvider = AutoDisposeAsyncNotifierProvider<
    CustomerHomeController, CustomerHomeSummary>(
  CustomerHomeController.new,
);
