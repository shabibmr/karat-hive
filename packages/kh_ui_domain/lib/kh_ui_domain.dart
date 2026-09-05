library kh_ui_domain;

import 'package:flutter/material.dart';
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
