import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

/// Shared Guest "How this works" steps: post → offers → accept → WhatsApp,
/// plus per-type [extras], in the 1a accordion (`UI-Design-Context.md` §6.13).
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
    final steps = <String>[
      l10n?.guestHowItWorksPost ?? 'Post a Request describing what you need',
      l10n?.guestHowItWorksOffers ?? 'Verified jewellers send competing Offers',
      l10n?.guestHowItWorksAccept ??
          'Accept one Offer — identities are revealed',
      l10n?.guestHowItWorksWhatsApp ?? 'Continue the conversation on WhatsApp',
      ...extras,
    ];

    return KhHowItWorksAccordion(
      key: const Key('how-this-works'),
      title: l10n?.guestHowItWorksTitle ?? 'How this works',
      steps: steps,
      initiallyExpanded: initiallyExpanded,
    );
  }
}
