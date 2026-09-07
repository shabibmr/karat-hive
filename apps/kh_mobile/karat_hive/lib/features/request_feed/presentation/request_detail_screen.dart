import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../controller/request_detail_controller.dart';

/// VEN-S08 — Request Detail Screen.
///
/// Strictly adheres to BR-006 (customer identity masked) and BR-008 (competitor
/// price and offers absent).
class RequestDetailScreen extends ConsumerWidget {
  const RequestDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(requestDetailProvider(requestId));
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Scaffold(
      key: const Key('request-detail-screen'),
      appBar: AppBar(
        title: Text('Request $requestId'),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: KhLoadingView()),
        error: (err, _) => Center(
          child: KhErrorView(
            message: 'Could not load request details.',
            onRetry: () => ref.invalidate(requestDetailProvider(requestId)),
          ),
        ),
        data: (item) {
          final isExpired = item.expiresAt != null &&
              item.expiresAt!.isBefore(DateTime.now().toUtc());
          final closedStates = {
            'EXPIRED',
            'CANCELLED',
            'CLOSED',
            'ACCEPTED',
            'WITHDRAWN',
          };
          final isClosed = closedStates.contains(item.state.toUpperCase());
          final actionsDisabled = isExpired || isClosed;
          final imageUrls = item.media
              .map((m) => m.displayUrl ?? m.thumbnailUrl ?? '')
              .where((url) => url.isNotEmpty)
              .toList(growable: false);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(tokens.space.md),
                  children: [
                    // Media Gallery (SH-MED-03)
                    if (imageUrls.isNotEmpty) ...[
                      KhImageGallery(imageUrls: imageUrls),
                      SizedBox(height: tokens.space.md),
                    ],

                    // Header row: Reference/Title + ExpiryCountdown
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.reference ?? 'Request Details',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.requestType.replaceAll('_', ' ')} · ${item.direction}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: tokens.ink.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (item.expiresAt != null)
                          ExpiryCountdown(expiresAt: item.expiresAt!),
                      ],
                    ),
                    SizedBox(height: tokens.space.md),

                    // Masked Customer Card (BR-006 / SH-ID-01 / SH-ID-07)
                    Card(
                      elevation: 0,
                      color: tokens.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(tokens.radius.md),
                        side: BorderSide(color: tokens.ink.withValues(alpha: 0.12)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(tokens.space.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customer Summary',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: tokens.ink.withValues(alpha: 0.5),
                              ),
                            ),
                            SizedBox(height: tokens.space.xs),
                            MaskedPartyLabel(party: item.customer),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: tokens.space.md),

                    // Specifications Grid
                    SpecificationGrid(item: item),
                    SizedBox(height: tokens.space.md),

                    if (item.notes != null && item.notes!.trim().isNotEmpty) ...[
                      Card(
                        elevation: 0,
                        color: tokens.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(tokens.radius.md),
                          side: BorderSide(
                            color: tokens.ink.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(tokens.space.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Customer Notes',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: tokens.ink.withValues(alpha: 0.5),
                                ),
                              ),
                              SizedBox(height: tokens.space.xs),
                              Text(
                                item.notes!,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: tokens.space.md),
                    ],

                    // Offers summary (Competitor price blind - BR-008)
                    Card(
                      elevation: 0,
                      color: tokens.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(tokens.radius.md),
                        side: BorderSide(color: tokens.ink.withValues(alpha: 0.12)),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.local_offer, color: tokens.gold),
                        title: Text(
                          '${item.offerCount} ${item.offerCount == 1 ? 'offer' : 'offers'} received',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          'Competitor pricing and terms are hidden per marketplace rules.',
                        ),
                      ),
                    ),
                    SizedBox(height: tokens.space.lg),
                  ],
                ),
              ),

              // Bottom action bar
              Container(
                padding: EdgeInsets.all(tokens.space.md),
                decoration: BoxDecoration(
                  color: tokens.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      offset: const Offset(0, -2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: SafeArea(
                  child: KhButton(
                    label: isExpired
                        ? 'Request Expired'
                        : isClosed
                            ? 'Request Closed'
                            : 'Make an Offer (CP-3)',
                    onPressed: actionsDisabled
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Bidding opens in Check-Point 3.'),
                              ),
                            );
                          },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
