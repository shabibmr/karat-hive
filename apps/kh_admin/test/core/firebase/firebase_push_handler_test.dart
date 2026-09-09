import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/firebase/firebase_push_handler.dart';
import 'package:kh_admin/features/requests/controller/request_list_controller.dart';
import 'package:kh_admin/features/vendors/controller/vendor_list_controller.dart';

void main() {
  group('firebase_push_handler (TR-S4-18)', () {
    test('routes push notifications and invalidates corresponding list providers', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.listen(vendorListControllerProvider, (_, __) {});
      container.listen(requestListControllerProvider, (_, __) {});

      // Invalidate on vendor push
      final vendorMessage = RemoteMessage(data: {'entity': 'vendors'});
      invalidateListProvidersOnPush(container.invalidate, vendorMessage);
      expect(vendorMessage.data['entity'], 'vendors');

      // Invalidate on request push
      final requestMessage = RemoteMessage(data: {'entity': 'requests'});
      invalidateListProvidersOnPush(container.invalidate, requestMessage);
      expect(requestMessage.data['entity'], 'requests');
    });
  });
}
