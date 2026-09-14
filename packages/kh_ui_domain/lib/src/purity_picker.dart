import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

/// SH-DOM-06 — purity (karat) picker. Default list: 24K / 22K / 21K / 18K.
class PurityPicker extends StatelessWidget {
  const PurityPicker({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.options = const [Karat.k24, Karat.k22, Karat.k21, Karat.k18],
    this.errorText,
    this.emptyLabel,
  });

  final String label;
  final Karat? value;
  final ValueChanged<Karat> onChanged;
  final List<Karat> options;
  final String? errorText;
  final String? emptyLabel;

  static int _karatInt(Karat k) => switch (k) {
        Karat.k24 => 24,
        Karat.k22 => 22,
        Karat.k21 => 21,
        Karat.k18 => 18,
        Karat.unknown => 0,
      };

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return KhSelectField<Karat>(
      label: label,
      value: value,
      emptyLabel: emptyLabel,
      errorText: errorText,
      searchable: false,
      options: [
        for (final k in options)
          if (k != Karat.unknown)
            KhSelectOption(
              value: k,
              label: KaratFormatter.karat(_karatInt(k), locale: locale),
            ),
      ],
      onChanged: onChanged,
    );
  }
}
