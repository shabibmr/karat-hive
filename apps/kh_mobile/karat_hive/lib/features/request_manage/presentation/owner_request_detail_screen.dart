import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../controller/owner_request_detail_controller.dart';
import 'customer_copy.dart';

/// CUS-S10 — owner Request detail (CU-10).
class OwnerRequestDetailScreen extends ConsumerStatefulWidget {
  const OwnerRequestDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<OwnerRequestDetailScreen> createState() =>
      _OwnerRequestDetailScreenState();
}

class _OwnerRequestDetailScreenState
    extends ConsumerState<OwnerRequestDetailScreen> {
  late final TextEditingController _notes;
  late final TextEditingController _budgetMin;
  late final TextEditingController _budgetMax;
  bool _flexible = false;
  bool _hydrated = false;
  String? _cancelReason;

  @override
  void initState() {
    super.initState();
    _notes = TextEditingController();
    _budgetMin = TextEditingController();
    _budgetMax = TextEditingController();
  }

  @override
  void dispose() {
    _notes.dispose();
    _budgetMin.dispose();
    _budgetMax.dispose();
    super.dispose();
  }

  void _hydrate(RequestForCustomer req) {
    if (_hydrated) return;
    _hydrated = true;
    _notes.text = req.notes ?? '';
    _budgetMin.text = req.budgetMin ?? '';
    _budgetMax.text = req.budgetMax ?? '';
    _flexible = req.budgetIsFlexible;
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(ownerRequestDetailProvider(widget.requestId));
    final tokens = context.tokens;
    final s = KhStrings.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      key: const Key('owner-request-detail-screen'),
      appBar: AppBar(title: Text(s.s('cus.s10.title'))),
      body: async.when(
        loading: () => const KhLoadingView(),
        error: (err, _) => KhErrorView(
          message: customerFailureMessage(
            err is Failure ? err : ServerFailure(message: err.toString()),
            s,
            'cus.home.error',
          ),
          onRetry: () => ref
              .read(ownerRequestDetailProvider(widget.requestId).notifier)
              .reload(),
          retryLabel: s.s('common.retry'),
        ),
        data: (detail) {
          final req = detail.request;
          _hydrate(req);
          final specs = <(String, String)>[
            ('Type', requestTypeLabel(s, req.requestType)),
            ('Direction', req.direction.wire),
            ('Category', req.category.nameEn),
            ('Region', req.region.nameEn),
            if (req.weightGrams != null) ('Weight', '${req.weightGrams} g'),
            if (req.purityKarat != null) ('Purity', req.purityKarat!.wire),
            if (req.quantity != null) ('Quantity', '${req.quantity}'),
          ];

          return ListView(
            padding: EdgeInsets.all(tokens.space.md),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      req.reference ?? req.id,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  KhStatusChip(
                    label: requestStateLabel(s, req.state),
                    tone: requestStateTone(req.state),
                  ),
                ],
              ),
              if (req.expiresAt != null) ...[
                SizedBox(height: tokens.space.sm),
                ExpiryCountdown(expiresAt: req.expiresAt!),
              ],
              SizedBox(height: tokens.space.lg),
              Wrap(
                spacing: tokens.space.md,
                runSpacing: tokens.space.sm,
                children: [
                  for (final e in specs)
                    SizedBox(
                      width: 140,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.$1,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: tokens.ink.withValues(alpha: 0.6),
                            ),
                          ),
                          Text(
                            e.$2,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: tokens.space.lg),
              Text(
                '${s.s('cus.s10.offers')}: ${req.offerCount}',
                key: const Key('offer-count'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (req.offerCount == 0) ...[
                SizedBox(height: tokens.space.sm),
                Text(
                  s.s('cus.s10.zeroOffers'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: tokens.ink.withValues(alpha: 0.65),
                  ),
                ),
              ],
              SizedBox(height: tokens.space.md),
              KhButton(
                label: s.s('cus.s10.viewOffers'),
                onPressed: () =>
                    context.push('/customer/requests/${req.id}/offers'),
              ),
              if (req.connectionId != null &&
                  req.connectionId!.isNotEmpty) ...[
                SizedBox(height: tokens.space.sm),
                KhButton(
                  label: s.s('cus.s10.openConnection'),
                  secondary: true,
                  onPressed: () =>
                      context.push('/customer/connections/${req.connectionId}'),
                ),
              ],
              SizedBox(height: tokens.space.xl),
              KhTextField(
                label: s.s('cus.s10.editNotes'),
                controller: _notes,
              ),
              KhTextField(
                label: s.s('cus.s10.budgetMin'),
                controller: _budgetMin,
                keyboardType: TextInputType.number,
              ),
              KhTextField(
                label: s.s('cus.s10.budgetMax'),
                controller: _budgetMax,
                keyboardType: TextInputType.number,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(s.s('cus.s10.budgetFlexible')),
                value: _flexible,
                onChanged: (v) => setState(() => _flexible = v),
              ),
              if (detail.actionError != null) ...[
                KhInlineError(
                  message: customerFailureMessage(
                    detail.actionError!,
                    s,
                    'cus.home.error',
                  ),
                ),
                SizedBox(height: tokens.space.md),
              ],
              KhButton(
                label: s.s('cus.s10.saveEdits'),
                busy: detail.saving,
                onPressed: () => ref
                    .read(ownerRequestDetailProvider(widget.requestId).notifier)
                    .save(
                      notes: _notes.text,
                      budgetMin: _budgetMin.text,
                      budgetMax: _budgetMax.text,
                      budgetIsFlexible: _flexible,
                    ),
              ),
              SizedBox(height: tokens.space.md),
              KhButton(
                label: s.s('cus.s10.cancelRequest'),
                destructive: true,
                busy: detail.cancelling,
                onPressed: () => _confirmCancel(s),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmCancel(KhStrings s) async {
    final reasons = const [
      'CHANGED_MIND',
      'FOUND_ELSEWHERE',
      'WRONG_DETAILS',
      'OTHER',
    ];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: Text(s.s('cus.s10.cancelRequest')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(s.s('cus.s10.cancelBody')),
                  const SizedBox(height: 12),
                  for (final r in reasons)
                    RadioListTile<String>(
                      dense: true,
                      title: Text(s.s('cus.cancel.$r')),
                      value: r,
                      groupValue: _cancelReason,
                      onChanged: (v) => setLocal(() => _cancelReason = v),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(s.s('common.cancel')),
                ),
                TextButton(
                  key: const Key('confirm-cancel-request'),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(s.s('cus.s10.cancelConfirm')),
                ),
              ],
            );
          },
        );
      },
    );
    if (confirmed == true && mounted) {
      await ref
          .read(ownerRequestDetailProvider(widget.requestId).notifier)
          .cancel(reason: _cancelReason);
    }
  }
}
