import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';

/// SH-REQ-05 — Ornament type picker.
///
/// Default options: Ring, Chain, Bangle, Necklace, Earring, Bracelet, Pendant, Other.
class OrnamentTypePicker extends StatelessWidget {
  const OrnamentTypePicker({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.options = const [
      OrnamentType.ring,
      OrnamentType.chain,
      OrnamentType.bangle,
      OrnamentType.necklace,
      OrnamentType.earring,
      OrnamentType.bracelet,
      OrnamentType.pendant,
      OrnamentType.other,
    ],
    this.errorText,
    this.emptyLabel,
  });

  final String label;
  final OrnamentType? value;
  final ValueChanged<OrnamentType> onChanged;
  final List<OrnamentType> options;
  final String? errorText;
  final String? emptyLabel;

  static String labelForOrnamentType(OrnamentType type) => switch (type) {
        OrnamentType.ring => 'Ring',
        OrnamentType.chain => 'Chain',
        OrnamentType.bangle => 'Bangle',
        OrnamentType.necklace => 'Necklace',
        OrnamentType.earring => 'Earring',
        OrnamentType.bracelet => 'Bracelet',
        OrnamentType.pendant => 'Pendant',
        OrnamentType.other => 'Other',
        OrnamentType.unknown => 'Unknown',
      };

  @override
  Widget build(BuildContext context) {
    return KhSelectField<OrnamentType>(
      key: const Key('ornament-type-picker'),
      label: label,
      value: value,
      emptyLabel: emptyLabel,
      errorText: errorText,
      searchable: false,
      options: [
        for (final o in options)
          if (o != OrnamentType.unknown)
            KhSelectOption(
              value: o,
              label: labelForOrnamentType(o),
            ),
      ],
      onChanged: onChanged,
    );
  }
}
