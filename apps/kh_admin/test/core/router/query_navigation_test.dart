import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_admin/core/router/query_navigation.dart';
import 'package:kh_admin/core/router/taxonomy_query_params.dart';
import 'package:kh_admin/core/router/verification_query_params.dart';

void main() {
  group('QueryNavigation clear-semantics regression tests (ADM-SMP-64 / TR-S1-24)', () {
    testWidgets('applyQueryParameters clears query parameters when passed empty map', (tester) async {
      late BuildContext capturedContext;
      late GoRouter router;

      router = GoRouter(
        initialLocation: '/test?q=initial&status=active',
        routes: [
          GoRoute(
            path: '/test',
            builder: (context, state) {
              capturedContext = context;
              return Scaffold(
                body: Text('Current Query: ${state.uri.query}'),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Current Query: q=initial&status=active'), findsOneWidget);
      expect(GoRouterState.of(capturedContext).uri.queryParameters, {
        'q': 'initial',
        'status': 'active',
      });

      // Clear all query parameters
      capturedContext.applyQueryParameters(const <String, String>{});
      await tester.pumpAndSettle();

      expect(find.text('Current Query: '), findsOneWidget);
      expect(GoRouterState.of(capturedContext).uri.queryParameters, isEmpty);
      expect(GoRouterState.of(capturedContext).uri.query, isEmpty);
    });

    testWidgets('updateTaxonomyQuery clears query string when all filters cleared', (tester) async {
      late BuildContext capturedContext;
      final router = GoRouter(
        initialLocation: '/taxonomy?selected=node_1&showInactive=true',
        routes: [
          GoRoute(
            path: '/taxonomy',
            builder: (context, state) {
              capturedContext = context;
              return Scaffold(
                body: Text('Taxonomy Query: ${state.uri.query}'),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(GoRouterState.of(capturedContext).uri.queryParameters, {
        'selected': 'node_1',
        'showInactive': 'true',
      });

      // Clear both selected node and inactive filter
      capturedContext.updateTaxonomyQuery(
        clearSelected: true,
        showInactive: false,
      );
      await tester.pumpAndSettle();

      expect(GoRouterState.of(capturedContext).uri.queryParameters, isEmpty);
      expect(GoRouterState.of(capturedContext).uri.query, isEmpty);
    });

    testWidgets('updateVerificationQuery clears query string when selectedId cleared', (tester) async {
      late BuildContext capturedContext;
      final router = GoRouter(
        initialLocation: '/verification?selectedId=vendor_123',
        routes: [
          GoRoute(
            path: '/verification',
            builder: (context, state) {
              capturedContext = context;
              return Scaffold(
                body: Text('Verification Query: ${state.uri.query}'),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(GoRouterState.of(capturedContext).uri.queryParameters, {
        'selectedId': 'vendor_123',
      });

      // Clear selected vendor
      capturedContext.updateVerificationQuery(clearSelected: true);
      await tester.pumpAndSettle();

      expect(GoRouterState.of(capturedContext).uri.queryParameters, isEmpty);
      expect(GoRouterState.of(capturedContext).uri.query, isEmpty);
    });

    test('stringMapsEqual checks order-insensitive equality', () {
      expect(stringMapsEqual({'a': '1', 'b': '2'}, {'b': '2', 'a': '1'}), isTrue);
      expect(stringMapsEqual({'a': '1'}, {'a': '2'}), isFalse);
      expect(stringMapsEqual({'a': '1'}, {'a': '1', 'b': '2'}), isFalse);
      expect(stringMapsEqual({}, {}), isTrue);
    });
  });
}
