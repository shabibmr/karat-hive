import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_admin/core/router/query_navigation.dart';
import 'package:kh_admin/core/router/query_params_codec.dart';

/// Codec for encoding/decoding verification queue query state (TR-S1-25 / ADM-SMP-07).
class VerificationQueryParamsCodec extends QueryParamsCodec<void> {
  const VerificationQueryParamsCodec();

  @override
  String get selectedIdKey => 'selectedId';

  @override
  void decodeFilters(Map<String, String> query) {}

  @override
  Map<String, String> encodeFilters(void filters) => const {};
}

/// Verification queue query state encoded in URL query parameters (AD-FE §16.2).
class VerificationQueryParams {
  static const codec = VerificationQueryParamsCodec();

  const VerificationQueryParams({this.selectedId});

  final String? selectedId;

  factory VerificationQueryParams.fromUri(Uri uri) {
    final state = codec.fromUri(uri);
    return VerificationQueryParams(
      selectedId: state.selectedId,
    );
  }

  factory VerificationQueryParams.fromState(GoRouterState state) {
    return VerificationQueryParams.fromUri(state.uri);
  }

  Map<String, String> toQueryParameters() {
    return codec.encode(
      ListUrlState<void>(
        filters: null,
        selectedId: selectedId,
      ),
    );
  }

  VerificationQueryParams copyWith({
    String? selectedId,
    bool clearSelected = false,
  }) {
    return VerificationQueryParams(
      selectedId: clearSelected ? null : (selectedId ?? this.selectedId),
    );
  }
}

/// Extension on [BuildContext] for updating verification queue query parameters.
extension VerificationQueryNavigation on BuildContext {
  void updateVerificationQuery({
    String? selectedId,
    bool clearSelected = false,
  }) {
    try {
      final state = GoRouterState.of(this);
      final current = VerificationQueryParams.fromState(state);
      final updated = current.copyWith(
        selectedId: selectedId,
        clearSelected: clearSelected,
      );

      applyQueryParameters(updated.toQueryParameters());
    } on Object catch (_) {
      // Safe fallback when executed outside a GoRouter context (e.g. widget tests)
    }
  }
}
