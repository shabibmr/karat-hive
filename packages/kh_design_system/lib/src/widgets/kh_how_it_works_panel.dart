import 'package:flutter/material.dart';

import 'package:kh_design_system/src/tokens.dart';
import 'package:kh_design_system/src/typography.dart';

/// One icon step of a [KhHowItWorksPanel].
class KhHowStep {
  const KhHowStep({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// "How this works" panel for Customer Home (`UI-Design-Context.md` §6.13,
/// Panel variant): soft-gold panel, serif title, four icon steps in a row
/// numbered "1. Post a request". Guest Landing uses [KhHowItWorksAccordion].
class KhHowItWorksPanel extends StatelessWidget {
  const KhHowItWorksPanel({super.key, required this.title, required this.steps});

  final String title;
  final List<KhHowStep> steps;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final type = context.typography;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: t.space.s12,
        vertical: t.space.md,
      ),
      decoration: BoxDecoration(
        color: t.goldPanel,
        borderRadius: BorderRadius.circular(t.radius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              t.space.xs,
              0,
              t.space.xs,
              t.space.s12,
            ),
            child: Semantics(
              header: true,
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < steps.length; i++) ...[
                if (i > 0) SizedBox(width: t.space.xs),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: t.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: t.goldRing),
                        ),
                        child: Icon(steps[i].icon, size: 21, color: t.goldDark),
                      ),
                      SizedBox(height: t.space.s6),
                      Text(
                        '${i + 1}. ${steps[i].label}',
                        textAlign: TextAlign.center,
                        style: type.stepLabel,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
