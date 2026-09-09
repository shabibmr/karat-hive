import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_admin/features/abuse/controller/abuse_controller.dart';
import 'package:kh_admin/features/admin_users/controller/admin_user_controller.dart';
import 'package:kh_admin/features/announcements/controller/announcement_controller.dart';
import 'package:kh_admin/features/audit/controller/audit_controller.dart';
import 'package:kh_admin/features/connections/controller/connection_list_controller.dart';
import 'package:kh_admin/features/customers/controller/customer_list_controller.dart';
import 'package:kh_admin/features/moderation/controller/moderation_controller.dart';
import 'package:kh_admin/features/offers/controller/offer_list_controller.dart';
import 'package:kh_admin/features/requests/controller/request_list_controller.dart';
import 'package:kh_admin/features/vendors/controller/vendor_list_controller.dart';
import 'package:kh_admin/features/verification/controller/verification_controller.dart';

typedef ProviderInvalidator = void Function(ProviderOrFamily provider);

/// Routes incoming FCM push notifications to invalidate corresponding list providers (TR-S4-18).
void invalidateListProvidersOnPush(
  ProviderInvalidator invalidate,
  RemoteMessage message,
) {
  final entity = (message.data['entity'] ?? message.data['type'] ?? '').toString().toLowerCase();

  switch (entity) {
    case 'vendor':
    case 'vendors':
      invalidate(vendorListControllerProvider);
      break;
    case 'request':
    case 'requests':
      invalidate(requestListControllerProvider);
      break;
    case 'offer':
    case 'offers':
      invalidate(offerListControllerProvider);
      break;
    case 'customer':
    case 'customers':
      invalidate(customerListControllerProvider);
      break;
    case 'connection':
    case 'connections':
      invalidate(connectionListControllerProvider);
      break;
    case 'verification':
      invalidate(verificationQueueControllerProvider);
      break;
    case 'audit':
      invalidate(auditControllerProvider);
      break;
    case 'abuse':
      invalidate(abuseListControllerProvider);
      break;
    case 'moderation':
      invalidate(moderationListControllerProvider);
      break;
    case 'announcement':
    case 'announcements':
      invalidate(announcementListControllerProvider);
      break;
    case 'admin_user':
    case 'admin_users':
      invalidate(adminUserControllerProvider);
      break;
    default:
      // Invalidate primary live vertical providers on untyped refresh push
      invalidate(vendorListControllerProvider);
      invalidate(requestListControllerProvider);
      invalidate(offerListControllerProvider);
      invalidate(verificationQueueControllerProvider);
      break;
  }
}
