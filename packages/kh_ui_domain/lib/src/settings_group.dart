import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';

/// SH-SET-02 — Setting row widget with ink response, token spacing, and chevron.
class SettingRow extends StatelessWidget {
  const SettingRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.onTap,
    this.showChevron = false,
  });

  /// Accepts a [String] or [Widget].
  final dynamic title;

  /// Optional subtitle, accepts a [String] or [Widget].
  final dynamic subtitle;

  /// Optional leading icon, accepts [IconData] or [Widget].
  final dynamic leadingIcon;

  /// Optional trailing widget. If null and [showChevron] is true, a chevron is rendered.
  final Widget? trailing;

  /// Optional tap callback. If provided, renders an ink response.
  final VoidCallback? onTap;

  /// Whether to show a trailing chevron.
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;

    Widget titleWidget;
    if (title is Widget) {
      titleWidget = title as Widget;
    } else {
      titleWidget = Text(
        title?.toString() ?? '',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: tokens.ink,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    Widget? subtitleWidget;
    if (subtitle != null) {
      if (subtitle is Widget) {
        subtitleWidget = subtitle as Widget;
      } else {
        subtitleWidget = Text(
          subtitle.toString(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: tokens.ink.withValues(alpha: 0.6),
          ),
        );
      }
    }

    Widget? leadingWidget;
    if (leadingIcon != null) {
      if (leadingIcon is Widget) {
        leadingWidget = leadingIcon as Widget;
      } else if (leadingIcon is IconData) {
        leadingWidget = Icon(
          leadingIcon as IconData,
          size: 22,
          color: tokens.ink.withValues(alpha: 0.7),
        );
      }
    }

    Widget? trailingWidget = trailing;
    if (trailingWidget == null && showChevron) {
      trailingWidget = Icon(
        rtl ? Icons.chevron_left : Icons.chevron_right,
        size: 20,
        color: tokens.ink.withValues(alpha: 0.45),
      );
    }

    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space.md,
        vertical: tokens.space.sm + 2,
      ),
      child: Row(
        children: [
          if (leadingWidget != null) ...[
            leadingWidget,
            SizedBox(width: tokens.space.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                titleWidget,
                if (subtitleWidget != null) ...[
                  SizedBox(height: tokens.space.xs / 2),
                  subtitleWidget,
                ],
              ],
            ),
          ),
          if (trailingWidget != null) ...[
            SizedBox(width: tokens.space.sm),
            trailingWidget,
          ],
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}

/// SH-SET-02 — Settings group container with rounded corners, subtle border,
/// and dividers between children.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    super.key,
    this.title,
    this.description,
    required this.children,
  });

  /// Optional group header title.
  final String? title;

  /// Optional group description text.
  final String? description;

  /// Child rows / widgets in this group.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null && title!.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(
              left: tokens.space.xs,
              right: tokens.space.xs,
              bottom: tokens.space.xs,
            ),
            child: Text(
              title!,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: tokens.ink.withValues(alpha: 0.75),
              ),
            ),
          ),
        ],
        if (description != null && description!.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(
              left: tokens.space.xs,
              right: tokens.space.xs,
              bottom: tokens.space.sm,
            ),
            child: Text(
              description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: tokens.ink.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: tokens.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radius.md),
            side: BorderSide(
              color: tokens.ink.withValues(alpha: 0.12),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: tokens.ink.withValues(alpha: 0.08),
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
