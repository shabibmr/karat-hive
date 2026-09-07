library kh_ui_domain;

export 'src/expiry_countdown.dart';
export 'src/masked_party_label.dart';
export 'src/money_display.dart';
export 'src/offer_widgets.dart';
export 'src/relative_time_label.dart';
export 'src/specification_grid.dart';
export 'src/subscription_badge.dart';
export 'src/vendor_request_card.dart';

import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';

/// A checklist of the mandatory KYC documents and which are present.
class DocumentChecklist extends StatelessWidget {
  const DocumentChecklist({super.key, required this.present});
  final Set<VendorDocumentType> present;

  @override
  Widget build(BuildContext context) => Column(
        children: mandatoryVendorDocuments
            .map(
              (d) => ListTile(
                dense: true,
                leading: Icon(
                  present.contains(d) ? Icons.check_circle : Icons.radio_button_unchecked,
                ),
                title: Text(d.label),
              ),
            )
            .toList(growable: false),
      );
}

/// Multi-select tree picker for categories or regions.
class CategoryRegionPicker extends StatelessWidget {
  const CategoryRegionPicker({
    super.key,
    required this.nodes,
    required this.selected,
    required this.onToggle,
    required this.locale,
  });

  final List<TaxonomyNode> nodes;
  final Set<String> selected;
  final void Function(String id) onToggle;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final leaves = <TaxonomyNode>[];
    void walk(TaxonomyNode n) {
      if (n.children.isEmpty) {
        leaves.add(n);
      } else {
        n.children.forEach(walk);
      }
    }

    nodes.forEach(walk);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: leaves
          .map(
            (n) => FilterChip(
              label: Text(n.name(locale)),
              selected: selected.contains(n.id),
              onSelected: (_) => onToggle(n.id),
            ),
          )
          .toList(growable: false),
    );
  }
}

/// VE-03 / VEN-S03 status panel, reused as ACTIVE chrome on VEN-S05.
///
/// Labels are passed in so this package never depends on `kh_l10n`.
class VendorStatusCard extends StatelessWidget {
  const VendorStatusCard({
    super.key,
    required this.lifecycle,
    required this.tradingName,
    required this.lifecycleLabel,
    this.subtitle,
    this.verificationMessage,
  });

  final VendorLifecycle lifecycle;
  final String tradingName;
  final String lifecycleLabel;
  final String? subtitle;
  final String? verificationMessage;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final message = verificationMessage?.trim();

    return Card(
      key: const Key('vendor-status-card'),
      child: Padding(
        padding: EdgeInsets.all(tokens.space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    tradingName,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                _LifecycleChip(
                  lifecycle: lifecycle,
                  label: lifecycleLabel,
                ),
              ],
            ),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              SizedBox(height: tokens.space.sm),
              Text(subtitle!, style: theme.textTheme.bodyMedium),
            ],
            if (message != null && message.isNotEmpty) ...[
              SizedBox(height: tokens.space.md),
              KhInlineError(message: message),
            ],
          ],
        ),
      ),
    );
  }
}

class _LifecycleChip extends StatelessWidget {
  const _LifecycleChip({required this.lifecycle, required this.label});

  final VendorLifecycle lifecycle;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final (Color fg, Color bg) = switch (lifecycle) {
      VendorLifecycle.active || VendorLifecycle.verified => (
          tokens.ink,
          tokens.gold.withValues(alpha: 0.28),
        ),
      VendorLifecycle.rejected ||
      VendorLifecycle.suspended ||
      VendorLifecycle.deactivated => (
          tokens.danger,
          tokens.danger.withValues(alpha: 0.12),
        ),
      VendorLifecycle.pendingVerification || VendorLifecycle.registered => (
          const Color(0xFF8A5A00),
          const Color(0xFFFFE08A),
        ),
      VendorLifecycle.unknown => (
          tokens.ink.withValues(alpha: 0.7),
          tokens.ink.withValues(alpha: 0.08),
        ),
    };

    return Chip(
      avatar: lifecycle == VendorLifecycle.active
          ? Icon(Icons.verified, size: 16, color: fg)
          : null,
      label: Text(label),
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
      backgroundColor: bg,
      labelStyle: TextStyle(color: fg, fontWeight: FontWeight.w600),
    );
  }
}
