import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../../app/guards.dart';
import '../controller/request_create_controller.dart';
import '../controller/request_create_state.dart';
import '../routes.dart';
import 'widgets/create_fields.dart';
import 'widgets/create_flow_chrome.dart';
import 'widgets/request_images_section.dart';

class ComposeScreenHost extends ConsumerStatefulWidget {
  const ComposeScreenHost({
    super.key,
    required this.title,
    this.eyebrow,
    required this.stepLabel,
    required this.fields,
    this.combineImages = false,
    this.showActualItemNotice = false,
  });

  final String title;
  final String? eyebrow;
  final String stepLabel;
  final Widget fields;

  /// Find Jewellery / Sell Gold: details + photos on one page → review.
  final bool combineImages;
  final bool showActualItemNotice;

  @override
  ConsumerState<ComposeScreenHost> createState() => _ComposeScreenHostState();
}

class _ComposeScreenHostState extends ConsumerState<ComposeScreenHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(requestCreateControllerProvider.notifier).ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final locale = Localizations.localeOf(context).languageCode;
    final state = ref.watch(requestCreateControllerProvider);
    final controller = ref.read(requestCreateControllerProvider.notifier);

    Future<void> saveDraft() async {
      final ok = await controller.saveDraft();
      if (ok && context.mounted) {
        controller.resetFlow();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              createCopy(context, 'create.draftSaved', 'Draft saved'),
            ),
          ),
        );
        context.go('${AppGuards.customerRequests}?tab=DRAFTS');
      }
    }

    final String effectiveEyebrow = widget.eyebrow ??
        (state.direction == Direction.sell
            ? createCopy(context, 'create.eyebrow.sell', 'SPECIFY THE PIECE · SELL')
            : createCopy(context, 'create.eyebrow.buy', 'SPECIFY THE PIECE · BUY'));

    return CreateFlowChrome(
      title: widget.title,
      eyebrow: effectiveEyebrow,
      stepLabel: widget.stepLabel,
      bottom: DraftActions(
        busy: state.busy || state.uploading,
        continueEnabled: !widget.combineImages || controller.canContinuePhotos,
        onSaveDraft: saveDraft,
        onContinue: () async {
          if (widget.combineImages &&
              state.imagesRequired &&
              !controller.canContinuePhotos) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  createCopy(
                    context,
                    'create.imagesRequired',
                    'Add at least one photo to continue.',
                  ),
                ),
              ),
            );
            return;
          }
          final next = widget.combineImages
              ? RequestCreateStep.review
              : RequestCreateStep.images;
          final ok = await controller.persistAndGo(next);
          if (ok && context.mounted) {
            // push (not go): preserves history so back returns to this step.
            context.push(
              widget.combineImages
                  ? RequestCreatePaths.review
                  : RequestCreatePaths.images,
            );
          }
        },
      ),
      child: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space.md,
          vertical: tokens.space.sm,
        ),
        children: [
          if (state.failure != null) ...[
            KhInlineError(
              message: state.failure!.message ??
                  createCopy(context, 'create.saveFailed', 'Could not save.'),
            ),
            SizedBox(height: tokens.space.xs),
          ],
          for (final w in state.warnings) ...[
            KhInlineError(message: w),
            SizedBox(height: tokens.space.xs),
          ],
          if (widget.combineImages) ...[
            RequestImagesSection(
              showHint: true,
              showActualItemNotice: widget.showActualItemNotice,
            ),
            SizedBox(height: tokens.space.md),
          ],
          widget.fields,
          SizedBox(height: tokens.space.md),
          CommonCreateFields(
            state: state,
            controller: controller,
            locale: locale,
          ),
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
    final tokens = context.tokens;
    final state = ref.watch(requestCreateControllerProvider);
    final controller = ref.read(requestCreateControllerProvider.notifier);

    return ComposeScreenHost(
      title: createCopy(context, 'create.type.ornament', 'Find An Ornament'),
      eyebrow: createCopy(context, 'create.eyebrow.buy', 'SPECIFY THE PIECE · BUY'),
      stepLabel: createCopy(context, 'create.stepCompose', 'Specify the piece'),
      combineImages: true,
      fields: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OrnamentTypeChips(
            value: state.ornamentType,
            errorText: state.fieldError('ornamentType'),
            onChanged: controller.setOrnamentType,
            optional: true,
          ),
          SizedBox(height: tokens.space.md),
          WeightPurityFields(
            state: state,
            controller: controller,
            purityAsChips: true,
            purityOptional: true,
          ),
          SizedBox(height: tokens.space.sm),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              createCopy(context, 'create.gemstones', 'Includes gemstones'),
            ),
            value: state.gemstonesPresent,
            onChanged: controller.setGemstonesPresent,
          ),
          if (state.gemstonesPresent) ...[
            SizedBox(height: tokens.space.xs),
            KhTextField(
              label: createCopy(context, 'create.gemstoneType', 'Gemstone type'),
              initialValue: state.gemstoneType,
              onChanged: controller.setGemstoneType,
            ),
            SizedBox(height: tokens.space.xs),
            KhNumericField(
              label: createCopy(context, 'create.gemstoneCount', 'Gemstone count'),
              decimalPlaces: 0,
              min: 1,
              initialValue: state.gemstoneCount?.toString(),
              onChanged: (v) => controller.setGemstoneCount(v?.toInt()),
            ),
          ],
          SizedBox(height: tokens.space.md),
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

    return ComposeScreenHost(
      title: createCopy(context, 'create.type.sellGold', 'Sell Old Gold'),
      eyebrow: createCopy(context, 'create.eyebrow.sell', 'SPECIFY THE PIECE · SELL'),
      stepLabel: createCopy(context, 'create.stepCompose', 'Specify the piece'),
      combineImages: true,
      showActualItemNotice: true,
      fields: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OrnamentTypeChips(
            value: state.ornamentType,
            onChanged: controller.setOrnamentType,
          ),
          SizedBox(height: tokens.space.md),
          WeightPurityFields(
            state: state,
            controller: controller,
            weightRequired: true,
            purityAsChips: true,
          ),
          SizedBox(height: tokens.space.md),
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
          SizedBox(height: tokens.space.sm),
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

    return ComposeScreenHost(
      title: createCopy(context, 'create.type.coins', 'Buy/Sell Gold Coins'),
      stepLabel: createCopy(context, 'create.stepCompose', 'Specify the piece'),
      fields: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DirectionControl(
            value: state.direction,
            onChanged: controller.setDirection,
          ),
          CoinDenominationChips(
            value: state.denominationGrams,
            errorText: state.fieldError('denominationGrams'),
            onChanged: controller.setDenomination,
          ),
          SizedBox(height: tokens.space.md),
          QuantityStepper(
            value: state.quantity ?? 1,
            onChanged: controller.setQuantity,
            totalWeightGrams: controller.totalWeightGrams(),
          ),
          SizedBox(height: tokens.space.md),
          WeightPurityFields(
            state: state,
            controller: controller,
            showWeight: false,
            purityAsChips: true,
          ),
          SizedBox(height: tokens.space.md),
          KhTextField(
            label: createCopy(
              context,
              'create.mint',
              'Mint / brand (optional)',
            ),
            initialValue: state.mintOrRefiner,
            onChanged: controller.setMint,
          ),
          SizedBox(height: tokens.space.sm),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              createCopy(context, 'create.packagingSealed', 'Sealed packaging'),
            ),
            value: state.packagingSealed ?? false,
            onChanged: controller.setPackagingSealed,
          ),
          if (state.direction == Direction.buy) ...[
            SizedBox(height: tokens.space.md),
            BudgetEditor(state: state, controller: controller),
          ],
        ],
      ),
    );
  }
}

/// CUS-S07 — Gold Bullion (CU-07).
class GoldBullionScreen extends ConsumerWidget {
  const GoldBullionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final state = ref.watch(requestCreateControllerProvider);
    final controller = ref.read(requestCreateControllerProvider.notifier);

    return ComposeScreenHost(
      title: createCopy(context, 'create.type.bullion', 'Buy/Sell Bullions'),
      stepLabel: createCopy(context, 'create.stepCompose', 'Specify the piece'),
      fields: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DirectionControl(
            value: state.direction,
            onChanged: controller.setDirection,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: KhNumericField(
                  label: createCopy(context, 'create.barWeight', 'Bar weight'),
                  unit: 'g',
                  min: 0.10,
                  max: 5000,
                  initialValue: state.weightGrams,
                  errorText: state.fieldError('weightGrams'),
                  onChanged: (v) =>
                      controller.setWeightGrams(v?.toStringAsFixed(2)),
                ),
              ),
              SizedBox(width: tokens.space.md),
              Expanded(
                child: QuantityStepper(
                  value: state.quantity ?? 1,
                  onChanged: controller.setQuantity,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.space.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                createCopy(context, 'create.purity', 'Purity'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SizedBox(height: tokens.space.xs),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.space.md,
                  vertical: tokens.space.sm,
                ),
                decoration: BoxDecoration(
                  color: tokens.goldWash,
                  borderRadius: BorderRadius.circular(tokens.radius.md),
                  border: Border.all(color: tokens.goldRing),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 16, color: tokens.goldDark),
                    SizedBox(width: tokens.space.xs),
                    Text(
                      '24K · 999.9',
                      style: context.typography.fieldInlineLabel.copyWith(
                        color: tokens.goldDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.space.md),
          KhTextField(
            label: createCopy(
              context,
              'create.refiner',
              'Refiner / brand (optional)',
            ),
            initialValue: state.mintOrRefiner,
            onChanged: controller.setMint,
          ),
          SizedBox(height: tokens.space.sm),
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
          if (state.direction == Direction.buy) ...[
            SizedBox(height: tokens.space.md),
            BudgetEditor(state: state, controller: controller),
          ],
        ],
      ),
    );
  }
}
