import 'package:flutter/material.dart';

import 'package:kh_design_system/src/tokens.dart';
import 'package:kh_design_system/src/typography.dart';

/// One cell of a [KhStatStrip].
class KhStatItem {
  const KhStatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.onTap,
    this.key,
  });

  final IconData icon;

  /// Already formatted; `–` while loading.
  final String value;
  final String label;
  final VoidCallback onTap;
  final Key? key;
}

/// Activity stats strip on Customer Home (`UI-Design-Context.md` §6.12).
///
/// Equal columns on a white panel; each cell is one tap target and one
/// semantics node ("3 Open, button").
class KhStatStrip extends StatelessWidget {
  const KhStatStrip({super.key, required this.items});

  final List<KhStatItem> items;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final radius = BorderRadius.circular(t.radius.card);
    final rule = BorderSide(color: t.inkBorderSoft);

    return Material(
      color: t.paper,
      shape: RoundedRectangleBorder(borderRadius: radius, side: rule),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: i == 0
                        ? null
                        : BorderDirectional(start: rule),
                  ),
                  child: _StatCell(item: items[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.item});

  final KhStatItem item;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final type = context.typography;

    return Semantics(
      button: true,
      label: '${item.value} ${item.label}',
      onTap: item.onTap,
      excludeSemantics: true,
      child: InkWell(
        key: item.key,
        onTap: item.onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: t.space.s12,
            vertical: t.space.s14,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: t.goldIconCircle,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, size: 18, color: t.goldDark),
              ),
              SizedBox(height: t.space.s6),
              Text(
                item.value,
                style: type.statNumber.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              SizedBox(height: t.space.s6),
              Text(
                item.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: type.statLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
