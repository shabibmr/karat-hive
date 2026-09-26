import 'package:flutter/material.dart';

import 'package:kh_design_system/src/theme.dart';
import 'package:kh_design_system/src/tokens.dart';
import 'package:kh_design_system/src/typography.dart';

/// "How this works" accordion for Guest Landing
/// (`UI-Design-Context.md` §6.13, Accordion variant).
///
/// White panel with a serif header and chevron; when open, numbered lines
/// with a soft-gold number circle. Collapsed lines are removed from the tree,
/// not hidden.
class KhHowItWorksAccordion extends StatefulWidget {
  const KhHowItWorksAccordion({
    super.key,
    required this.title,
    required this.steps,
    this.initiallyExpanded = false,
  });

  final String title;
  final List<String> steps;
  final bool initiallyExpanded;

  @override
  State<KhHowItWorksAccordion> createState() => _KhHowItWorksAccordionState();
}

class _KhHowItWorksAccordionState extends State<KhHowItWorksAccordion> {
  late bool _open = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final type = context.typography;
    final body = Theme.of(context).textTheme.bodyMedium;
    final radius = BorderRadius.circular(t.radius.card);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Material(
      color: t.paper,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: t.inkBorderSoft),
      ),
      clipBehavior: Clip.antiAlias,
      child: AnimatedSize(
        duration: reduceMotion ? Duration.zero : KhMotion.reveal,
        curve: Curves.easeInOut,
        alignment: AlignmentDirectional.topStart,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              button: true,
              expanded: _open,
              child: InkWell(
                onTap: () => setState(() => _open = !_open),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: t.space.md,
                    vertical: t.space.s14,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(widget.title, style: type.accordionTitle),
                      ),
                      Icon(
                        _open ? Icons.expand_less : Icons.expand_more,
                        size: 22,
                        color: t.goldDark,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_open)
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  t.space.md,
                  0,
                  t.space.md,
                  t.space.s14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < widget.steps.length; i++) ...[
                      if (i > 0) SizedBox(height: t.space.sm),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: t.goldNumber,
                              shape: BoxShape.circle,
                            ),
                            child: Text('${i + 1}', style: type.numberBadge),
                          ),
                          SizedBox(width: t.space.s10),
                          Expanded(child: Text(widget.steps[i], style: body)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
