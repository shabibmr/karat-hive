import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';

/// One Specs row for Find An Ornament compose (`Find-orna-create.png`).
///
/// Label above [child], no leading icon (unlike [SellIconFieldRow]).
class FindSpecRow extends StatelessWidget {
  const FindSpecRow({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final fonts = KhFonts.forLocale(Localizations.maybeLocaleOf(context));

    return Padding(
      padding: EdgeInsets.all(tokens.space.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            fonts.isArabic ? label : label.toUpperCase(),
            style: fonts
                .sansStyle(10, FontWeight.w600, trackingEm: 0.10)
                .copyWith(color: tokens.inkSecondary),
          ),
          SizedBox(height: tokens.space.sm),
          child,
        ],
      ),
    );
  }
}
