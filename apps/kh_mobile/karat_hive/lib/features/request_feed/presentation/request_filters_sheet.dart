import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../../onboarding/repository/onboarding_repository.dart';
import '../controller/request_feed_controller.dart';
import '../repository/request_feed_repository.dart';

/// VEN-S07 — Request Filters & Presets Bottom Sheet (SH-FND-16).
class RequestFiltersSheet extends ConsumerStatefulWidget {
  const RequestFiltersSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const RequestFiltersSheet(),
    );
  }

  @override
  ConsumerState<RequestFiltersSheet> createState() => _RequestFiltersSheetState();
}

class _RequestFiltersSheetState extends ConsumerState<RequestFiltersSheet> {
  late RequestFiltersState _draft;
  late final TextEditingController _minBudgetController;
  late final TextEditingController _maxBudgetController;

  static const _requestTypeCodes = <String>[
    'FIND_ORNAMENT',
    'CUSTOM_DESIGN',
    'BULLION',
    'REPAIR_RESIZE',
  ];

  String _requestTypeLabel(AppLocalizations? l10n, String code) {
    return switch (code) {
      'FIND_ORNAMENT' => l10n?.requestTypeFindOrnament ?? 'Find Ornament',
      'CUSTOM_DESIGN' => l10n?.requestTypeCustomDesign ?? 'Custom Design',
      'BULLION' => l10n?.requestTypeBullion ?? 'Bullion',
      'REPAIR_RESIZE' => l10n?.requestTypeRepairResize ?? 'Repair & Resize',
      _ => code.replaceAll('_', ' '),
    };
  }

  @override
  void initState() {
    super.initState();
    _draft = ref.read(requestFiltersProvider);
    _minBudgetController = TextEditingController(
      text: _draft.minBudget?.toStringAsFixed(0) ?? '',
    );
    _maxBudgetController = TextEditingController(
      text: _draft.maxBudget?.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    super.dispose();
  }

  Iterable<TaxonomyNode> _leaves(List<TaxonomyNode> nodes) sync* {
    for (final node in nodes) {
      if (node.children.isEmpty) {
        yield node;
      } else {
        yield* _leaves(node.children);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final presetsAsync = ref.watch(filterPresetsListProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final regionsAsync = ref.watch(regionsProvider);

    // Material (not DecoratedBox) so SwitchListTile ink/background resolve correctly.
    return Material(
      color: tokens.surface,
      borderRadius: BorderRadius.vertical(top: Radius.circular(tokens.radius.lg)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.only(
          top: tokens.space.md,
          left: tokens.space.md,
          right: tokens.space.md,
          bottom: MediaQuery.of(context).viewInsets.bottom + tokens.space.md,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: tokens.ink.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: tokens.space.sm),

          // Title & Reset
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n?.filterRequests ?? 'Filter Requests',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (_draft.hasActiveFilters)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _draft = const RequestFiltersState();
                      _minBudgetController.clear();
                      _maxBudgetController.clear();
                    });
                  },
                  child: Text(l10n?.resetAll ?? 'Reset All'),
                ),
            ],
          ),
          const Divider(height: 1),
          SizedBox(height: tokens.space.sm),

          // Scrollable filter fields
          Expanded(
            child: ListView(
              children: [
                // --- Sort by ---
                Text(l10n?.sortBy ?? 'Sort By', style: theme.textTheme.titleSmall),
                SizedBox(height: tokens.space.xs),
                Wrap(
                  spacing: 8,
                  children: [
                    _choiceChip(
                      'NEWEST',
                      l10n?.sortNewest ?? 'Newest',
                      _draft.sort == 'NEWEST',
                      (sel) {
                        if (sel) {
                          setState(() => _draft = _draft.copyWith(sort: 'NEWEST'));
                        }
                      },
                    ),
                    _choiceChip(
                      'EXPIRING',
                      l10n?.sortExpiringSoon ?? 'Expiring Soon',
                      _draft.sort == 'EXPIRING',
                      (sel) {
                        if (sel) {
                          setState(
                            () => _draft = _draft.copyWith(sort: 'EXPIRING'),
                          );
                        }
                      },
                    ),
                    _choiceChip(
                      'HIGHEST_VALUE',
                      l10n?.sortHighestValue ?? 'Highest Value',
                      _draft.sort == 'HIGHEST_VALUE',
                      (sel) {
                        if (sel) {
                          setState(
                            () =>
                                _draft = _draft.copyWith(sort: 'HIGHEST_VALUE'),
                          );
                        }
                      },
                    ),
                    _choiceChip(
                      'FEWEST_OFFERS',
                      l10n?.sortFewestOffers ?? 'Fewest Offers',
                      _draft.sort == 'FEWEST_OFFERS',
                      (sel) {
                        if (sel) {
                          setState(
                            () =>
                                _draft = _draft.copyWith(sort: 'FEWEST_OFFERS'),
                          );
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: tokens.space.md),

                // --- Request type ---
                Text(l10n?.requestType ?? 'Request Type', style: theme.textTheme.titleSmall),
                SizedBox(height: tokens.space.xs),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _requestTypeCodes.map((value) {
                    final label = _requestTypeLabel(l10n, value);
                    final selected = _draft.requestType == value;
                    return _choiceChip(value, label, selected, (sel) {
                      setState(() {
                        _draft = _draft.copyWith(
                          requestType: sel ? value : null,
                          clearRequestType: !sel,
                          clearActivePreset: true,
                        );
                      });
                    });
                  }).toList(growable: false),
                ),
                SizedBox(height: tokens.space.md),

                // --- Category ---
                Text(l10n?.category ?? 'Category', style: theme.textTheme.titleSmall),
                SizedBox(height: tokens.space.xs),
                categoriesAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => Text(
                    l10n?.couldNotLoadCategories ?? 'Could not load categories',
                  ),
                  data: (nodes) {
                    final leaves = _leaves(nodes).toList(growable: false);
                    final anyCategory = l10n?.anyCategory ?? 'Any category';
                    return DropdownButtonFormField<String?>(
                      key: ValueKey('filter-category-${_draft.categoryId}'),
                      initialValue: _draft.categoryId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: anyCategory,
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(anyCategory),
                        ),
                        ...leaves.map(
                          (n) => DropdownMenuItem<String?>(
                            value: n.id,
                            child: Text(n.nameEn),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _draft = value == null
                              ? _draft.copyWith(
                                  clearCategoryId: true,
                                  clearActivePreset: true,
                                )
                              : _draft.copyWith(
                                  categoryId: value,
                                  clearActivePreset: true,
                                );
                        });
                      },
                    );
                  },
                ),
                SizedBox(height: tokens.space.md),

                // --- Region ---
                Text(l10n?.region ?? 'Region', style: theme.textTheme.titleSmall),
                SizedBox(height: tokens.space.xs),
                regionsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => Text(
                    l10n?.couldNotLoadRegions ?? 'Could not load regions',
                  ),
                  data: (nodes) {
                    final leaves = _leaves(nodes).toList(growable: false);
                    final anyRegion = l10n?.anyRegion ?? 'Any region';
                    return DropdownButtonFormField<String?>(
                      key: ValueKey('filter-region-${_draft.regionId}'),
                      initialValue: _draft.regionId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: anyRegion,
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(anyRegion),
                        ),
                        ...leaves.map(
                          (n) => DropdownMenuItem<String?>(
                            value: n.id,
                            child: Text(n.nameEn),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _draft = value == null
                              ? _draft.copyWith(
                                  clearRegionId: true,
                                  clearActivePreset: true,
                                )
                              : _draft.copyWith(
                                  regionId: value,
                                  clearActivePreset: true,
                                );
                        });
                      },
                    );
                  },
                ),
                SizedBox(height: tokens.space.md),

                // --- Budget ---
                Text(l10n?.budgetAed ?? 'Budget (AED)', style: theme.textTheme.titleSmall),
                SizedBox(height: tokens.space.xs),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('filter-min-budget'),
                        controller: _minBudgetController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: l10n?.minLabel ?? 'Min',
                        ),
                        onChanged: (raw) {
                          final parsed = double.tryParse(raw);
                          setState(() {
                            _draft = parsed == null
                                ? _draft.copyWith(
                                    clearMinBudget: true,
                                    clearActivePreset: true,
                                  )
                                : _draft.copyWith(
                                    minBudget: parsed,
                                    clearActivePreset: true,
                                  );
                          });
                        },
                      ),
                    ),
                    SizedBox(width: tokens.space.sm),
                    Expanded(
                      child: TextField(
                        key: const Key('filter-max-budget'),
                        controller: _maxBudgetController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: l10n?.maxLabel ?? 'Max',
                        ),
                        onChanged: (raw) {
                          final parsed = double.tryParse(raw);
                          setState(() {
                            _draft = parsed == null
                                ? _draft.copyWith(
                                    clearMaxBudget: true,
                                    clearActivePreset: true,
                                  )
                                : _draft.copyWith(
                                    maxBudget: parsed,
                                    clearActivePreset: true,
                                  );
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: tokens.space.md),

                // --- Purity Karat ---
                Text(l10n?.purityKarat ?? 'Purity (Karat)', style: theme.textTheme.titleSmall),
                SizedBox(height: tokens.space.xs),
                Wrap(
                  spacing: 8,
                  children: ['18', '21', '22', '24'].map((k) {
                    final selected = _draft.purityKarat == k;
                    return _choiceChip(k, '${k}K', selected, (sel) {
                      setState(() {
                        _draft = _draft.copyWith(
                          purityKarat: sel ? k : null,
                          clearPurityKarat: !sel,
                          clearActivePreset: true,
                        );
                      });
                    });
                  }).toList(growable: false),
                ),
                SizedBox(height: tokens.space.md),

                // --- Responded Toggle ---
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n?.includeAlreadyResponded ??
                        'Include already responded requests',
                  ),
                  value: _draft.includeResponded,
                  onChanged: (v) => setState(
                    () => _draft = _draft.copyWith(
                      includeResponded: v,
                      clearActivePreset: true,
                    ),
                  ),
                ),
                SizedBox(height: tokens.space.sm),

                // --- Saved Presets Section ---
                Text(l10n?.filterPresets ?? 'Filter Presets', style: theme.textTheme.titleSmall),
                SizedBox(height: tokens.space.xs),
                presetsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Text(
                    l10n?.couldNotLoadPresets ?? 'Could not load presets',
                  ),
                  data: (presets) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (presets.isEmpty)
                          Text(
                            l10n?.noSavedPresetsYet ?? 'No saved presets yet.',
                            style: TextStyle(
                              fontSize: 13,
                              color: tokens.ink.withValues(alpha: 0.5),
                            ),
                          ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: presets.map((p) {
                            final isCurrent = _draft.activePresetId == p.id;
                            return InputChip(
                              label: Text(p.name),
                              selected: isCurrent,
                              onSelected: (_) => _applyPreset(p),
                              onDeleted: () => _deletePreset(p.id),
                            );
                          }).toList(growable: false),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _showSavePresetDialog,
                          icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                          label: Text(
                            l10n?.saveCurrentFiltersAsPreset ??
                                'Save current filters as preset',
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: tokens.space.md),

          // Apply button
          KhButton(
            label: l10n?.applyFilters ?? 'Apply Filters',
            onPressed: () {
              ref.read(requestFiltersProvider.notifier).update(_draft);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      ),
      ),
    );
  }

  Widget _choiceChip(String key, String label, bool selected, ValueChanged<bool> onSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
    );
  }

  void _applyPreset(FilterPresetItem preset) {
    final f = preset.filters;
    final minBudget =
        f['minBudget'] != null ? double.tryParse(f['minBudget'].toString()) : null;
    final maxBudget =
        f['maxBudget'] != null ? double.tryParse(f['maxBudget'].toString()) : null;
    setState(() {
      _draft = RequestFiltersState(
        activePresetId: preset.id,
        activePresetName: preset.name,
        sort: f['sort']?.toString() ?? 'NEWEST',
        requestType: f['requestType']?.toString(),
        categoryId: f['categoryId']?.toString(),
        regionId: f['regionId']?.toString(),
        purityKarat: f['purityKarat']?.toString(),
        minBudget: minBudget,
        maxBudget: maxBudget,
        includeResponded: f['includeResponded'] == true,
      );
      _minBudgetController.text = minBudget?.toStringAsFixed(0) ?? '';
      _maxBudgetController.text = maxBudget?.toStringAsFixed(0) ?? '';
    });
  }

  Future<void> _deletePreset(String id) async {
    await ref.read(requestFeedRepositoryProvider).deleteFilterPreset(id);
    ref.invalidate(filterPresetsListProvider);
    if (_draft.activePresetId == id) {
      setState(() {
        _draft = _draft.copyWith(clearActivePreset: true);
      });
    }
  }

  Future<void> _showSavePresetDialog() async {
    final textController = TextEditingController();
    final l10n = AppLocalizations.of(context);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.saveFilterPreset ?? 'Save Filter Preset'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n?.presetNameHint ??
                'Preset name (e.g. Dubai 22K Rings)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(textController.text.trim()),
            child: Text(l10n?.save ?? 'Save'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      await ref.read(requestFeedRepositoryProvider).createFilterPreset(
            name: name,
            filters: _draft.toFilterMap(),
          );
      ref.invalidate(filterPresetsListProvider);
    }
  }
}
