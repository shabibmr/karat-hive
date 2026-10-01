import 'package:flutter/material.dart';

import 'package:kh_design_system/src/tokens.dart';

/// Grid of [KhServiceCard]s: 2 × 2 on phones, one row of four once the
/// column is ≥ 520 px (`UI-Design-Context.md` §10). Cards have a fixed height
/// (scaled with text size), so a row stays even when titles wrap.
class KhServiceGrid extends StatelessWidget {
  const KhServiceGrid({
    super.key,
    required this.children,
    this.maxColumns = 4,
    this.spacing,
    this.equalizeHeight = true,
  }) : assert(maxColumns >= 1);

  final List<Widget> children;
  final int maxColumns;
  final double? spacing;
  final bool equalizeHeight;

  @override
  Widget build(BuildContext context) {
    final gap = spacing ?? context.tokens.space.s10;
    return LayoutBuilder(
      builder: (context, constraints) {
        final perRow = (constraints.maxWidth >= 520 ? 4 : 2).clamp(
          1,
          maxColumns,
        );
        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += perRow) {
          final slice = children.skip(i).take(perRow).toList();
          if (rows.isNotEmpty) rows.add(SizedBox(height: gap));
          final row = Row(
            crossAxisAlignment: equalizeHeight
                ? CrossAxisAlignment.stretch
                : CrossAxisAlignment.start,
            children: [
              for (var j = 0; j < slice.length; j++) ...[
                if (j > 0) SizedBox(width: gap),
                Expanded(child: slice[j]),
              ],
            ],
          );
          rows.add(equalizeHeight ? IntrinsicHeight(child: row) : row);
        }
        return Column(children: rows);
      },
    );
  }
}
