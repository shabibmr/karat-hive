import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_admin/core/log/kh_logger.dart';

/// Riverpod [ProviderObserver] that logs provider failures using [KhLogger].
class ProviderLogger extends ProviderObserver {
  const ProviderLogger({KhLogger logger = const KhLogger()}) : _logger = logger;

  final KhLogger _logger;

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    _logger.error(
      'Provider ${provider.name ?? provider.runtimeType} failed',
      error,
      stackTrace,
    );
  }
}
