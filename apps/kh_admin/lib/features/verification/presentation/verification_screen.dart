import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/api/api_exception.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_screen_header.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/core/router/verification_query_params.dart';
import 'package:kh_admin/l10n/app_localizations.dart';
import 'package:kh_admin/features/verification/controller/verification_controller.dart';
import 'package:kh_admin/features/verification/model/verification_queue_item.dart';
import 'package:kh_admin/features/verification/presentation/verification_detail_pane.dart';
import 'package:kh_admin/features/verification/presentation/verification_queue_list.dart';

/// ADM-S07 Verification Queue Screen.
/// Oldest-first review queue for vendor business credentials (FR-ADM-015).
class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key, this.initialSelectedId});

  final String? initialSelectedId;

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialSelectedId;
  }

  String? _resolveSelectedId(BuildContext context) {
    try {
      final state = GoRouterState.of(context);
      final query = VerificationQueryParams.fromState(state);
      if (query.selectedId != null && query.selectedId!.isNotEmpty) {
        return query.selectedId;
      }
    } on Object catch (_) {
      // Outside GoRouter context (e.g. tests)
    }
    return _selectedId;
  }

  void _selectVendor(VerificationQueueItem item) {
    setState(() {
      _selectedId = item.id;
    });
    context.updateVerificationQuery(selectedId: item.id);
  }

  void _handleDecisionMade(List<VerificationQueueItem> currentQueue) {
    final colors = context.kh.colors;
    final shapes = context.kh.shapes;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: const Key('verification-success-toast'),
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: colors.sapphire900, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Decision recorded and vendor notified.',
                style: TextStyle(
                  color: colors.sapphire900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colors.gold400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: shapes.roundedSm),
        duration: const Duration(seconds: 4),
      ),
    );

    // Refresh queue and select next vendor if applicable
    final currentId = _resolveSelectedId(context);
    final index = currentQueue.indexWhere((it) => it.id == currentId);
    String? nextId;
    if (index >= 0 && index + 1 < currentQueue.length) {
      nextId = currentQueue[index + 1].id;
    } else if (index > 0 && currentQueue.length > 1) {
      nextId = currentQueue[index - 1].id;
    }

    setState(() {
      _selectedId = nextId;
    });

    if (nextId != null) {
      context.updateVerificationQuery(selectedId: nextId);
    } else {
      context.updateVerificationQuery(clearSelected: true);
    }

    ref.read(verificationQueueControllerProvider.notifier).reload();
  }

  String _formatErrorMessage(Object error) {
    if (error is ApiException) return error.message;
    final str = error.toString();
    if (str.startsWith('Exception: ')) return str.substring(11);
    return str;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kh.colors;
    final typography = context.kh.typography;
    final spacing = context.kh.spacing;
    final shapes = context.kh.shapes;
    final l10n = AppLocalizations.of(context);

    final queueAsync = ref.watch(verificationQueueControllerProvider);
    final currentSelectedId = _resolveSelectedId(context);

    return Padding(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: KhScreenHeader with title "Verification Queue" and subtitle
          KhScreenHeader(
            eyebrow: l10n?.verificationEyebrow ?? 'Compliance Reviewer',
            heading: queueAsync.maybeWhen(
              data: (items) => l10n?.verificationHeading(items.length) ??
                  'KYC Verification Queue (${items.length} Pending)',
              orElse: () =>
                  l10n?.verificationHeadingLoading ?? 'KYC Verification Queue',
            ),
            supportingText: l10n?.verificationSubtitle ??
                'Review vendor KYC submissions oldest-first. Every document view and decision is audit-logged.',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                KhStatusChip(
                  label: l10n?.oldestFirstBadge ?? 'OLDEST FIRST',
                  tone: KhStatusTone.pending,
                ),
                SizedBox(width: spacing.sm),
                IconButton(
                  key: const Key('verification-refresh-button'),
                  icon: const Icon(Icons.refresh),
                  tooltip: l10n?.refresh ?? 'Refresh',
                  color: colors.textSecondary,
                  onPressed: () {
                    ref
                        .read(verificationQueueControllerProvider.notifier)
                        .reload();
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.lg),

          // Main content area
          Expanded(
            child: queueAsync.when(
              loading: () => const Center(
                key: Key('verification-loading-view'),
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Center(
                key: const Key('verification-error-view'),
                child: Container(
                  padding: EdgeInsets.all(spacing.xl),
                  constraints: const BoxConstraints(maxWidth: 480),
                  decoration: BoxDecoration(
                    color: colors.backgroundElevated,
                    borderRadius: shapes.roundedMd,
                    border: Border.all(
                      color: colors.error.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: colors.error),
                      SizedBox(height: spacing.md),
                      Text(
                        l10n?.verificationLoadErrorTitle ??
                            'Failed to load verification queue',
                        style: typography.title.copyWith(color: colors.cream100),
                      ),
                      SizedBox(height: spacing.xs),
                      Text(
                        _formatErrorMessage(error),
                        textAlign: TextAlign.center,
                        style: typography.bodySmall
                            .copyWith(color: colors.textMuted),
                      ),
                      SizedBox(height: spacing.lg),
                      OutlinedButton(
                        onPressed: () {
                          ref
                              .read(verificationQueueControllerProvider.notifier)
                              .reload();
                        },
                        child: Text(l10n?.tryAgain ?? 'Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    key: const Key('verification-empty-view'),
                    child: Container(
                      padding: EdgeInsets.all(spacing.xxl),
                      constraints: const BoxConstraints(maxWidth: 500),
                      decoration: BoxDecoration(
                        color: colors.backgroundElevated,
                        borderRadius: shapes.roundedMd,
                        border: Border.all(color: colors.borderSubtle),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 56,
                            color: colors.goldPrimary,
                          ),
                          SizedBox(height: spacing.md),
                          Text(
                            l10n?.emptyVerificationTitle ?? 'Queue is Clear',
                            style: typography.title,
                          ),
                          SizedBox(height: spacing.sm),
                          Text(
                            l10n?.emptyVerificationBody ??
                                'No vendors are currently awaiting KYC verification.',
                            textAlign: TextAlign.center,
                            style: typography.bodySmall
                                .copyWith(color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Default selection to first item if none selected or if selected not in queue
                final effectiveSelectedId =
                    (currentSelectedId != null &&
                            items.any((it) => it.id == currentSelectedId))
                        ? currentSelectedId
                        : items.first.id;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 1000;

                    final listWidget = VerificationQueueList(
                      items: items,
                      selectedId: effectiveSelectedId,
                      onSelect: _selectVendor,
                    );

                    final detailWidget = VerificationDetailPane(
                      vendorId: effectiveSelectedId,
                      onDecisionMade: () => _handleDecisionMade(items),
                    );

                    if (isDesktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 4,
                            child: listWidget,
                          ),
                          SizedBox(width: spacing.md),
                          Expanded(
                            flex: 5,
                            child: detailWidget,
                          ),
                        ],
                      );
                    }

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          listWidget,
                          SizedBox(height: spacing.md),
                          SizedBox(
                            height: 650,
                            child: detailWidget,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
