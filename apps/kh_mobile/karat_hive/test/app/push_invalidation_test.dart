import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/notifications/push_invalidation.dart';

void main() {
  const requestId = '11111111-1111-1111-1111-111111111111';
  const offerId = '22222222-2222-2222-2222-222222222222';
  const connectionId = '33333333-3333-3333-3333-333333333333';

  group('PushInvalidationPlan.fromData', () {
    test('always includes notifications even with empty data', () {
      final plan = PushInvalidationPlan.fromData(const {});
      expect(plan.targets, {PushInvalidationTarget.notifications});
    });

    test('maps /requests/{id} to feed + detail providers', () {
      final plan = PushInvalidationPlan.fromData({
        'deepLink': '/requests/$requestId',
        'type': 'request.matched',
      });
      expect(plan.requestId, requestId);
      expect(
        plan.targets,
        containsAll({
          PushInvalidationTarget.notifications,
          PushInvalidationTarget.requestFeed,
          PushInvalidationTarget.requestDetail,
          PushInvalidationTarget.myOffers,
          PushInvalidationTarget.customerHome,
          PushInvalidationTarget.ownerRequestDetail,
        }),
      );
    });

    test('maps /requests/{id}/offers to offers list', () {
      final plan = PushInvalidationPlan.fromData({
        'deepLink': '/requests/$requestId/offers',
      });
      expect(plan.requestId, requestId);
      expect(plan.targets, contains(PushInvalidationTarget.offersList));
    });

    test('maps /offers/{id}', () {
      final plan = PushInvalidationPlan.fromData({
        'deepLink': '/offers/$offerId',
      });
      expect(plan.offerId, offerId);
      expect(plan.targets, contains(PushInvalidationTarget.offerDetail));
      expect(plan.targets, contains(PushInvalidationTarget.myOffers));
    });

    test('maps /connections/{id}', () {
      final plan = PushInvalidationPlan.fromData({
        'deepLink': '/connections/$connectionId',
      });
      expect(plan.connectionId, connectionId);
      expect(
        plan.targets,
        containsAll({
          PushInvalidationTarget.connectionsVendor,
          PushInvalidationTarget.connectionsCustomer,
          PushInvalidationTarget.connectionDetailVendor,
          PushInvalidationTarget.connectionDetailCustomer,
        }),
      );
    });

    test('maps /connections/{id}/review to myReviews', () {
      final plan = PushInvalidationPlan.fromData({
        'deepLink': '/connections/$connectionId/review',
      });
      expect(plan.targets, contains(PushInvalidationTarget.myReviews));
    });

    test('maps /me/vendor and documents', () {
      final profile = PushInvalidationPlan.fromData({
        'deepLink': '/me/vendor',
      });
      expect(
        profile.targets,
        containsAll({
          PushInvalidationTarget.vendorMe,
          PushInvalidationTarget.vendorProfile,
        }),
      );

      final docs = PushInvalidationPlan.fromData({
        'deepLink': '/me/vendor/documents',
      });
      expect(docs.targets, contains(PushInvalidationTarget.vendorDocuments));
    });

    test('accepts deep_link snake_case key', () {
      final plan = PushInvalidationPlan.fromData({
        'deep_link': '/offers/$offerId',
      });
      expect(plan.offerId, offerId);
    });

    test('falls back to type when deepLink absent', () {
      final plan = PushInvalidationPlan.fromData({
        'type': 'offer.accepted',
      });
      expect(
        plan.targets,
        containsAll({
          PushInvalidationTarget.notifications,
          PushInvalidationTarget.myOffers,
          PushInvalidationTarget.connectionsVendor,
          PushInvalidationTarget.connectionsCustomer,
        }),
      );
    });

    test('rejects absolute URLs as deep links', () {
      final plan = PushInvalidationPlan.fromData({
        'deepLink': 'https://evil.example/requests/$requestId',
      });
      expect(plan.targets, {PushInvalidationTarget.notifications});
      expect(plan.requestId, isNull);
    });
  });
}
