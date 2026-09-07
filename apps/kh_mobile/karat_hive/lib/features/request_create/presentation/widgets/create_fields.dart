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
    final leaves = taxonomyLeaves(nodes);
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

class DirectionControl extends StatelessWidget {
  const DirectionControl({
    super.key,
    required this.fixed,
    required this.value,
    required this.onChanged,
  });

  final bool fixed;
  final Direction? value;
  final ValueChanged<Direction> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final label = createCopy(context, 'create.direction', 'Direction');
    if (fixed) {
      final text = value == Direction.sell
          ? createCopy(context, 'create.sell', 'SELL')
          : createCopy(context, 'create.buy', 'BUY');
      return Padding(
        padding: EdgeInsets.only(bottom: tokens.space.md),
        child: InputDecorator(
          decoration: InputDecoration(labelText: label),
          child: Text(text),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        RadioListTile<Direction>(
          key: const Key('direction-buy'),
          title: Text(createCopy(context, 'create.buy', 'BUY')),
          value: Direction.buy,
          groupValue: value,
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
        RadioListTile<Direction>(
          key: const Key('direction-sell'),
          title: Text(createCopy(context, 'create.sell', 'SELL')),
          value: Direction.sell,
          groupValue: value,
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
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
        TaxonomySinglePick(
          label: createCopy(context, 'create.category', 'Category'),
          nodes: state.categories,
          value: state.categoryId,
          locale: locale,
          errorText: state.fieldError('categoryId'),
          onChanged: controller.setCategory,
        ),
        TaxonomySinglePick(
          label: createCopy(context, 'create.region', 'Region'),
          nodes: state.regions,
          value: state.regionId,
          locale: locale,
          errorText: state.fieldError('regionId'),
          onChanged: controller.setRegion,
        ),
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
  });

  final RequestCreateState state;
  final RequestCreateController controller;
  final bool weightRequired;
  final bool showWeight;

  @override
  Widget build(BuildContext context) {
    final karats = state.config?.karatList ?? const ['24', '22', '21', '18'];
    return Column(
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
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              createCopy(context, 'create.weightApprox', 'Weight is approximate'),
            ),
            value: state.weightIsApproximate,
            onChanged: controller.setWeightApproximate,
          ),
        ],
        KhSelectField<Karat>(
          label: createCopy(context, 'create.purity', 'Purity'),
          value: state.purityKarat,
          errorText: state.fieldError('purityKarat'),
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
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            createCopy(
              context,
              'create.budgetFlexible',
              'Budget is flexible',
            ),
          ),
          value: state.budgetIsFlexible,
          onChanged: controller.setBudgetFlexible,
        ),
      ],
    );
  }
}
