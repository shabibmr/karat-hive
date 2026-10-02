import 'package:flutter/material.dart';

/// The light photographic treatment used on Customer Home.
abstract final class KhHomeStyle {
  static const background = Color(0xFFFFFCF9);
  static const cream = Color(0xFFF0E6DC);
  static const gold = Color(0xFF855614);
  static const ink = Color(0xFF191917);
  static const muted = Color(0xFF888783);
  static const headline = Color(0xFF46433F);
  static const radius = 12.0;
  static const pagePadding = 14.0;
  static const gridGap = 12.0;
}

/// Centered brand logo with independently accessible bell and profile actions.
class KhBrandHeader extends StatelessWidget {
  const KhBrandHeader({
    super.key,
    required this.brandLabel,
    this.alertsLabel = '',
    this.profileLabel = '',
    this.onAlerts,
    this.onProfile,
    this.initial,
    this.hasUnread = false,
    this.trailing,
  });

  final String brandLabel;
  final String alertsLabel;
  final String profileLabel;
  final String? initial;
  final bool hasUnread;
  final VoidCallback? onAlerts;
  final VoidCallback? onProfile;

  /// Replaces the bell and profile actions (e.g. Guest "Log in").
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Semantics(
            label: brandLabel,
            image: true,
            excludeSemantics: true,
            child: Image.asset(
              'assets/karat-hive-logo.png',
              package: 'kh_design_system',
              key: const Key('brand-header-logo'),
              height: 48,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Text(
                brandLabel.toUpperCase(),
                textScaler: TextScaler.noScaling,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  package: 'kh_design_system',
                  fontSize: 10,
                  letterSpacing: 4.5,
                  color: KhHomeStyle.ink,
                ),
              ),
            ),
          ),
          PositionedDirectional(
            end: 10,
            bottom: 2,
            top: trailing == null ? null : 0,
            child: trailing ?? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  key: const Key('customer-home-alerts'),
                  tooltip: alertsLabel,
                  onPressed: onAlerts,
                  color: KhHomeStyle.gold,
                  style: IconButton.styleFrom(
                    fixedSize: const Size(44, 44),
                    minimumSize: const Size(44, 44),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications_none_rounded, size: 25),
                      if (hasUnread)
                        PositionedDirectional(
                          end: 1,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD92525),
                              shape: BoxShape.circle,
                              border: Border.all(color: KhHomeStyle.background),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  key: const Key('customer-home-profile'),
                  style: IconButton.styleFrom(
                    fixedSize: const Size(44, 44),
                    minimumSize: const Size(44, 44),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  tooltip: profileLabel,
                  onPressed: onProfile,
                  icon: CircleAvatar(
                    radius: 15,
                    backgroundColor: KhHomeStyle.cream,
                    foregroundColor: KhHomeStyle.gold,
                    child: initial == null
                        ? const Icon(Icons.person_outline, size: 20)
                        : Text(
                            initial!,
                            textScaler: TextScaler.noScaling,
                            style: const TextStyle(fontSize: 17),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
