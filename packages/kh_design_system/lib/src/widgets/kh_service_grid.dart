import 'package:flutter/material.dart';

import 'package:kh_design_system/src/tokens.dart';

/// Grid of [KhServiceCard]s: 2 × 2 on phones, one row of four once the
/// column is ≥ 520 px (`UI-Design-Context.md` §10). Cards in a row share the
/// tallest card's height, so titles that wrap don't stagger the arrows; pass
/// cards built with `expand: true`.
class KhServiceGrid extends StatelessWidget {
  const KhServiceGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final gap = context.tokens.space.s10;
    return LayoutBuilder(
      builder: (context, constraints) {
        final perRow = constraints.maxWidth >= 520 ? 4 : 2;
        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += perRow) {
          final slice = children.skip(i).take(perRow).toList();
          if (rows.isNotEmpty) rows.add(SizedBox(height: gap));
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var j = 0; j < slice.length; j++) ...[
                    if (j > 0) SizedBox(width: gap),
                    Expanded(child: slice[j]),
                  ],
                ],
              ),
            ),
          );
        }
        return Column(children: rows);
      },
    );
  }
}
