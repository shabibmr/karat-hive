import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/dashboard/model/dashboard_stats.dart';
import 'package:kh_admin/features/dashboard/repository/dashboard_repository.dart';

void main() {
  ApiClient buildClient({required dynamic responseData}) {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path == '/v1/admin/dashboard') {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: responseData,
              ),
            );
          }
          return handler.next(options);
        },
      ),
    );
    return ApiClient(baseUrl: 'http://localhost:3000', dio: dio);
  }

  group('DashboardRepository with real backend envelope shapes', () {
    test('parses stats from standard unwrapped backend envelope', () async {
      final client = buildClient(
        responseData: {
          'data': {
            'totalCustomers': 1420,
            'totalVendors': 185,
            'pendingVerificationVendors': 7,
            'activeRequests': 890,
            'activeOffers': 2340,
            'activeConnections': 512,
          },
        },
      );

      final repository = DashboardRepository(client);
      final stats = await repository.fetchStats();

      expect(stats.totalCustomers, 1420);
      expect(stats.totalVendors, 185);
      expect(stats.pendingVerificationVendors, 7);
      expect(stats.activeRequests, 890);
      expect(stats.activeOffers, 2340);
      expect(stats.activeConnections, 512);
    });

    test('parses stats from double-wrapped NestJS envelope interceptor',
        () async {
      // NestJS EnvelopeInterceptor wraps { data } into { data: { data: ... }, meta: ... }
      final client = buildClient(
        responseData: {
          'data': {
            'data': {
              'totalCustomers': 500,
              'totalVendors': 75,
              'pendingVerificationVendors': 3,
              'activeRequests': 120,
              'activeOffers': 340,
              'activeConnections': 88,
            },
          },
          'meta': {
            'requestId': 'req-dash-001',
            'serverTime': '2026-08-10T10:00:00.000Z',
          },
        },
      );

      final repository = DashboardRepository(client);
      final stats = await repository.fetchStats();

      expect(stats.totalCustomers, 500);
      expect(stats.totalVendors, 75);
      expect(stats.pendingVerificationVendors, 3);
      expect(stats.activeRequests, 120);
      expect(stats.activeOffers, 340);
      expect(stats.activeConnections, 88);
    });

    test('gracefully coerces strings and numbers into integers', () {
      final stats = DashboardStats.fromJson({
        'totalCustomers': '1420',
        'totalVendors': 185.0,
        'pendingVerificationVendors': '12',
        'activeRequests': 90,
        'activeOffers': '240',
        'activeConnections': 15,
      });

      expect(stats.totalCustomers, 1420);
      expect(stats.totalVendors, 185);
      expect(stats.pendingVerificationVendors, 12);
      expect(stats.activeRequests, 90);
      expect(stats.activeOffers, 240);
      expect(stats.activeConnections, 15);
    });

    test('handles empty / zero-valued payload', () {
      final stats = DashboardStats.fromJson({});

      expect(stats.totalCustomers, 0);
      expect(stats.totalVendors, 0);
      expect(stats.pendingVerificationVendors, 0);
      expect(stats.activeRequests, 0);
      expect(stats.activeOffers, 0);
      expect(stats.activeConnections, 0);
    });

    test('supports copyWith and equality comparison', () {
      const initial = DashboardStats(
        totalCustomers: 10,
        totalVendors: 5,
        pendingVerificationVendors: 1,
        activeRequests: 2,
        activeOffers: 3,
        activeConnections: 4,
      );

      final modified = initial.copyWith(totalCustomers: 20);
      expect(modified.totalCustomers, 20);
      expect(modified.totalVendors, 5);

      final identicalCopy = initial.copyWith();
      expect(identicalCopy, equals(initial));
      expect(identicalCopy.hashCode, equals(initial.hashCode));
      expect(initial.toString(), contains('customers: 10'));
    });
  });
}
