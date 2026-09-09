import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/router/audit_query_params.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_screen_header.dart';
import 'package:kh_admin/features/audit/controller/audit_controller.dart';
import 'package:kh_admin/features/audit/model/audit_log_filters.dart';
import 'package:kh_admin/features/audit/presentation/widgets/audit_data_table.dart';
import 'package:kh_admin/features/audit/presentation/widgets/audit_detail_dialog.dart';
import 'package:kh_admin/features/audit/presentation/widgets/audit_empty_view.dart';
import 'package:kh_admin/features/audit/presentation/widgets/audit_error_view.dart';
import 'package:kh_admin/features/audit/presentation/widgets/audit_filters_toolbar.dart';
import 'package:kh_admin/features/audit/presentation/widgets/audit_pagination_controls.dart';
import 'package:kh_admin/features/audit/presentation/widgets/audit_self_view_notice.dart';

/// ADM-S22 · Audit Log viewer screen.
///
/// Search immutable audit trail of security and administrative operations
/// (`FR-ADM-033`, `FR-SYS-011`). Viewing this log is itself audited per §39.
///
/// Composition root only: toolbar, table, pagination, states, and the detail
/// dialog live in `presentation/widgets/` (TR-S2-13).
class AuditScreen extends ConsumerStatefulWidget {
  const AuditScreen({super.key});

  @override
  ConsumerState<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends ConsumerState<AuditScreen> {
  late final TextEditingController _actionSearchController;
  late final TextEditingController _actorSearchController;
  late final TextEditingController _ipSearchController;

  Uri? _lastSyncedUri;

  @override
  void initState() {
    super.initState();
    final filters = ref.read(auditControllerProvider).filters;
    _actionSearchController = TextEditingController(text: filters.action ?? '');
    _actorSearchController =
        TextEditingController(text: filters.actorUserId ?? '');
    _ipSearchController = TextEditingController(text: filters.ip ?? '');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncFromUri();
  }

  void _syncFromUri() {
    Uri uri;
    try {
      uri = GoRouterState.of(context).uri;
    } on Object catch (_) {
      return;
    }
    if (uri == _lastSyncedUri) return;
    _lastSyncedUri = uri;

    final parsed = AuditQueryParams.fromUri(uri).filters;
    final current = ref.read(auditControllerProvider).filters;
    if (parsed == current) return;
    ref.read(auditControllerProvider.notifier).applyFilters(parsed);
    if (_actionSearchController.text != (parsed.action ?? '')) {
      _actionSearchController.text = parsed.action ?? '';
    }
    if (_actorSearchController.text != (parsed.actorUserId ?? '')) {
      _actorSearchController.text = parsed.actorUserId ?? '';
    }
    if (_ipSearchController.text != (parsed.ip ?? '')) {
      _ipSearchController.text = parsed.ip ?? '';
    }
  }

  @override
  void dispose() {
    _actionSearchController.dispose();
    _actorSearchController.dispose();
    _ipSearchController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange(
    BuildContext context,
    AuditLogFilters filters,
  ) async {
    final now = DateTime.now();
    final initialDateRange = DateTimeRange(
      start: filters.from ?? now.subtract(const Duration(days: 30)),
      end: filters.to ?? now,
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025, 1, 1),
      lastDate: now.add(const Duration(days: 1)),
      initialDateRange: initialDateRange,
      helpText: 'Select GST Audit Date Range',
    );

    if (picked != null) {
      ref.read(auditControllerProvider.notifier).setDateRange(
            picked.start,
            DateTime(
              picked.end.year,
              picked.end.month,
              picked.end.day,
              23,
              59,
              59,
            ),
          );
    }
  }

  void _resetFilters() {
    _actionSearchController.clear();
    _actorSearchController.clear();
    _ipSearchController.clear();
    ref.read(auditControllerProvider.notifier).clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuditLogFilters>(
      auditControllerProvider.select((s) => s.filters),
      (prev, next) {
        if (prev != next) {
          context.updateAuditQuery(next);
        }
      },
    );

    final kh = context.kh;
    final colors = kh.colors;
    final spacing = kh.spacing;
    final auditState = ref.watch(auditControllerProvider);
    final controller = ref.read(auditControllerProvider.notifier);

    return Material(
      color: colors.backgroundSurface,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const KhScreenHeader(
              eyebrow: 'COMPLIANCE & SECURITY',
              heading: 'Audit Log',
              supportingText:
                  'Immutable audit trail of security and administrative operations (FR-ADM-033, BR-021, NFR-021)',
            ),
            SizedBox(height: spacing.md),
            const AuditSelfViewNotice(),
            SizedBox(height: spacing.lg),
            AuditFiltersToolbar(
              state: auditState,
              controller: controller,
              actorSearchController: _actorSearchController,
              ipSearchController: _ipSearchController,
              onPickDateRange: () => _pickDateRange(context, auditState.filters),
              onReset: _resetFilters,
            ),
            SizedBox(height: spacing.lg),
            if (auditState.isLoading)
              const Center(
                key: Key('audit-loading-indicator'),
                child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (auditState.error != null && auditState.items.isEmpty)
              AuditErrorView(
                error: auditState.error!,
                onRetry: controller.refresh,
              )
            else if (auditState.items.isEmpty)
              const AuditEmptyView()
            else ...[
              AuditDataTable(
                items: auditState.items,
                onInspect: (item) => showAuditDetailDialog(context, item),
              ),
              SizedBox(height: spacing.md),
              AuditPaginationControls(
                state: auditState,
                controller: controller,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
