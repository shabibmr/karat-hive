import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';

import 'create_flow_chrome.dart';

/// Specs block for Find An Ornament compose (`Find-orna-create.png`).
///
/// Title above a paper/hairline group of [FindSpecRow] children. No Edit
/// action — compose rows are inline-editable (Edit belongs on review).
class FindSpecsSection extends StatelessWidget {
  const FindSpecsSection({
    super.key,
    required this.children,
    this.title,
  });

  final List<Widget> children;

  /// Defaults to l10n `create.specs` / "Specs".
  final String? title;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final heading = title ?? createCopy(context, 'create.specs', 'Specs');

    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i < children.length - 1) {
        rows.add(Divider(height: 1, color: tokens.inkHairline));
      }
    }

    return Column(
      key: const Key('find-specs-section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          heading,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SizedBox(height: tokens.space.sm),
        Container(
          decoration: BoxDecoration(
            color: tokens.paper,
            borderRadius: BorderRadius.circular(tokens.radius.md),
            border: Border.all(color: tokens.inkHairline),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rows,
          ),
        ),
      ],
    );
  }
}
