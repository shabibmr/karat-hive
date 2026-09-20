import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../controller/request_create_controller.dart';
import '../../controller/request_create_state.dart';
import 'create_flow_chrome.dart';

class TaxonomySinglePick extends StatelessWidget {
  const TaxonomySinglePick({
    super.key,
    required this.label,
    required this.nodes,
    required this.value,
    required this.onChanged,
    required this.locale,
    this.errorText,
  });

  final String label;
  final List<TaxonomyNode> nodes;
  final String? value;
  final ValueChanged<String> onChanged;
  final String locale;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final leaves = nodes;
    return KhSelectField<String>(
      label: label,
      value: value,
      errorText: errorText,
      searchable: leaves.length > 5,
      options: [
        for (final n in leaves)
          KhSelectOption(value: n.id, label: n.name(locale)),
      ],
      onChanged: onChanged,
    );
  }
}

/// Buy / Sell chooser for Coins & Bullion — one split container, not a TabBar.
class DirectionControl extends StatelessWidget {
  const DirectionControl({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final Direction? value;
  final ValueChanged<Direction> onChanged;

  static const _buyFill = Color(0xFFC8A046);
  static const _sellFill = Color(0xFF1A2744);
  static const _idleBuy = Color(0x33C8A046);
  static const _idleSell = Color(0x331A2744);

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final selected = value ?? Direction.buy;
    final buyOn = selected == Direction.buy;
    final sellOn = selected == Direction.sell;

    return Padding(
      padding: EdgeInsets.only(bottom: tokens.space.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(tokens.radius.lg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(tokens.radius.lg),
              child: SizedBox(
                height: 52,
                child: Row(
                  children: [
                    Expanded(
                      child: _DirectionHalf(
                        key: const Key('direction-buy'),
                        label: createCopy(context, 'create.buy', 'Buy'),
                        selected: buyOn,
                        fill: _buyFill,
                        idle: _idleBuy,
                        foreground: const Color(0xFF1C1B1A),
                        onTap: () => onChanged(Direction.buy),
                      ),
                    ),
                    Expanded(
                      child: _DirectionHalf(
                        key: const Key('direction-sell'),
                        label: createCopy(context, 'create.sell', 'Sell'),
                        selected: sellOn,
                        fill: _sellFill,
                        idle: _idleSell,
                        foreground: Colors.white,
                        onTap: () => onChanged(Direction.sell),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DirectionHalf extends StatelessWidget {
  const _DirectionHalf({
    super.key,
    required this.label,
    required this.selected,
    required this.fill,
    required this.idle,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color fill;
  final Color idle;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? fill : idle,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 160),
            style: (Theme.of(context).textTheme.titleMedium ?? const TextStyle())
                .copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected ? foreground : const Color(0xFF5C5A57),
              letterSpacing: 0.8,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

class CommonCreateFields extends StatelessWidget {
  const CommonCreateFields({
    super.key,
    required this.state,
    required this.controller,
    required this.locale,
  });

  final RequestCreateState state;
  final RequestCreateController controller;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KhTextField(
          label: createCopy(
            context,
            'create.notes',
            'Notes (optional)',
          ),
          initialValue: state.notes,
          errorText: state.fieldError('notes'),
          onChanged: controller.setNotes,
        ),
      ],
    );
  }
}

class WeightPurityFields extends StatelessWidget {
  const WeightPurityFields({
    super.key,
    required this.state,
    required this.controller,
    this.weightRequired = false,
    this.showWeight = true,
    this.purityAsChips = false,
  });

  final RequestCreateState state;
  final RequestCreateController controller;
  final bool weightRequired;
  final bool showWeight;
  final bool purityAsChips;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final karats = state.config?.karatList ?? const ['24', '22', '21', '18'];
    final purityError = state.fieldError('purityKarat');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showWeight) ...[
          KhNumericField(
            label: createCopy(context, 'create.weight', 'Weight'),
            unit: 'g',
            min: 0.10,
            max: 5000,
            decimalPlaces: 2,
            initialValue: state.weightGrams,
            errorText: state.fieldError('weightGrams'),
            rangeErrorText: createCopy(
              context,
              'create.weightRange',
              'Weight must be between 0.10 g and 5000.00 g',
            ),
            onChanged: (v) => controller.setWeightGrams(
              v?.toStringAsFixed(2),
            ),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              createCopy(context, 'create.weightApprox', 'Weight is approximate'),
            ),
            value: state.weightIsApproximate,
            onChanged: (v) => controller.setWeightApproximate(v ?? false),
          ),
        ],
        if (purityAsChips) ...[
          Text(
            createCopy(context, 'create.purity', 'Purity'),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          SizedBox(height: tokens.space.sm),
          Wrap(
            spacing: tokens.space.sm,
            runSpacing: tokens.space.sm,
            children: [
              for (final raw in karats)
                Builder(
                  builder: (context) {
                    final karat = karatFromConfig(raw);
                    final selected = state.purityKarat == karat;
                    return ChoiceChip(
                      key: Key('purity-chip-${karat.wire}'),
                      label: Text(karat.wire),
                      selected: selected,
                      onSelected: (_) => controller.setPurity(karat),
                    );
                  },
                ),
            ],
          ),
          if (purityError != null) ...[
            SizedBox(height: tokens.space.xs),
            Text(
              purityError,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ],
        ] else
          KhSelectField<Karat>(
            label: createCopy(context, 'create.purity', 'Purity'),
            value: state.purityKarat,
            errorText: purityError,
            searchable: false,
            options: [
              for (final raw in karats)
                KhSelectOption(
                  value: karatFromConfig(raw),
                  label: karatFromConfig(raw).wire,
                ),
            ],
            onChanged: controller.setPurity,
          ),
      ],
    );
  }
}

class OrnamentTypeChips extends StatelessWidget {
  const OrnamentTypeChips({
    super.key,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final OrnamentType? value;
  final ValueChanged<OrnamentType> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          createCopy(context, 'create.ornamentType', 'Ornament type'),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SizedBox(height: tokens.space.sm),
        Wrap(
          spacing: tokens.space.sm,
          runSpacing: tokens.space.sm,
          children: [
            for (final t in OrnamentType.values)
              if (t != OrnamentType.unknown)
                ChoiceChip(
                  key: Key('ornament-type-chip-${t.name}'),
                  label: Text(ornamentWire(t)),
                  selected: value == t,
                  onSelected: (_) => onChanged(t),
                ),
          ],
        ),
        if (errorText != null) ...[
          SizedBox(height: tokens.space.xs),
          Text(
            errorText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
        ],
      ],
    );
  }
}

class BudgetEditor extends StatelessWidget {
  const BudgetEditor({
    super.key,
    required this.state,
    required this.controller,
    this.mandatory = false,
  });

  final RequestCreateState state;
  final RequestCreateController controller;
  final bool mandatory;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          createCopy(
            context,
            'create.budget',
            mandatory ? 'Budget' : 'Budget (optional)',
          ),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SizedBox(height: tokens.space.sm),
        RadioListTile<BudgetMode>(
          title: Text(
            createCopy(context, 'create.budgetMaxOnly', 'Maximum only'),
          ),
          value: BudgetMode.maxOnly,
          groupValue: state.budgetMode,
          onChanged: (v) {
            if (v != null) controller.setBudgetMode(v);
          },
        ),
        RadioListTile<BudgetMode>(
          title: Text(
            createCopy(context, 'create.budgetRange', 'Min–max range'),
          ),
          value: BudgetMode.range,
          groupValue: state.budgetMode,
          onChanged: (v) {
            if (v != null) controller.setBudgetMode(v);
          },
        ),
        if (state.budgetMode == BudgetMode.range)
          KhNumericField(
            label: createCopy(context, 'create.budgetMin', 'Budget min'),
            unit: 'AED',
            initialValue: state.budgetMin,
            errorText: state.fieldError('budgetMin'),
            onChanged: (v) => controller.setBudgetMin(v?.toStringAsFixed(2)),
          ),
        KhNumericField(
          label: createCopy(context, 'create.budgetMax', 'Budget max'),
          unit: 'AED',
          initialValue: state.budgetMax,
          errorText: state.fieldError('budgetMax'),
          onChanged: (v) => controller.setBudgetMax(v?.toStringAsFixed(2)),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
            createCopy(
              context,
              'create.budgetFlexible',
              'Budget is flexible',
            ),
          ),
          value: state.budgetIsFlexible,
          onChanged: (v) => controller.setBudgetFlexible(v ?? false),
        ),
      ],
    );
  }
}
