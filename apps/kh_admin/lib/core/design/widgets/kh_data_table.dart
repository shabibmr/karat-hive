import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';

/// One column of a [KhDataTable].
class KhTableColumn {
  const KhTableColumn(this.label, {this.flex = 1});

  final String label;

  /// Relative width, standing in for the mock's auto table layout.
  final int flex;
}

/// One row of a [KhDataTable]. [cells] must line up with the table's columns.
class KhTableRow {
  const KhTableRow({
    required this.cells,
    this.key,
    this.onTap,
  });

  final List<Widget> cells;
  final Key? key;
  final VoidCallback? onTap;
}

/// Bordered, horizontally scrollable table.
///
/// Port of `.table-wrap` + `table.data-table` (`ui-mock/css/components.css`
/// L418–L448): rounded bordered container, uppercase gold header row on the
/// surface tint, hairline row separators, and a 560px minimum width that
/// scrolls rather than squashing on narrow viewports.
class KhDataTable extends StatelessWidget {
  const KhDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.minWidth = 560,
  });

  final List<KhTableColumn> columns;
  final List<KhTableRow> rows;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final colors = kh.colors;
    final borderWidth = kh.shapes.cardBorderWidth;

    return LayoutBuilder(
      builder: (context, constraints) {
        // A horizontal viewport gives its child unbounded width, which the
        // `Expanded` columns cannot resolve. Size the content explicitly: fill
        // the available width, or fall back to [minWidth] and scroll.
        final inner = constraints.maxWidth.isFinite
            ? constraints.maxWidth - borderWidth * 2
            : minWidth;
        final contentWidth = inner > minWidth ? inner : minWidth;

        return Container(
          decoration: BoxDecoration(
            color: colors.backgroundElevated,
            borderRadius: kh.shapes.roundedLg,
            border: Border.all(color: colors.borderSubtle, width: borderWidth),
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: contentWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _headerRow(context),
                  for (var i = 0; i < rows.length; i++)
                    _bodyRow(context, rows[i], isLast: i == rows.length - 1),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _headerRow(BuildContext context) {
    final kh = context.kh;

    return Container(
      color: kh.colors.backgroundSurface,
      padding: EdgeInsets.symmetric(
        horizontal: kh.spacing.md,
        vertical: kh.spacing.sm,
      ),
      child: Row(
        children: [
          for (final column in columns)
            Expanded(
              flex: column.flex,
              child: Text(
                column.label.toUpperCase(),
                style: kh.typography.caption.copyWith(
                  color: kh.colors.goldPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _bodyRow(BuildContext context, KhTableRow row, {required bool isLast}) {
    final kh = context.kh;

    final rowWidget = Container(
      key: row.key,
      constraints: BoxConstraints(minHeight: kh.spacing.tableRowHeight),
      padding: EdgeInsets.symmetric(
        horizontal: kh.spacing.md,
        vertical: kh.spacing.sm,
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: kh.colors.borderSubtle)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < row.cells.length; i++)
            Expanded(
              flex: i < columns.length ? columns[i].flex : 1,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: row.cells[i],
              ),
            ),
        ],
      ),
    );

    if (row.onTap != null) {
      return InkWell(
        onTap: row.onTap,
        hoverColor: kh.colors.goldPrimary.withValues(alpha: 0.05),
        child: rowWidget,
      );
    }

    return rowWidget;
  }
}
