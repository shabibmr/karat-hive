import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';

/// SH-RPT-01 category descriptor.
class AbuseCategoryOption {
  const AbuseCategoryOption({required this.key, required this.label});
  final String key;
  final String label;
}

/// Vendor reporting categories per `VEN-S21` / `FR-VEN-030`.
const List<AbuseCategoryOption> kVendorAbuseCategories = [
  AbuseCategoryOption(
    key: 'FRAUDULENT_REQUEST',
    label: 'Non-genuine / Fake Request Specifications',
  ),
  AbuseCategoryOption(
    key: 'OFF_PLATFORM_FRAUD',
    label: 'Attempted External Off-platform Fraud',
  ),
  AbuseCategoryOption(
    key: 'ABUSIVE_BEHAVIOUR',
    label: 'Abusive or Spam Communication',
  ),
  AbuseCategoryOption(
    key: 'UNREALISTIC_EXPECTATIONS',
    label: 'Unrealistic Expectations / Time-Wasting',
  ),
  AbuseCategoryOption(
    key: 'SUSPECTED_NON_GENUINE',
    label: 'Suspected Non-genuine Item',
  ),
  AbuseCategoryOption(
    key: 'OTHER',
    label: 'Other Policy Violation',
  ),
];

/// Customer reporting categories per `CUS-S22` / `FR-CUS-033`.
const List<AbuseCategoryOption> kCustomerAbuseCategories = [
  AbuseCategoryOption(
    key: 'FRAUDULENT_OFFER',
    label: 'Fraudulent Offer',
  ),
  AbuseCategoryOption(
    key: 'ABUSIVE_BEHAVIOUR',
    label: 'Abusive Behaviour',
  ),
  AbuseCategoryOption(
    key: 'OFF_PLATFORM_SOLICITATION',
    label: 'Off-platform Solicitation',
  ),
  AbuseCategoryOption(
    key: 'MISLEADING_TERMS',
    label: 'Misleading Terms',
  ),
  AbuseCategoryOption(
    key: 'OTHER',
    label: 'Other Policy Violation',
  ),
];

/// SH-RPT-01 — Abuse report form widget (`FR-VEN-030`, `FR-CUS-033`).
///
/// Category set adapts to [reporterRole]. Reporter identity is never
/// disclosed to the reported party (`BR-016`).
class AbuseReportForm extends StatefulWidget {
  const AbuseReportForm({
    super.key,
    required this.entityType,
    required this.entityId,
    this.entityReference,
    this.reporterRole = UserRole.vendor,
    this.onSubmit,
    this.onCancel,
    this.onDone,
    this.categories,
  });

  final AbuseEntityType entityType;
  final String entityId;
  final String? entityReference;
  final UserRole reporterRole;
  final Future<bool> Function({
    required String category,
    required String description,
  })? onSubmit;
  final VoidCallback? onCancel;
  final VoidCallback? onDone;
  final List<AbuseCategoryOption>? categories;

  @override
  State<AbuseReportForm> createState() => _AbuseReportFormState();
}

class _AbuseReportFormState extends State<AbuseReportForm> {
  String? _selectedCategory;
  late final TextEditingController _explanationController;
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _explanationController = TextEditingController();
    final list = _availableCategories;
    if (list.isNotEmpty) {
      _selectedCategory = list.first.key;
    }
  }

  @override
  void dispose() {
    _explanationController.dispose();
    super.dispose();
  }

  List<AbuseCategoryOption> get _availableCategories =>
      widget.categories ??
      (widget.reporterRole == UserRole.customer
          ? kCustomerAbuseCategories
          : kVendorAbuseCategories);

  Future<void> _handleSubmit() async {
    final cat = _selectedCategory;
    final text = _explanationController.text.trim();
    if (cat == null || cat.isEmpty) {
      setState(() => _errorMessage = 'Please select a reason.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      if (widget.onSubmit != null) {
        final ok = await widget.onSubmit!(category: cat, description: text);
        if (!mounted) return;
        if (ok) {
          setState(() {
            _isSubmitting = false;
            _isSubmitted = true;
          });
        } else {
          setState(() {
            _isSubmitting = false;
            _errorMessage = 'Failed to submit report. Please try again.';
          });
        }
      } else {
        setState(() {
          _isSubmitting = false;
          _isSubmitted = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    if (_isSubmitted) {
      return Card(
        key: const Key('abuse-report-submitted'),
        child: Padding(
          padding: EdgeInsets.all(tokens.space.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 48, color: tokens.gold),
              SizedBox(height: tokens.space.md),
              Text(
                'Report Submitted',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: tokens.space.sm),
              Text(
                'Thank you for keeping the marketplace safe. Our Trust & Safety team will review this report.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: tokens.ink.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: tokens.space.sm),
              Text(
                'Your identity is never disclosed to the reported party.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: tokens.ink.withValues(alpha: 0.5),
                ),
              ),
              SizedBox(height: tokens.space.lg),
              KhButton(
                key: const Key('abuse-report-done-button'),
                label: 'Done',
                onPressed: widget.onDone ?? widget.onCancel ?? () {},
              ),
            ],
          ),
        ),
      );
    }

    final entityLabel = widget.entityReference ?? widget.entityId;

    return SingleChildScrollView(
      key: const Key('abuse-report-form'),
      child: Padding(
        padding: EdgeInsets.all(tokens.space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Context header
            Row(
              children: [
                Icon(Icons.shield_outlined, size: 20, color: tokens.gold),
                SizedBox(width: tokens.space.xs),
                Text(
                  'Trust & Safety',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: tokens.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.space.xs),
            Text(
              'Report ${widget.entityType.wire.toLowerCase()}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: tokens.space.xs),
            Text(
              'Context: $entityLabel',
              style: theme.textTheme.bodySmall?.copyWith(
                color: tokens.ink.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: tokens.space.md),

            // Form card
            Card(
              child: Padding(
                padding: EdgeInsets.all(tokens.space.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    KhSelectField<String>(
                      label: 'Report Reason',
                      value: _selectedCategory,
                      options: _availableCategories
                          .map(
                            (c) => KhSelectOption(
                              value: c.key,
                              label: c.label,
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (val) {
                        setState(() => _selectedCategory = val);
                      },
                    ),
                    SizedBox(height: tokens.space.md),
                    KhTextField(
                      key: const Key('abuse-report-explanation-input'),
                      controller: _explanationController,
                      label: 'Explanation & Context',
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: tokens.space.sm),

            // Anonymity assurance
            Container(
              padding: EdgeInsets.all(tokens.space.sm),
              decoration: BoxDecoration(
                color: tokens.gold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(tokens.radius.sm),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 16, color: tokens.ink),
                  SizedBox(width: tokens.space.xs),
                  Expanded(
                    child: Text(
                      'Confidential: Reporter identity is withheld from the reported party (BR-016).',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: tokens.ink.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_errorMessage != null) ...[
              SizedBox(height: tokens.space.sm),
              KhInlineError(message: _errorMessage!),
            ],

            SizedBox(height: tokens.space.lg),

            KhButton(
              key: const Key('abuse-report-submit-button'),
              label: 'Submit Report →',
              busy: _isSubmitting,
              onPressed: _isSubmitting ? null : _handleSubmit,
            ),
            if (widget.onCancel != null) ...[
              SizedBox(height: tokens.space.sm),
              KhButton(
                key: const Key('abuse-report-cancel-button'),
                label: 'Cancel',
                secondary: true,
                onPressed: widget.onCancel,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
