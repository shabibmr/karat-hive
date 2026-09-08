import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../controller/request_create_controller.dart';
import '../controller/request_create_state.dart';
import '../routes.dart';
import 'widgets/create_fields.dart';
import 'widgets/create_flow_chrome.dart';

class ComposeScreenHost extends ConsumerWidget {
  const ComposeScreenHost({
    super.key,
    required this.title,
    required this.stepLabel,
    required this.fields,
  });

  final String title;
  final String stepLabel;
  final Widget fields;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final locale = Localizations.localeOf(context).languageCode;
    final state = ref.watch(requestCreateControllerProvider);
    final controller = ref.read(requestCreateControllerProvider.notifier);

    Future<void> saveDraft() async {
      await controller.saveDraft();
    }

    return CreateFlowChrome(
      title: title,
      stepLabel: stepLabel,
      rateStrip: GoldRateStrip(rates: state.rates, karat: state.purityKarat),
      bottom: DraftActions(
        busy: state.busy,
        onSaveDraft: saveDraft,
        onContinue: () async {
          final ok = await controller.persistAndGo(RequestCreateStep.images);
          if (ok && context.mounted) context.go(RequestCreatePaths.images);
        },
      ),
      child: ListView(
        padding: EdgeInsets.all(tokens.space.md),
        children: [
          if (state.failure != null) ...[
            KhInlineError(
              message: state.failure!.message ??
                  createCopy(context, 'create.saveFailed', 'Could not save.'),
            ),
            SizedBox(height: tokens.space.sm),
          ],
          for (final w in state.warnings) ...[
            KhInlineError(message: w),
            SizedBox(height: tokens.space.sm),
          ],
          CommonCreateFields(
            state: state,
            controller: controller,
            locale: locale,
          ),
          fields,
        ],
      ),
    );
  }
}

/// CUS-S04 — Find An Ornament (CU-04). Direction fixed BUY.
class FindOrnamentScreen extends ConsumerWidget {
  const FindOrnamentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(requestCreateControllerProvider);
    final controller = ref.read(requestCreateControllerProvider.notifier);
    return ComposeScreenHost(
      title: createCopy(context, 'create.type.ornament', 'Find An Ornament'),
      stepLabel: createCopy(context, 'create.stepCompose', 'Specify the piece'),
      fields: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DirectionControl(
            fixed: true,
            value: Direction.buy,
            onChanged: controller.setDirection,
          ),
          KhSelectField<OrnamentType>(
            label: createCopy(context, 'create.ornamentType', 'Ornament type'),
            value: state.ornamentType,
            errorText: state.fieldError('ornamentType'),
            searchable: false,
            options: [
              for (final t in OrnamentType.values)
                if (t != OrnamentType.unknown)
                  KhSelectOption(value: t, label: ornamentWire(t)),
            ],
            onChanged: controller.setOrnamentType,
          ),
          WeightPurityFields(state: state, controller: controller),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              createCopy(context, 'create.gemstones', 'Includes gemstones'),
            ),
            value: state.gemstonesPresent,
            onChanged: controller.setGemstonesPresent,
          ),
          if (state.gemstonesPresent) ...[
            KhTextField(
              label: createCopy(context, 'create.gemstoneType', 'Gemstone type'),
              initialValue: state.gemstoneType,
              onChanged: controller.setGemstoneType,
            ),
            KhNumericField(
              label: createCopy(context, 'create.gemstoneCount', 'Gemstone count'),
              decimalPlaces: 0,
              min: 1,
              initialValue: state.gemstoneCount?.toString(),
              onChanged: (v) => controller.setGemstoneCount(v?.toInt()),
            ),
          ],
          BudgetEditor(
            state: state,
            controller: controller,
            mandatory: true,
          ),
        ],
      ),
    );
  }
}

/// CUS-S05 — Sell Old Gold (CU-05). Direction fixed SELL.
class SellOldGoldScreen extends ConsumerWidget {
  const SellOldGoldScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final state = ref.watch(requestCreateControllerProvider);
    final controller = ref.read(requestCreateControllerProvider.notifier);
    final value = controller.indicativeValueAed();
    return ComposeScreenHost(
      title: createCopy(context, 'create.type.sellGold', 'Sell Old Gold'),
      stepLabel: createCopy(context, 'create.stepCompose', 'Specify the piece'),
      fields: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DirectionControl(
            fixed: true,
            value: Direction.sell,
            onChanged: controller.setDirection,
          ),
          KhInlineError(
            message: createCopy(
              context,
              'create.actualItemPhotos',
              'Photos must be of the actual item — stock or catalogue images are not accepted.',
            ),
          ),
          SizedBox(height: tokens.space.md),
          KhSelectField<OrnamentType>(
            label: createCopy(context, 'create.ornamentType', 'Ornament type'),
            value: state.ornamentType,
            searchable: false,
            options: [
              for (final t in OrnamentType.values)
                if (t != OrnamentType.unknown)
                  KhSelectOption(value: t, label: ornamentWire(t)),
            ],
            onChanged: controller.setOrnamentType,
          ),
          WeightPurityFields(
            state: state,
            controller: controller,
            weightRequired: true,
          ),
          if (value != null) ...[
            Text(
              createCopy(
                context,
                'create.indicative',
                'Indicative valuation (estimate, not an offer)',
              ),
            ),
            MoneyDisplay(amount: value),
            SizedBox(height: tokens.space.md),
          ],
          KhSelectField<ItemCondition>(
            label: createCopy(
              context,
              'create.condition',
              'Condition (optional)',
            ),
            value: state.condition,
            searchable: false,
            options: [
              for (final c in ItemCondition.values)
                if (c != ItemCondition.unknown)
                  KhSelectOption(value: c, label: conditionWire(c)),
            ],
            onChanged: controller.setCondition,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              createCopy(
                context,
                'create.hasInvoice',
                'Original invoice or hallmark certificate',
              ),
            ),
            value: state.hasInvoice,
            onChanged: controller.setHasInvoice,
          ),
        ],
      ),
    );
  }
}

/// CUS-S06 — Gold Coins (CU-06).
class GoldCoinsScreen extends ConsumerWidget {
  const GoldCoinsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final state = ref.watch(requestCreateControllerProvider);
    final controller = ref.read(requestCreateControllerProvider.notifier);
    const denoms = ['1', '2.5', '5', '10', '20', '50', '100'];
    final total = controller.totalWeightGrams();
    return ComposeScreenHost(
      title: createCopy(context, 'create.type.coins', 'Gold Coins'),
      stepLabel: createCopy(context, 'create.stepCompose', 'Specify the piece'),
      fields: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DirectionControl(
            fixed: false,
            value: state.direction,
            onChanged: controller.setDirection,
          ),
          KhSelectField<String>(
            label: createCopy(
              context,
              'create.denomination',
              'Coin denomination',
            ),
            value: state.denominationGrams,
            errorText: state.fieldError('denominationGrams'),
            searchable: false,
            options: [
              for (final d in denoms) KhSelectOption(value: d, label: '$d g'),
            ],
            onChanged: controller.setDenomination,
          ),
          KhNumericField(
            label: createCopy(context, 'create.quantity', 'Quantity'),
            decimalPlaces: 0,
            min: 1,
            errorText: state.fieldError('quantity'),
            rangeErrorText: createCopy(
              context,
              'create.quantityPositive',
              'Quantity must be greater than 0',
            ),
            initialValue: state.quantity?.toString(),
            onChanged: (v) => controller.setQuantity(v?.toInt()),
          ),
          if (total != null) ...[
            Text(
              createCopy(context, 'create.totalWeight', 'Total weight'),
            ),
            Text('${total.toStringAsFixed(2)} g'),
            SizedBox(height: tokens.space.md),
          ],
          WeightPurityFields(state: state, controller: controller),
          KhTextField(
            label: createCopy(
              context,
              'create.mint',
              'Mint / brand (optional)',
            ),
            initialValue: state.mintOrRefiner,
            onChanged: controller.setMint,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              createCopy(context, 'create.packagingSealed', 'Sealed packaging'),
            ),
            value: state.packagingSealed ?? false,
            onChanged: controller.setPackagingSealed,
          ),
          if (state.direction == Direction.buy)
            BudgetEditor(state: state, controller: controller),
        ],
      ),
    );
  }
}

/// CUS-S07 — Gold Bullion (CU-07). Rate required to publish; compose allowed.
class GoldBullionScreen extends ConsumerWidget {
  const GoldBullionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final state = ref.watch(requestCreateControllerProvider);
    final controller = ref.read(requestCreateControllerProvider.notifier);
    final value = controller.indicativeValueAed();
    final floor = controller.bullionFloorAed();
    final noRate = state.rates == null || state.rates?.available != true;
    return ComposeScreenHost(
      title: createCopy(context, 'create.type.bullion', 'Gold Bullion'),
      stepLabel: createCopy(context, 'create.stepCompose', 'Specify the piece'),
      fields: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DirectionControl(
            fixed: false,
            value: state.direction,
            onChanged: controller.setDirection,
          ),
          if (noRate)
            Padding(
              padding: EdgeInsets.only(bottom: tokens.space.md),
              child: KhInlineError(
                message: createCopy(
                  context,
                  'create.bullionNeedsRate',
                  'A gold rate is required to publish bullion. You can still compose and save a draft.',
                ),
              ),
            ),
          KhNumericField(
            label: createCopy(context, 'create.barWeight', 'Bar weight'),
            unit: 'g',
            min: 0.10,
            max: 5000,
            initialValue: state.weightGrams,
            errorText: state.fieldError('weightGrams'),
            onChanged: (v) =>
                controller.setWeightGrams(v?.toStringAsFixed(2)),
          ),
          KhNumericField(
            label: createCopy(context, 'create.quantity', 'Quantity'),
            decimalPlaces: 0,
            min: 1,
            errorText: state.fieldError('quantity'),
            initialValue: state.quantity?.toString(),
            onChanged: (v) => controller.setQuantity(v?.toInt()),
          ),
          WeightPurityFields(state: state, controller: controller),
          KhTextField(
            label: createCopy(
              context,
              'create.refiner',
              'Refiner / brand (optional)',
            ),
            initialValue: state.mintOrRefiner,
            onChanged: controller.setMint,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              createCopy(
                context,
                'create.assay',
                'Serial / assay certificate present',
              ),
            ),
            value: state.hasAssayCertificate,
            onChanged: controller.setHasAssayCertificate,
          ),
          if (value != null && floor != null) ...[
            Text(
              createCopy(
                context,
                'create.indicative',
                'Indicative valuation (estimate, not an offer)',
              ),
            ),
            Row(
              children: [
                Text('${createCopy(context, 'create.bullionFloor', 'Minimum')}: '),
                MoneyDisplay(amount: floor),
              ],
            ),
            if (value < floor)
              KhInlineError(
                message: createCopy(
                  context,
                  'create.bullionBelow',
                  'Indicative value is below the platform minimum. Publish will be refused.',
                ),
              ),
            SizedBox(height: tokens.space.md),
          ],
          if (state.direction == Direction.buy)
            BudgetEditor(state: state, controller: controller),
        ],
      ),
    );
  }
}
