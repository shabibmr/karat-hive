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

/// Reusable Ink Pill Chip for selection rows (Ornament types, Purity, Denominations).
/// Active state = `#1C1B1A` ink pill background with white text; inactive state = outlined pill background.
class _InkPillChip extends StatelessWidget {
  const _InkPillChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const _inkColor = Color(0xFF1C1B1A);
  static const _outlineBorder = Color(0xFFE6E4E0);

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radius.full),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: tokens.space.md,
            vertical: tokens.space.xs + 2,
          ),
          decoration: BoxDecoration(
            color: selected ? _inkColor : Colors.transparent,
            borderRadius: BorderRadius.circular(tokens.radius.full),
            border: Border.all(
              color: selected ? _inkColor : _outlineBorder,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: (Theme.of(context).textTheme.labelMedium ?? const TextStyle()).copyWith(
              color: selected ? Colors.white : _inkColor,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// 46px height segmented pill control for Buy / Sell direction.
/// Animated Buy (`#C8A046` gold fill) and Sell (`#1C1B1A` ink fill) state transitions.
class DirectionControl extends StatelessWidget {
  const DirectionControl({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final Direction? value;
  final ValueChanged<Direction> onChanged;

  static const _goldFill = Color(0xFFC8A046);
  static const _inkFill = Color(0xFF1C1B1A);
  static const _trackBg = Color(0xFFF5F4F0);

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final selected = value ?? Direction.buy;
    final isBuy = selected == Direction.buy;

    return Padding(
      padding: EdgeInsets.only(bottom: tokens.space.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            height: 46,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: _trackBg,
              borderRadius: BorderRadius.circular(23),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    key: const Key('direction-buy'),
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChanged(Direction.buy),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: isBuy ? _goldFill : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isBuy
                            ? [
                                BoxShadow(
                                  color: _goldFill.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        createCopy(context, 'create.buy', 'Buy'),
                        style: (Theme.of(context).textTheme.titleMedium ??
                                const TextStyle())
                            .copyWith(
                          fontWeight: isBuy ? FontWeight.w700 : FontWeight.w600,
                          color: isBuy ? const Color(0xFF1C1B1A) : const Color(0xFF5C5A57),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    key: const Key('direction-sell'),
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChanged(Direction.sell),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: !isBuy ? _inkFill : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: !isBuy
                            ? [
                                BoxShadow(
                                  color: _inkFill.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        createCopy(context, 'create.sell', 'Sell'),
                        style: (Theme.of(context).textTheme.titleMedium ??
                                const TextStyle())
                            .copyWith(
                          fontWeight: !isBuy ? FontWeight.w700 : FontWeight.w600,
                          color: !isBuy ? Colors.white : const Color(0xFF5C5A57),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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

/// 2-up grid row pairing Weight (grams numeric input, 48px height) with 4-up Purity chip row (24K, 22K, 21K, 18K).
class WeightPurityFields extends StatelessWidget {
  const WeightPurityFields({
    super.key,
    required this.state,
    required this.controller,
    this.weightRequired = false,
    this.showWeight = true,
    this.purityAsChips = false,
    this.purityOptional = false,
  });

  final RequestCreateState state;
  final RequestCreateController controller;
  final bool weightRequired;
  final bool showWeight;
  final bool purityAsChips;
  final bool purityOptional;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final karats = state.config?.karatList ?? const ['24', '22', '21', '18'];
    final purityError = state.fieldError('purityKarat');

    final weightWidget = KhNumericField(
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
    );

    Widget purityWidget;
    if (purityAsChips) {
      purityWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            purityOptional
                ? createCopy(
                    context,
                    'create.purityOptional',
                    'Purity (optional)',
                  )
                : createCopy(context, 'create.purity', 'Purity'),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          SizedBox(height: tokens.space.sm),
          Wrap(
            spacing: tokens.space.xs,
            runSpacing: tokens.space.xs,
            children: [
              for (final raw in karats)
                Builder(
                  builder: (context) {
                    final karat = karatFromConfig(raw);
                    final selected = state.purityKarat == karat;
                    return _InkPillChip(
                      key: Key('purity-chip-${karat.wire}'),
                      label: karat.wire,
                      selected: selected,
                      onTap: () => controller.setPurity(karat),
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
        ],
      );
    } else {
      purityWidget = KhSelectField<Karat>(
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
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showWeight && purityAsChips)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: weightWidget),
              SizedBox(width: tokens.space.md),
              Expanded(child: purityWidget),
            ],
          )
        else ...[
          if (showWeight) weightWidget,
          if (showWeight) SizedBox(height: tokens.space.sm),
          purityWidget,
        ],
        if (showWeight)
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
    );
  }
}

/// 9 ornament type chips (Ring, Necklace, Bracelet, Bangle, Earrings, Pendant, Chain, Anklet, Other).
/// Active state = `#1C1B1A` ink pill background with white text; inactive state = outlined pill background.
class OrnamentTypeChips extends StatelessWidget {
  const OrnamentTypeChips({
    super.key,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.optional = false,
  });

  final OrnamentType? value;
  final ValueChanged<OrnamentType> onChanged;
  final String? errorText;
  final bool optional;

  String _displayName(BuildContext context, OrnamentType t) {
    return switch (t) {
      OrnamentType.ring => createCopy(context, 'create.ornament.ring', 'Ring'),
      OrnamentType.necklace => createCopy(context, 'create.ornament.necklace', 'Necklace'),
      OrnamentType.bracelet => createCopy(context, 'create.ornament.bracelet', 'Bracelet'),
      OrnamentType.bangle => createCopy(context, 'create.ornament.bangle', 'Bangle'),
      OrnamentType.earring => createCopy(context, 'create.ornament.earring', 'Earrings'),
      OrnamentType.pendant => createCopy(context, 'create.ornament.pendant', 'Pendant'),
      OrnamentType.chain => createCopy(context, 'create.ornament.chain', 'Chain'),
      OrnamentType.other => createCopy(context, 'create.ornament.other', 'Other'),
      _ => ornamentWire(t),
    };
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final types = OrnamentType.values.where((t) => t != OrnamentType.unknown).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          optional
              ? createCopy(
                  context,
                  'create.ornamentTypeOptional',
                  'Ornament type (optional)',
                )
              : createCopy(context, 'create.ornamentType', 'Ornament type'),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SizedBox(height: tokens.space.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final t in types) ...[
                _InkPillChip(
                  key: Key('ornament-type-chip-${t.name}'),
                  label: _displayName(context, t),
                  selected: value == t,
                  onTap: () => onChanged(t),
                ),
                SizedBox(width: tokens.space.xs),
              ],
            ],
          ),
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

/// Segmented control switching between "Maximum only" (1-up Max field) and "Min–max range" (2-up Min + Max fields).
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

  static const _inkColor = Color(0xFF1C1B1A);
  static const _trackBg = Color(0xFFF5F4F0);

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isRange = state.budgetMode == BudgetMode.range;

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
        Container(
          height: 40,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: _trackBg,
            borderRadius: BorderRadius.circular(tokens.radius.lg),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.setBudgetMode(BudgetMode.maxOnly),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: !isRange ? _inkColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(tokens.radius.md),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      createCopy(context, 'create.budgetMaxOnly', 'Maximum only'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: !isRange ? FontWeight.w700 : FontWeight.w600,
                        color: !isRange ? Colors.white : const Color(0xFF5C5A57),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.setBudgetMode(BudgetMode.range),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: isRange ? _inkColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(tokens.radius.md),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      createCopy(context, 'create.budgetRange', 'Min–max range'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isRange ? FontWeight.w700 : FontWeight.w600,
                        color: isRange ? Colors.white : const Color(0xFF5C5A57),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.space.md),
        if (isRange)
          Row(
            children: [
              Expanded(
                child: KhNumericField(
                  key: const ValueKey('create-field-budgetMin'),
                  label: createCopy(context, 'create.budgetMin', 'Budget min'),
                  unit: 'AED',
                  initialValue: state.budgetMin,
                  errorText: state.fieldError('budgetMin'),
                  onChanged: (v) => controller.setBudgetMin(v?.toStringAsFixed(2)),
                ),
              ),
              SizedBox(width: tokens.space.md),
              Expanded(
                child: KhNumericField(
                  key: const ValueKey('create-field-budgetMax'),
                  label: createCopy(context, 'create.budgetMax', 'Budget max'),
                  unit: 'AED',
                  initialValue: state.budgetMax,
                  errorText: state.fieldError('budgetMax'),
                  onChanged: (v) => controller.setBudgetMax(v?.toStringAsFixed(2)),
                ),
              ),
            ],
          )
        else
          KhNumericField(
            key: const ValueKey('create-field-budgetMax'),
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

/// 7-up Denomination chips (1, 2.5, 5, 10, 20, 50, 100 g). Active state ink pill.
class CoinDenominationChips extends StatelessWidget {
  const CoinDenominationChips({
    super.key,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.optional = false,
  });

  final String? value;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool optional;

  static const denoms = ['1', '2.5', '5', '10', '20', '50', '100'];

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          optional
              ? createCopy(
                  context,
                  'create.denominationOptional',
                  'Coin denomination (optional)',
                )
              : createCopy(context, 'create.denomination', 'Coin denomination'),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SizedBox(height: tokens.space.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final d in denoms) ...[
                _InkPillChip(
                  key: Key('denom-chip-$d'),
                  label: '$d g',
                  selected: value == d,
                  onTap: () => onChanged(d),
                ),
                SizedBox(width: tokens.space.xs),
              ],
            ],
          ),
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

/// Compact stepper (– / + buttons with quantity integer display) with optional live total weight badge.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 999,
    this.label,
    this.totalWeightGrams,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final String? label;
  final double? totalWeightGrams;

  static const _inkColor = Color(0xFF1C1B1A);
  static const _goldFill = Color(0xFFC8A046);

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final fieldLabel = label ?? createCopy(context, 'create.quantity', 'Quantity');
    final canDecrement = value > min;
    final canIncrement = value < max;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.space.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fieldLabel,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (totalWeightGrams != null && totalWeightGrams! > 0) ...[
                  SizedBox(height: tokens.space.xxs),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _goldFill.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(tokens.radius.sm),
                      border: Border.all(color: _goldFill.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '${createCopy(context, 'create.totalWeight', 'Total weight')}: ${totalWeightGrams!.toStringAsFixed(2)} g',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8C6B1B),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F4F0),
              borderRadius: BorderRadius.circular(tokens.radius.full),
              border: Border.all(color: const Color(0xFFE6E4E0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: canDecrement ? () => onChanged(value - 1) : null,
                  color: _inkColor,
                  disabledColor: Colors.grey.shade400,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                ),
                Container(
                  constraints: const BoxConstraints(minWidth: 32),
                  alignment: Alignment.center,
                  child: Text(
                    '$value',
                    style: (Theme.of(context).textTheme.titleMedium ??
                            const TextStyle())
                        .copyWith(
                      fontWeight: FontWeight.w700,
                      color: _inkColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: canIncrement ? () => onChanged(value + 1) : null,
                  color: _inkColor,
                  disabledColor: Colors.grey.shade400,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
