import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../../../app/platform/open_url.dart';
import '../../../core/failure_copy.dart';
import '../controller/connections_controller.dart';

/// CUS-S15 — revealed Vendor identity, Talk, close, review, report.
class ConnectionDetailScreen extends ConsumerStatefulWidget {
  const ConnectionDetailScreen({super.key, required this.connectionId});

  final String connectionId;

  @override
  ConsumerState<ConnectionDetailScreen> createState() =>
      _ConnectionDetailScreenState();
}

class _ConnectionDetailScreenState extends ConsumerState<ConnectionDetailScreen>
    with WidgetsBindingObserver {
  var _obscureIdentity = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _obscureIdentity = state == AppLifecycleState.inactive ||
          state == AppLifecycleState.paused;
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(connectionDetailProvider(widget.connectionId));
    final s = KhStrings.of(context);
    final tokens = context.tokens;

    return Stack(
      children: [
        Scaffold(
          key: const Key('connection-detail-screen'),
          appBar: AppBar(
            title: Text(s.s('connections.title')),
            actions: [
              IconButton(
                key: const Key('connection-report'),
                tooltip: s.s('connections.report'),
                onPressed: async.valueOrNull == null
                    ? null
                    : () => context.push(
                          '/customer/report?entityType=CONNECTION&entityId=${widget.connectionId}',
                        ),
                icon: const Icon(Icons.flag_outlined),
              ),
            ],
          ),
          body: async.when(
            loading: () => const KhLoadingView(),
            error: (err, _) => KhErrorView(
              message: khFailureMessage(err, s.s('common.retry')),
              onRetry: () => ref
                  .read(connectionDetailProvider(widget.connectionId).notifier)
                  .reload(),
              retryLabel: s.s('common.retry'),
            ),
            data: (c) => _Body(connection: c),
          ),
        ),
        if (_obscureIdentity)
          Positioned.fill(
            child: ColoredBox(
              color: tokens.surface,
              child: Center(
                child: Icon(Icons.visibility_off_outlined, color: tokens.gold, size: 48),
              ),
            ),
          ),
      ],
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.connection});

  final ConnectionForCustomer connection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = KhStrings.of(context);
    final tokens = context.tokens;
    final vendor = connection.vendor;
    final active = connection.state == ConnectionState.active;
    final talk = connection.talk;
    final price = num.tryParse(connection.acceptedOffer?.terms.offeredPrice ?? '');
    final notifier =
        ref.read(connectionDetailProvider(connection.id).notifier);

    return ListView(
      padding: EdgeInsets.all(tokens.space.md),
      children: [
        if (!active)
          Padding(
            padding: EdgeInsets.only(bottom: tokens.space.md),
            child: KhInlineError(message: s.s('connections.closedBanner')),
          ),
        Text(
          vendor.displayName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        SizedBox(height: tokens.space.xs),
        KhStatusChip(
          label: connection.state.wire,
          tone: active ? KhStatusTone.success : KhStatusTone.neutral,
        ),
        SizedBox(height: tokens.space.md),
        _Fact(label: s.s('profile.mobile'), value: vendor.mobile.e164),
        if (vendor.business?.contactPersonName != null)
          _Fact(
            label: 'Contact',
            value: vendor.business!.contactPersonName!,
          ),
        if (vendor.address != null || vendor.business?.businessAddress != null)
          _Fact(
            label: 'Address',
            value: vendor.address ?? vendor.business!.businessAddress!,
          ),
        if (vendor.region != null)
          _Fact(label: 'Region', value: vendor.region!.nameEn),
        if (connection.request?.reference != null)
          _Fact(
            label: 'Request',
            value: connection.request!.reference!,
          ),
        if (price != null) ...[
          SizedBox(height: tokens.space.sm),
          Text(s.s('dashboard.rating').isEmpty ? 'Offer' : 'Accepted Offer'),
          MoneyDisplay(amount: price, highlight: true),
        ],
        if (connection.acceptedOffer?.terms.vendorNote != null)
          Padding(
            padding: EdgeInsets.only(top: tokens.space.sm),
            child: Text(connection.acceptedOffer!.terms.vendorNote!),
          ),
        SizedBox(height: tokens.space.lg),
        KhButton(
          key: const Key('talk-button'),
          label: s.s('connections.talk'),
          onPressed: !talk.available
              ? null
              : () async {
                  await notifier.talkOpened();
                  if (talk.waUrl.isEmpty) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(s.s('connections.talkUnavailable'))),
                    );
                    return;
                  }
                  final opened = await openExternalUrl(talk.waUrl);
                  if (!opened && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(s.s('connections.talkUnavailable'))),
                    );
                  }
                },
        ),
        SizedBox(height: tokens.space.sm),
        KhButton(
          key: const Key('copy-number-button'),
          label: s.s('connections.copyNumber'),
          secondary: true,
          onPressed: () async {
            await Clipboard.setData(
              ClipboardData(text: vendor.mobile.e164),
            );
            await notifier.numberCopied();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(s.s('connections.numberCopied'))),
            );
          },
        ),
        SizedBox(height: tokens.space.lg),
        KhButton(
          key: const Key('leave-review-button'),
          label: s.s('connections.leaveReview'),
          secondary: true,
          onPressed: () =>
              context.push('/customer/connections/${connection.id}/review'),
        ),
        if (active) ...[
          SizedBox(height: tokens.space.sm),
          KhButton(
            key: const Key('close-connection-button'),
            label: s.s('connections.close'),
            destructive: true,
            onPressed: () async {
              final ok = await showKhConfirmDialog(
                context,
                title: s.s('connections.closeConfirmTitle'),
                body: s.s('connections.closeConfirmBody'),
                confirmLabel: s.s('connections.close'),
                cancelLabel: s.s('common.cancel'),
                destructive: true,
              );
              if (ok != true) return;
              final result = await notifier.close();
              if (!context.mounted) return;
              result.when(
                ok: (_) => context.push(
                  '/customer/connections/${connection.id}/review',
                ),
                err: (f) => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(khFailureMessage(f, s.s('common.retry'))),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.space.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: tokens.ink.withValues(alpha: 0.6),
                ),
          ),
          SelectableText(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
