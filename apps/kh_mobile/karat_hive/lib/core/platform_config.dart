import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_domain/kh_domain.dart';

import '../app/di.dart';

class PlatformConfigController
    extends AutoDisposeAsyncNotifier<PlatformConfig> {
  @override
  Future<PlatformConfig> build() async {
    final r = await ref.watch(khApiProvider).platformConfig.getConfig();
    return r.when(ok: (cfg) => cfg, err: (f) => throw f);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final r = await ref.read(khApiProvider).platformConfig.getConfig();
      return r.when(ok: (cfg) => cfg, err: (f) => throw f);
    });
  }
}

final platformConfigProvider =
    AsyncNotifierProvider.autoDispose<PlatformConfigController, PlatformConfig>(
  PlatformConfigController.new,
);
