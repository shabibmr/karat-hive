import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Verification queue query state encoded in URL query parameters (AD-FE §16.2).
class VerificationQueryParams {
  const VerificationQueryParams({this.selectedId});

  final String? selectedId;

  factory VerificationQueryParams.fromUri(Uri uri) {
    return VerificationQueryParams(
      selectedId:
          uri.queryParameters['selectedId'] ?? uri.queryParameters['selected'],
    );
  }

  factory VerificationQueryParams.fromState(GoRouterState state) {
    return VerificationQueryParams.fromUri(state.uri);
  }

  Map<String, String> toQueryParameters() {
    final params = <String, String>{};
    if (selectedId != null && selectedId!.isNotEmpty) {
      params['selectedId'] = selectedId!;
    }
    return params;
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

      final newUri = state.uri.replace(
        queryParameters: updated.toQueryParameters().isEmpty
            ? null
            : updated.toQueryParameters(),
      );

      go(newUri.toString());
    } catch (_) {
      // Safe fallback when executed outside a GoRouter context (e.g. widget tests)
    }
  }
}
