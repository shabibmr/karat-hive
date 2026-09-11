import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

/// Shared Guest "How this works" steps: post → offers → accept → WhatsApp.
class HowThisWorks extends StatelessWidget {
  const HowThisWorks({
    super.key,
    this.extras = const [],
    this.initiallyExpanded = false,
  });

  final List<String> extras;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final steps = <String>[
      l10n?.guestHowItWorksPost ?? 'Post a Request describing what you need',
      l10n?.guestHowItWorksOffers ?? 'Verified jewellers send competing Offers',
      l10n?.guestHowItWorksAccept ??
          'Accept one Offer — identities are revealed',
      l10n?.guestHowItWorksWhatsApp ?? 'Continue the conversation on WhatsApp',
      ...extras,
    ];

    return ExpansionTile(
      key: const Key('how-this-works'),
      initiallyExpanded: initiallyExpanded,
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.only(bottom: tokens.space.sm),
      title: Text(
        l10n?.guestHowItWorksTitle ?? 'How this works',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      children: [
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: tokens.space.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${i + 1}.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(width: tokens.space.xs),
                Expanded(
                  child: Text(
                    steps[i],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
