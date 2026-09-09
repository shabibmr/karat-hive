import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/router/abuse_query_params.dart';
import 'package:kh_admin/core/router/admin_user_query_params.dart';
import 'package:kh_admin/core/router/announcement_query_params.dart';
import 'package:kh_admin/core/router/audit_query_params.dart';
import 'package:kh_admin/core/router/connection_query_params.dart';
import 'package:kh_admin/core/router/customer_query_params.dart';
import 'package:kh_admin/core/router/moderation_query_params.dart';
import 'package:kh_admin/core/router/query_params_codec.dart';
import 'package:kh_admin/core/router/report_query_params.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_enums.dart';
import 'package:kh_admin/features/abuse/model/abuse_report_filters.dart';
import 'package:kh_admin/features/admin_users/model/admin_user_enums.dart';
import 'package:kh_admin/features/admin_users/model/admin_user_filters.dart';
import 'package:kh_admin/features/announcements/model/announcement_enums.dart';
import 'package:kh_admin/features/announcements/model/announcement_filters.dart';
import 'package:kh_admin/features/audit/model/audit_log_filters.dart';
import 'package:kh_admin/features/connections/model/connection_enums.dart';
import 'package:kh_admin/features/connections/model/connection_list_filters.dart';
import 'package:kh_admin/features/customers/model/customer_enums.dart';
import 'package:kh_admin/features/customers/model/customer_list_filters.dart';
import 'package:kh_admin/features/moderation/model/moderation_enums.dart';
import 'package:kh_admin/features/moderation/model/moderation_filters.dart';
import 'package:kh_admin/features/reports/model/report_filters.dart';

void main() {
  group('TR-S1-26a..h · Feature QueryParams Codecs & URL State Round-tripping', () {
    test('TR-S1-26a: CustomerQueryParams round-trips filters + cursor + selectedId', () {
      const state = ListUrlState<CustomerListFilters>(
        filters: CustomerListFilters(query: 'Ahmed', accountState: CustomerAccountState.active),
        cursor: 'cust_cursor_1',
        selectedId: 'cust_99',
      );

      final encoded = CustomerQueryParams.codec.encode(state);
      expect(encoded['q'], 'Ahmed');
      expect(encoded['accountState'], 'ACTIVE');
      expect(encoded['cursor'], 'cust_cursor_1');
      expect(encoded['selected'], 'cust_99');

      final decoded = CustomerQueryParams.codec.decode(encoded);
      expect(decoded.filters.query, 'Ahmed');
      expect(decoded.filters.accountState, CustomerAccountState.active);
      expect(decoded.cursor, 'cust_cursor_1');
      expect(decoded.selectedId, 'cust_99');
    });

    test('TR-S1-26b: ConnectionQueryParams round-trips filters + cursor + selectedId', () {
      const state = ListUrlState<ConnectionListFilters>(
        filters: ConnectionListFilters(query: 'ring', state: ConnectionState.active, hasNoContactOnly: true),
        cursor: 'conn_cur_2',
        selectedId: 'conn_42',
      );

      final encoded = ConnectionQueryParams.codec.encode(state);
      expect(encoded['q'], 'ring');
      expect(encoded['state'], 'ACTIVE');
      expect(encoded['hasNoContactOnly'], 'true');
      expect(encoded['cursor'], 'conn_cur_2');
      expect(encoded['selected'], 'conn_42');

      final decoded = ConnectionQueryParams.codec.decode(encoded);
      expect(decoded.filters.query, 'ring');
      expect(decoded.filters.state, ConnectionState.active);
      expect(decoded.filters.hasNoContactOnly, isTrue);
      expect(decoded.cursor, 'conn_cur_2');
      expect(decoded.selectedId, 'conn_42');
    });

    test('TR-S1-26c: AuditQueryParams round-trips filters + cursor + selectedId', () {
      final now = DateTime.utc(2026, 3, 15);
      final state = ListUrlState<AuditLogFilters>(
        filters: AuditLogFilters(
          actorUserId: 'admin_1',
          action: 'VENDOR_VERIFIED',
          entityType: 'vendor_profile',
          from: now,
        ),
        cursor: 'audit_cur_3',
        selectedId: 'entry_5',
      );

      final encoded = AuditQueryParams.codec.encode(state);
      expect(encoded['actorUserId'], 'admin_1');
      expect(encoded['action'], 'VENDOR_VERIFIED');
      expect(encoded['entityType'], 'vendor_profile');
      expect(encoded['from'], now.toIso8601String());
      expect(encoded['cursor'], 'audit_cur_3');
      expect(encoded['selected'], 'entry_5');

      final decoded = AuditQueryParams.codec.decode(encoded);
      expect(decoded.filters.actorUserId, 'admin_1');
      expect(decoded.filters.action, 'VENDOR_VERIFIED');
      expect(decoded.filters.entityType, 'vendor_profile');
      expect(decoded.filters.from, now);
      expect(decoded.cursor, 'audit_cur_3');
      expect(decoded.selectedId, 'entry_5');
    });

    test('TR-S1-26d: AbuseQueryParams round-trips filters + cursor + selectedId', () {
      const state = ListUrlState<AbuseReportFilters>(
        filters: AbuseReportFilters(query: 'spam', state: AbuseReportState.underReview, entityType: AbuseEntityType.vendor),
        cursor: 'abuse_cur_4',
        selectedId: 'abuse_7',
      );

      final encoded = AbuseQueryParams.codec.encode(state);
      expect(encoded['q'], 'spam');
      expect(encoded['state'], 'UNDER_REVIEW');
      expect(encoded['entityType'], 'VENDOR');
      expect(encoded['cursor'], 'abuse_cur_4');
      expect(encoded['selected'], 'abuse_7');

      final decoded = AbuseQueryParams.codec.decode(encoded);
      expect(decoded.filters.query, 'spam');
      expect(decoded.filters.state, AbuseReportState.underReview);
      expect(decoded.filters.entityType, AbuseEntityType.vendor);
      expect(decoded.cursor, 'abuse_cur_4');
      expect(decoded.selectedId, 'abuse_7');
    });

    test('TR-S1-26e: ModerationQueryParams round-trips filters + cursor + selectedId', () {
      const state = ListUrlState<ModerationFilters>(
        filters: ModerationFilters(query: 'bad review', state: ReviewState.rejected, authorType: AuthorType.customer),
        cursor: 'mod_cur_5',
        selectedId: 'rev_11',
      );

      final encoded = ModerationQueryParams.codec.encode(state);
      expect(encoded['q'], 'bad review');
      expect(encoded['state'], 'REJECTED');
      expect(encoded['authorType'], 'CUSTOMER');
      expect(encoded['cursor'], 'mod_cur_5');
      expect(encoded['selected'], 'rev_11');

      final decoded = ModerationQueryParams.codec.decode(encoded);
      expect(decoded.filters.query, 'bad review');
      expect(decoded.filters.state, ReviewState.rejected);
      expect(decoded.filters.authorType, AuthorType.customer);
      expect(decoded.cursor, 'mod_cur_5');
      expect(decoded.selectedId, 'rev_11');
    });

    test('TR-S1-26f: AnnouncementQueryParams round-trips filters + cursor + selectedId', () {
      const state = ListUrlState<AnnouncementFilters>(
        filters: AnnouncementFilters(query: 'maintenance', status: AnnouncementStatus.scheduled, audienceType: AudienceType.vendors),
        cursor: 'ann_cur_6',
        selectedId: 'ann_20',
      );

      final encoded = AnnouncementQueryParams.codec.encode(state);
      expect(encoded['q'], 'maintenance');
      expect(encoded['status'], 'SCHEDULED');
      expect(encoded['audienceType'], 'VENDOR');
      expect(encoded['cursor'], 'ann_cur_6');
      expect(encoded['selected'], 'ann_20');

      final decoded = AnnouncementQueryParams.codec.decode(encoded);
      expect(decoded.filters.query, 'maintenance');
      expect(decoded.filters.status, AnnouncementStatus.scheduled);
      expect(decoded.filters.audienceType, AudienceType.vendors);
      expect(decoded.cursor, 'ann_cur_6');
      expect(decoded.selectedId, 'ann_20');
    });

    test('TR-S1-26g: AdminUserQueryParams round-trips filters + cursor + selectedId', () {
      const state = ListUrlState<AdminUserFilters>(
        filters: AdminUserFilters(query: 'superadmin', state: AdminAccountState.active),
        cursor: 'adm_cur_7',
        selectedId: 'user_1',
      );

      final encoded = AdminUserQueryParams.codec.encode(state);
      expect(encoded['q'], 'superadmin');
      expect(encoded['state'], 'ACTIVE');
      expect(encoded['cursor'], 'adm_cur_7');
      expect(encoded['selected'], 'user_1');

      final decoded = AdminUserQueryParams.codec.decode(encoded);
      expect(decoded.filters.query, 'superadmin');
      expect(decoded.filters.state, AdminAccountState.active);
      expect(decoded.cursor, 'adm_cur_7');
      expect(decoded.selectedId, 'user_1');
    });

    test('TR-S1-26h: ReportQueryParams round-trips filters + cursor + selectedId', () {
      final from = DateTime.utc(2026, 1, 1);
      final to = DateTime.utc(2026, 1, 31);
      final state = ListUrlState<ReportFilters>(
        filters: ReportFilters(from: from, to: to, regionId: 'reg_dubai', categoryId: 'cat_gold'),
        cursor: 'rep_cur_8',
        selectedId: 'report_x',
      );

      final encoded = ReportQueryParams.codec.encode(state);
      expect(encoded['from'], '2026-01-01');
      expect(encoded['to'], '2026-01-31');
      expect(encoded['regionId'], 'reg_dubai');
      expect(encoded['categoryId'], 'cat_gold');
      expect(encoded['cursor'], 'rep_cur_8');
      expect(encoded['selected'], 'report_x');

      final decoded = ReportQueryParams.codec.decode(encoded);
      expect(decoded.filters.from, from);
      expect(decoded.filters.to, to);
      expect(decoded.filters.regionId, 'reg_dubai');
      expect(decoded.filters.categoryId, 'cat_gold');
      expect(decoded.cursor, 'rep_cur_8');
      expect(decoded.selectedId, 'report_x');
    });
  });
}
