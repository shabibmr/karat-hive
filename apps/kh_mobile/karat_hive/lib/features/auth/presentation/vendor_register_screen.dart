import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import '../../../app/guards.dart';
import '../../onboarding/repository/onboarding_repository.dart';
import '../controller/vendor_register_controller.dart';

class VendorRegisterScreen extends ConsumerWidget {
  const VendorRegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final form = ref.watch(vendorRegisterControllerProvider);
    final controller = ref.read(vendorRegisterControllerProvider.notifier);
    final regions = ref.watch(regionsProvider);

    return KhScaffold(
      title: 'Create your account',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (form.failure != null) ...[
            KhInlineError(
              message: form.failure!.message ??
                  (l10n?.authRegistrationFailed ?? 'Registration failed.'),
            ),
            const SizedBox(height: 12),
          ],
          // Wizard step progress indicator
          _WizardProgressHeader(currentStep: form.wizardStep, totalSteps: 4),
          const SizedBox(height: 16),
          if (form.wizardStep == 1) ...[
            // STEP 1: About You
            Text(
              'About You',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              "Tell us who's managing this account.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            KhTextField(
              label: 'Your name *',
              initialValue: form.contactPersonName,
              onChanged: (v) =>
                  controller.patch((s) => s.copyWith(contactPersonName: v)),
            ),
            KhTextField(
              label: 'Mobile number *',
              initialValue: form.mobileNumber,
              keyboardType: TextInputType.phone,
              onChanged: (v) =>
                  controller.patch((s) => s.copyWith(mobileNumber: v)),
            ),
            KhTextField(
              label: 'Your role (e.g. Owner, Manager)',
              initialValue: form.designation,
              onChanged: (v) =>
                  controller.patch((s) => s.copyWith(designation: v)),
            ),
            const SizedBox(height: 24),
            KhButton(
              label: 'Next: Store profile',
              busy: form.busy,
              onPressed: form.step1Complete ? controller.nextWizardStep : null,
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => context.go(AppGuards.login),
                child: const Text('Already have an account? Sign in'),
              ),
            ),
          ] else if (form.wizardStep == 2) ...[
            // STEP 2: Store Profile
            Text(
              'Store Profile',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tell us about your brand and online presence.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),

            // Logo Upload Section
            _LogoPickerWidget(
              logoPath: form.logoPath,
              onPickLogo: () async {
                final res = await FilePicker.platform.pickFiles(
                  type: FileType.image,
                  allowMultiple: false,
                );
                final path = res?.files.single.path;
                if (path != null) {
                  controller.patch((s) => s.copyWith(logoPath: path));
                }
              },
              onRemoveLogo: () {
                controller.patch((s) => s.copyWith(logoPath: ''));
              },
            ),
            const SizedBox(height: 16),

            KhTextField(
              label: 'Store / Business name *',
              initialValue: form.tradingName,
              onChanged: (v) =>
                  controller.patch((s) => s.copyWith(tradingName: v)),
            ),
            KhTextField(
              label: 'Website (optional)',
              initialValue: form.website,
              keyboardType: TextInputType.url,
              onChanged: (v) =>
                  controller.patch((s) => s.copyWith(website: v)),
            ),
            const SizedBox(height: 24),
            KhButton(
              label: 'Next: Store location',
              busy: form.busy,
              onPressed: form.step2Complete ? controller.nextWizardStep : null,
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: controller.prevWizardStep,
                child: const Text('Back'),
              ),
            ),
          ] else if (form.wizardStep == 3) ...[
            // STEP 3: Store Location
            Text(
              'Store Location',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Where can customers find your physical store?',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            KhTextField(
              label: 'Shop / Unit #',
              initialValue: form.addressShopUnit,
              onChanged: (v) =>
                  controller.patch((s) => s.copyWith(addressShopUnit: v)),
            ),
            KhTextField(
              label: 'Building or street',
              initialValue: form.addressBuilding,
              onChanged: (v) =>
                  controller.patch((s) => s.copyWith(addressBuilding: v)),
            ),
            const SizedBox(height: 8),
            Text(
              'Emirate / Region *',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            regions.when(
              data: (nodes) => Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final leaf in _leaves(nodes))
                    ChoiceChip(
                      label: Text(leaf.nameEn),
                      selected: form.regionId == leaf.id,
                      onSelected: (_) =>
                          controller.patch((s) => s.copyWith(regionId: leaf.id)),
                    ),
                ],
              ),
              loading: () => const KhLoadingView(),
              error: (_, __) => KhInlineError(
                message: l10n?.couldNotLoadRegions ?? 'Could not load regions.',
              ),
            ),
            const SizedBox(height: 14),
            KhTextField(
              label: 'GPS Location / Google Maps Link (optional)',
              initialValue: form.gpsCoordinates,
              keyboardType: TextInputType.streetAddress,
              onChanged: (v) =>
                  controller.patch((s) => s.copyWith(gpsCoordinates: v)),
            ),
            const SizedBox(height: 24),
            KhButton(
              label: 'Next: Contact & Agreement',
              busy: form.busy,
              onPressed: form.step3Complete ? controller.nextWizardStep : null,
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: controller.prevWizardStep,
                child: const Text('Back'),
              ),
            ),
          ] else ...[
            // STEP 4: Contact & Agreement
            Text(
              'Contact & Agreement',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'How customers can connect with you and final terms.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            KhTextField(
              label: 'WhatsApp number *',
              initialValue: form.whatsAppNumber,
              keyboardType: TextInputType.phone,
              onChanged: (v) =>
                  controller.patch((s) => s.copyWith(whatsAppNumber: v)),
            ),
            KhTextField(
              label: 'Email address (optional)',
              initialValue: form.businessEmail,
              keyboardType: TextInputType.emailAddress,
              onChanged: (v) =>
                  controller.patch((s) => s.copyWith(businessEmail: v)),
            ),
            const SizedBox(height: 12),
            // Terms and Privacy Policy
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  key: const Key('vendor-accept-terms-checkbox'),
                  value: form.termsAccepted,
                  onChanged: (v) => controller.patch(
                    (s) => s.copyWith(termsAccepted: v ?? false),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('I agree to the '),
                        InkWell(
                          onTap: () {
                            // Link to Vendor Marketplace Terms
                          },
                          child: Text(
                            'Terms & Conditions',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Text(' and '),
                        InkWell(
                          onTap: () {
                            // Link to Privacy Policy
                          },
                          child: Text(
                            'Privacy Policy',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            KhButton(
              label: 'Create Account',
              busy: form.busy,
              onPressed: form.detailsComplete ? controller.submitDirect : null,
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: controller.prevWizardStep,
                child: const Text('Back'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Iterable<TaxonomyNode> _leaves(List<TaxonomyNode> nodes) sync* {
    for (final n in nodes) {
      if (n.children.isEmpty) {
        yield n;
      } else {
        yield* _leaves(n.children);
      }
    }
  }
}

class _LogoPickerWidget extends StatelessWidget {
  const _LogoPickerWidget({
    required this.logoPath,
    required this.onPickLogo,
    required this.onRemoveLogo,
  });

  final String? logoPath;
  final VoidCallback onPickLogo;
  final VoidCallback onRemoveLogo;

  @override
  Widget build(BuildContext context) {
    final hasLogo = logoPath != null && logoPath!.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        children: [
          InkWell(
            onTap: onPickLogo,
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.outlineVariant,
                  width: 1.5,
                ),
              ),
              child: hasLogo
                  ? ClipOval(
                      child: Center(
                        child: Icon(Icons.business, size: 40, color: colorScheme.primary),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, size: 28, color: colorScheme.primary),
                        const SizedBox(height: 4),
                        Text(
                          'Logo',
                          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: onPickLogo,
                child: Text(hasLogo ? 'Change Logo' : 'Upload Store Logo'),
              ),
              if (hasLogo)
                TextButton(
                  onPressed: onRemoveLogo,
                  child: const Text('Remove', style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WizardProgressHeader extends StatelessWidget {
  const _WizardProgressHeader({
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step $currentStep of $totalSteps',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            Text(
              currentStep == 1 ? 'Contact Info' : 'Business Info',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: currentStep / totalSteps,
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }
}

/// Kept for future OTP unhiding (`RegisterStep.otp`).
class _OtpStep extends StatefulWidget {
  const _OtpStep({
    required this.busy,
    required this.onVerify,
    required this.onResend,
  });
  final bool busy;
  final Future<void> Function(String code) onVerify;
  final Future<void> Function() onResend;

  @override
  State<_OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends State<_OtpStep> {
  String _code = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Text(l10n?.authOtpSentMobile ?? 'We sent a code to your mobile number.'),
        const SizedBox(height: 12),
        OtpField(onChanged: (v) => _code = v, onResend: widget.onResend),
        const SizedBox(height: 12),
        KhButton(
          label: l10n?.authVerifyAndCreateAccount ?? 'Verify & create account',
          busy: widget.busy,
          onPressed: () => widget.onVerify(_code),
        ),
      ],
    );
  }
}
