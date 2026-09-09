import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';

/// SH-ID-04 — Star rating input (1–5 mandatory).
///
/// Controlled: the parent owns [value] / [onChanged]. A null [value] is the
/// unset state before the first tap; whether the field is required at submit
/// is enforced by the leave-review screen, not this widget.
class StarRatingInput extends StatelessWidget {
  const StarRatingInput({
    super.key,
    this.value,
    this.onChanged,
    this.enabled = true,
    this.errorText,
    this.label,
    this.helperText,
    this.starSize = 40,
  }) : assert(value == null || (value >= 1 && value <= 5));

  /// Selected rating 1–5, or null when unset.
  final int? value;

  /// Invoked with the tapped star (1–5). Null disables interaction.
  final ValueChanged<int>? onChanged;

  final bool enabled;
  final String? errorText;
  final String? label;
  final String? helperText;
  final double starSize;

  bool get _interactive => enabled && onChanged != null;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final selected = value;
    final hasError = errorText != null && errorText!.trim().isNotEmpty;
    final starColor = hasError ? tokens.danger : tokens.gold;
    final emptyColor = hasError
        ? tokens.danger.withValues(alpha: 0.45)
        : tokens.ink.withValues(alpha: 0.28);

    return Column(
      key: const Key('star-rating-input'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null && label!.trim().isNotEmpty) ...[
          Text(
            key: const Key('star-rating-input-label'),
            label!,
            style: theme.textTheme.labelLarge?.copyWith(
              color: hasError ? tokens.danger : tokens.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: tokens.space.sm),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 1; i <= 5; i++)
              _StarButton(
                index: i,
                filled: selected != null && i <= selected,
                size: starSize,
                filledColor: starColor,
                emptyColor: emptyColor,
                interactive: _interactive,
                onTap: _interactive ? () => onChanged!(i) : null,
              ),
          ],
        ),
        if (helperText != null &&
            helperText!.trim().isNotEmpty &&
            !hasError) ...[
          SizedBox(height: tokens.space.xs),
          Text(
            key: const Key('star-rating-input-helper'),
            helperText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: tokens.ink.withValues(alpha: 0.65),
            ),
          ),
        ],
        if (hasError) ...[
          SizedBox(height: tokens.space.xs),
          Text(
            key: const Key('star-rating-input-error'),
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: tokens.danger,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _StarButton extends StatelessWidget {
  const _StarButton({
    required this.index,
    required this.filled,
    required this.size,
    required this.filledColor,
    required this.emptyColor,
    required this.interactive,
    required this.onTap,
  });

  final int index;
  final bool filled;
  final double size;
  final Color filledColor;
  final Color emptyColor;
  final bool interactive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: interactive,
      enabled: interactive,
      selected: filled,
      label: '$index of 5 stars',
      child: InkWell(
        key: Key('star-rating-input-star-$index'),
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: filled ? filledColor : emptyColor,
          ),
        ),
      ),
    );
  }
}
