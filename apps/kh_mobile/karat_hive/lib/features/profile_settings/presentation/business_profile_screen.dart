import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../controller/business_profile_controller.dart';

/// Weekday keys for `businessHours` JSON (API inventory § VendorProfile).
const _kWeekdays = <(String, String)>[
  ('mon', 'Monday'),
  ('tue', 'Tuesday'),
  ('wed', 'Wednesday'),
  ('thu', 'Thursday'),
  ('fri', 'Friday'),
  ('sat', 'Saturday'),
  ('sun', 'Sunday'),
];

/// VEN-S15 — Business profile (CP6-B02.1 header + CP6-B02.2 safe edits + CP6-B02.4 BR-004 legal identity).
///
/// Safe fields: trading name, description, business hours, contact person,
/// business email. Logo/shop photos → B02.3. Legal identity fields trigger
/// re-verification confirmation dialog (BR-004).
class BusinessProfileScreen extends ConsumerStatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  ConsumerState<BusinessProfileScreen> createState() =>
      _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends ConsumerState<BusinessProfileScreen> {
  final _tradingName = TextEditingController();
  final _description = TextEditingController();
  final _contactPerson = TextEditingController();
  final _businessEmail = TextEditingController();
  final _legalBusinessName = TextEditingController();
  final _tradeLicenceNumber = TextEditingController();
  final _registeredAddress = TextEditingController();
  final _openCtrls = <String, TextEditingController>{};
  final _closeCtrls = <String, TextEditingController>{};
  final _closed = <String, bool>{};

  String _initialLegalBusinessName = '';
  String _initialTradeLicenceNumber = '';
  String _initialRegisteredAddress = '';

  String? _boundProfileId;
  var _seeded = false;

  @override
  void initState() {
    super.initState();
    for (final (key, _) in _kWeekdays) {
      _openCtrls[key] = TextEditingController(text: '09:30');
      _closeCtrls[key] = TextEditingController(text: '22:00');
      _closed[key] = key == 'sun';
    }
  }

  @override
  void dispose() {
    _tradingName.dispose();
    _description.dispose();
    _contactPerson.dispose();
    _businessEmail.dispose();
    _legalBusinessName.dispose();
    _tradeLicenceNumber.dispose();
    _registeredAddress.dispose();
    for (final c in _openCtrls.values) {
      c.dispose();
    }
    for (final c in _closeCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _seedFrom(VendorMe vendor) {
    if (_seeded && _boundProfileId == vendor.vendorProfileId) return;
    _boundProfileId = vendor.vendorProfileId;
    _seeded = true;
    _tradingName.text = vendor.tradingName;
    _description.text = vendor.description ?? '';
    _contactPerson.text = vendor.contactPersonName;
    _businessEmail.text = vendor.businessEmail;
    _legalBusinessName.text = vendor.legalBusinessName;
    _tradeLicenceNumber.text = vendor.tradeLicenceNumber;
    _registeredAddress.text = vendor.registeredAddress;
    _initialLegalBusinessName = vendor.legalBusinessName;
    _initialTradeLicenceNumber = vendor.tradeLicenceNumber;
    _initialRegisteredAddress = vendor.registeredAddress;
    for (final (key, _) in _kWeekdays) {
      final day = vendor.businessHours[key];
      if (day == null) continue;
      _openCtrls[key]!.text = day.open.isEmpty ? '09:30' : day.open;
      _closeCtrls[key]!.text = day.close.isEmpty ? '22:00' : day.close;
      _closed[key] = day.closed;
    }
  }

  Map<String, BusinessDayHours> _hoursPayload() => {
        for (final (key, _) in _kWeekdays)
          key: BusinessDayHours(
            open: _openCtrls[key]!.text.trim(),
            close: _closeCtrls[key]!.text.trim(),
            closed: _closed[key] ?? false,
          ),
      };

  Future<void> _save() async {
    final legalChanged = _legalBusinessName.text.trim() != _initialLegalBusinessName ||
        _tradeLicenceNumber.text.trim() != _initialTradeLicenceNumber ||
        _registeredAddress.text.trim() != _initialRegisteredAddress;

    if (legalChanged) {
      final confirmed = await showKhConfirmDialog(
        context,
        title: 'Re-verification Required',
        body:
            'Changing legal identity fields requires administrator re-verification. Your account will enter pending verification until reviewed.',
        destructive: true,
        confirmLabel: 'Submit for Re-verification',
        cancelLabel: 'Cancel',
      );
      if (!mounted || confirmed != true) return;
    }

    final ok = await ref.read(businessProfileSaveProvider.notifier).saveSafeEdits(
          tradingName: _tradingName.text,
          description: _description.text,
          contactPersonName: _contactPerson.text,
          businessEmail: _businessEmail.text,
          businessHours: _hoursPayload(),
        );
    if (!mounted) return;
    if (ok) {
      _seeded = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(vendorProfileProvider);
    final save = ref.watch(businessProfileSaveProvider);
    final tokens = context.tokens;

    ref.listen<AsyncValue<VendorMe>>(vendorProfileProvider, (prev, next) {
      final vendor = next.valueOrNull;
      if (vendor == null) return;
      if (_seeded && _boundProfileId == vendor.vendorProfileId) return;
      setState(() => _seedFrom(vendor));
    });

    final initial = async.valueOrNull;
    if (initial != null && !_seeded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _seeded) return;
        setState(() => _seedFrom(initial));
      });
    }

    return KhScaffold(
      title: 'Business profile',
      onRefresh: () async {
        _seeded = false;
        ref.invalidate(vendorProfileProvider);
      },
      body: async.when(
        loading: () => const KhLoadingView(),
        error: (_, __) => KhErrorView(
          message: 'Could not load your profile.',
          onRetry: () => ref.invalidate(vendorProfileProvider),
        ),
        data: (vendor) {
          return SingleChildScrollView(
            key: const Key('business-profile-header'),
            padding: EdgeInsets.all(tokens.space.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              VendorStatusCard(
                lifecycle: vendor.lifecycle,
                tradingName: vendor.tradingName,
                lifecycleLabel: _lifecycleLabel(l10n, vendor.lifecycle),
                verificationMessage: vendor.verificationMessage,
              ),
              if (vendor.verifiedAt != null) ...[
                SizedBox(height: tokens.space.sm),
                _VerifiedAtRow(verifiedAt: vendor.verifiedAt!),
              ],
              SizedBox(height: tokens.space.md),
              _TotalsRow(
                offersSubmitted: vendor.offersSubmittedCount,
                connections: vendor.connectionCount,
              ),
              SizedBox(height: tokens.space.md),
              KhSectionHeader(
                title: l10n?.dashboardRating ?? 'Rating',
              ),
              SizedBox(height: tokens.space.sm),
              RatingSummaryView(
                summary: vendor.rating ??
                    const RatingSummary(
                      average: 0,
                      count: 0,
                      limitedHistory: true,
                    ),
                showDistribution: (vendor.rating?.count ?? 0) > 0,
              ),
              SizedBox(height: tokens.space.md),
              const KhSectionHeader(title: 'Public preview'),
              SizedBox(height: tokens.space.xs),
              Text(
                'What Customers see before Acceptance.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tokens.ink.withValues(alpha: 0.65),
                    ),
              ),
              SizedBox(height: tokens.space.sm),
              _MaskedPublicPreviewCard(vendor: vendor),
              SizedBox(height: tokens.space.lg),
              const KhSectionHeader(title: 'Showroom & branding'),
              SizedBox(height: tokens.space.sm),
              KhTextField(
                key: const Key('business-profile-trading-name'),
                label: 'Trading name',
                controller: _tradingName,
              ),
              KhTextField(
                key: const Key('business-profile-description'),
                label: 'Business description',
                controller: _description,
                maxLines: 3,
              ),
              SizedBox(height: tokens.space.md),
              const _BrandingMediaSection(),
              SizedBox(height: tokens.space.md),
              const KhSectionHeader(title: 'Business hours'),
              SizedBox(height: tokens.space.xs),
              Text(
                'Times use 24-hour HH:MM (Gulf Standard Time).',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tokens.ink.withValues(alpha: 0.65),
                    ),
              ),
              SizedBox(height: tokens.space.sm),
              _BusinessHoursEditor(
                closed: _closed,
                openCtrls: _openCtrls,
                closeCtrls: _closeCtrls,
                onClosedChanged: (key, value) =>
                    setState(() => _closed[key] = value),
              ),
              SizedBox(height: tokens.space.md),
              const KhSectionHeader(title: 'Contact'),
              SizedBox(height: tokens.space.sm),
              KhTextField(
                key: const Key('business-profile-contact-person'),
                label: 'Contact person',
                controller: _contactPerson,
              ),
              KhTextField(
                key: const Key('business-profile-business-email'),
                label: 'Business email',
                controller: _businessEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: tokens.space.md),
              const KhSectionHeader(title: 'Legal identity (BR-004)'),
              SizedBox(height: tokens.space.xs),
              Text(
                'Changes to legal identity require administrator re-verification.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tokens.ink.withValues(alpha: 0.65),
                    ),
              ),
              SizedBox(height: tokens.space.sm),
              KhTextField(
                key: const Key('business-profile-legal-name'),
                label: 'Legal business name',
                controller: _legalBusinessName,
              ),
              KhTextField(
                key: const Key('business-profile-trade-licence'),
                label: 'Trade licence number',
                controller: _tradeLicenceNumber,
              ),
              KhTextField(
                key: const Key('business-profile-registered-address'),
                label: 'Registered address',
                controller: _registeredAddress,
                maxLines: 2,
              ),
              SizedBox(height: tokens.space.md),
              if (save.failure != null) ...[
                KhInlineError(
                  message: save.failure!.message ?? 'Could not save profile.',
                ),
                SizedBox(height: tokens.space.md),
              ],
              KhButton(
                key: const Key('business-profile-save'),
                label: 'Save',
                busy: save.busy,
                onPressed: save.busy ? null : _save,
              ),
              SizedBox(height: tokens.space.lg),
            ],
            ),
          );
        },
      ),
    );
  }

  String _lifecycleLabel(AppLocalizations? l10n, VendorLifecycle lifecycle) =>
      switch (lifecycle) {
        VendorLifecycle.registered => l10n?.lifecycleRegistered ?? 'Registered',
        VendorLifecycle.pendingVerification =>
          l10n?.lifecyclePendingVerification ?? 'Under review',
        VendorLifecycle.verified => l10n?.lifecycleVerified ?? 'Verified',
        VendorLifecycle.active => l10n?.lifecycleActive ?? 'Active',
        VendorLifecycle.suspended => l10n?.lifecycleSuspended ?? 'Suspended',
        VendorLifecycle.rejected => l10n?.lifecycleRejected ?? 'Needs changes',
        VendorLifecycle.deactivated =>
          l10n?.lifecycleDeactivated ?? 'Deactivated',
        VendorLifecycle.unknown => l10n?.lifecycleUnknown ?? 'Unknown',
      };
}

class _BusinessHoursEditor extends StatelessWidget {
  const _BusinessHoursEditor({
    required this.closed,
    required this.openCtrls,
    required this.closeCtrls,
    required this.onClosedChanged,
  });

  final Map<String, bool> closed;
  final Map<String, TextEditingController> openCtrls;
  final Map<String, TextEditingController> closeCtrls;
  final void Function(String key, bool value) onClosedChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      key: const Key('business-profile-hours'),
      children: [
        for (final (key, label) in _kWeekdays) ...[
          Card(
            elevation: 0,
            color: tokens.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tokens.radius.md),
              side: BorderSide(color: tokens.ink.withValues(alpha: 0.12)),
            ),
            child: Padding(
              padding: EdgeInsets.all(tokens.space.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(label),
                    subtitle: Text(closed[key] == true ? 'Closed' : 'Open'),
                    value: closed[key] != true,
                    onChanged: (open) => onClosedChanged(key, !open),
                  ),
                  if (closed[key] != true)
                    Row(
                      children: [
                        Expanded(
                          child: KhTextField(
                            label: 'Open',
                            controller: openCtrls[key],
                          ),
                        ),
                        SizedBox(width: tokens.space.sm),
                        Expanded(
                          child: KhTextField(
                            label: 'Close',
                            controller: closeCtrls[key],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: tokens.space.sm),
        ],
      ],
    );
  }
}

class _VerifiedAtRow extends StatelessWidget {
  const _VerifiedAtRow({required this.verifiedAt});

  final DateTime verifiedAt;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final locale = Localizations.localeOf(context);
    final date = GstFormatter.display(verifiedAt, locale: locale.languageCode);

    return Text(
      key: const Key('business-profile-verified-at'),
      'Verified on $date',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: tokens.ink.withValues(alpha: 0.7),
          ),
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({
    required this.offersSubmitted,
    required this.connections,
  });

  final int offersSubmitted;
  final int connections;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      key: const Key('business-profile-totals'),
      children: [
        Expanded(
          child: _StatTile(
            label: 'Offers submitted',
            value: offersSubmitted,
          ),
        ),
        SizedBox(width: tokens.space.sm),
        Expanded(
          child: _StatTile(
            label: 'Connections',
            value: connections,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: tokens.ink.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: tokens.gold,
              ),
            ),
            SizedBox(height: tokens.space.xs),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: tokens.ink.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// VE-18 — masked public preview. Uses server `maskedPreview` when present;
/// otherwise a non-identity fallback (no trading name).
class _MaskedPublicPreviewCard extends StatelessWidget {
  const _MaskedPublicPreviewCard({required this.vendor});

  final VendorMe vendor;

  MaskedParty get _party {
    final preview = vendor.maskedPreview;
    if (preview != null) return preview;

    final verified = vendor.lifecycle == VendorLifecycle.active ||
        vendor.lifecycle == VendorLifecycle.verified;
    return MaskedParty(
      role: UserRole.vendor,
      pseudonym: verified ? 'Verified Jeweller' : 'Jeweller',
      rating: vendor.rating,
      dealCount: vendor.connectionCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Card(
      key: const Key('masked-public-preview'),
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: tokens.ink.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.space.md),
        child: MaskedPartyLabel(party: _party),
      ),
    );
  }
}

/// VEN-S15 logo and shop photos placeholder citing the inventory gap (CP6-B02.3).
class _BrandingMediaSection extends StatelessWidget {
  const _BrandingMediaSection();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Card(
      key: const Key('business-profile-media-section'),
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: tokens.ink.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.storefront_outlined, size: 20, color: tokens.gold),
                SizedBox(width: tokens.space.xs),
                Text(
                  'Logo & Storefront Photos',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.space.xs),
            Text(
              'Showroom photos appear on your public merchant card once verified.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: tokens.ink.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: tokens.space.sm),
            Container(
              padding: EdgeInsets.all(tokens.space.sm),
              decoration: BoxDecoration(
                color: tokens.gold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(tokens.radius.sm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: tokens.ink),
                  SizedBox(width: tokens.space.xs),
                  Expanded(
                    child: Text(
                      'Inventory gap: Media upload endpoints for merchant logo and storefront photography are pending backend inventory specification (SAM-GAP / AD-API-09). To update physical showroom assets, submit high-resolution files to Support.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: tokens.ink.withValues(alpha: 0.8),
                      ),
                    ),
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

