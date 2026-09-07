import 'package:flutter/material.dart';

import '../tokens.dart';
import 'kh_text_field.dart';

class KhSelectOption<T> {
  const KhSelectOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// SH-FND-04 — single select, optionally searchable.
class KhSelectField<T> extends StatelessWidget {
  const KhSelectField({
    super.key,
    required this.label,
    required this.options,
    required this.onChanged,
    this.value,
    this.emptyLabel,
    this.searchHint,
    this.searchable = true,
    this.errorText,
  });

  final String label;
  final List<KhSelectOption<T>> options;
  final ValueChanged<T> onChanged;
  final T? value;
  final String? emptyLabel;
  final String? searchHint;
  final bool searchable;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final selected = options.where((o) => o.value == value);
    final display = selected.isEmpty
        ? (emptyLabel ?? label)
        : selected.first.label;

    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        key: const Key('kh-select-field'),
        onTap: () => _openSheet(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            errorText: errorText,
            suffixIcon: const Icon(Icons.expand_more),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(vertical: tokens.space.xs),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(display),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openSheet(BuildContext context) async {
    final chosen = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _KhSelectSheet<T>(
          label: label,
          options: options,
          searchHint: searchHint,
          searchable: searchable,
        );
      },
    );
    if (chosen != null) onChanged(chosen);
  }
}

class _KhSelectSheet<T> extends StatefulWidget {
  const _KhSelectSheet({
    required this.label,
    required this.options,
    required this.searchHint,
    required this.searchable,
  });

  final String label;
  final List<KhSelectOption<T>> options;
  final String? searchHint;
  final bool searchable;

  @override
  State<_KhSelectSheet<T>> createState() => _KhSelectSheetState<T>();
}

class _KhSelectSheetState<T> extends State<_KhSelectSheet<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? widget.options
        : widget.options
            .where((o) => o.label.toLowerCase().contains(q))
            .toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsetsDirectional.all(tokens.space.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.label, style: Theme.of(context).textTheme.titleMedium),
            if (widget.searchable) ...[
              SizedBox(height: tokens.space.sm),
              KhTextField(
                key: const Key('kh-select-search'),
                label: widget.searchHint ?? widget.label,
                onChanged: (value) => setState(() => _query = value),
              ),
            ],
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: tokens.space.xl * 10),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final option in filtered)
                    ListTile(
                      title: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(option.label),
                      ),
                      onTap: () => Navigator.of(context).pop(option.value),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
