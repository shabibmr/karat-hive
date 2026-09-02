import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../../onboarding/repository/onboarding_repository.dart';
import '../controller/vendor_register_controller.dart';
import '../model/register_form_state.dart';

class VendorRegisterScreen extends ConsumerWidget {
  const VendorRegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(vendorRegisterControllerProvider);
    final controller = ref.read(vendorRegisterControllerProvider.notifier);
    final categories = ref.watch(categoriesProvider);
    final regions = ref.watch(regionsProvider);

    return KhScaffold(
      title: 'Create a vendor account',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (form.failure != null) ...[
            KhInlineError(message: form.failure!.message ?? 'Registration failed.'),
            const SizedBox(height: 12),
          ],
          if (form.step == RegisterStep.otp)
            _OtpStep(busy: form.busy, onVerify: controller.verifyOtp, onResend: controller.sendOtp)
          else ...[
            KhTextField(
              label: 'Mobile number',
              initialValue: form.mobileNumber,
              keyboardType: TextInputType.phone,
              onChanged: (v) => controller.patch((s) => s.copyWith(mobileNumber: v)),
            ),
            KhTextField(
              label: 'Legal business name',
              initialValue: form.legalBusinessName,
              onChanged: (v) => controller.patch((s) => s.copyWith(legalBusinessName: v)),
            ),
            KhTextField(
              label: 'Trading name',
              initialValue: form.tradingName,
              onChanged: (v) => controller.patch((s) => s.copyWith(tradingName: v)),
            ),
            KhTextField(
              label: 'Trade licence number',
              initialValue: form.tradeLicenceNumber,
              onChanged: (v) => controller.patch((s) => s.copyWith(tradeLicenceNumber: v)),
            ),
            KhTextField(
              label: 'Licence expiry (YYYY-MM-DD)',
              initialValue: form.licenceExpiryDate,
              onChanged: (v) => controller.patch((s) => s.copyWith(licenceExpiryDate: v)),
            ),
            KhTextField(
              label: 'Business address',
              initialValue: form.businessAddress,
              onChanged: (v) => controller.patch((s) => s.copyWith(businessAddress: v)),
            ),
            KhTextField(
              label: 'Contact person',
              initialValue: form.contactPersonName,
              onChanged: (v) => controller.patch((s) => s.copyWith(contactPersonName: v)),
            ),
            KhTextField(
              label: 'Business email',
              initialValue: form.businessEmail,
              keyboardType: TextInputType.emailAddress,
              onChanged: (v) => controller.patch((s) => s.copyWith(businessEmail: v)),
            ),
            const SizedBox(height: 8),
            const Text('Home region'),
            regions.when(
              data: (nodes) => Wrap(
                spacing: 8,
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
              error: (_, __) => const KhInlineError(message: 'Could not load regions.'),
            ),
            const SizedBox(height: 12),
            const Text('Categories you serve'),
            categories.when(
              data: (nodes) => CategoryRegionPicker(
                nodes: nodes,
                selected: form.categoryIds.toSet(),
                locale: 'en',
                onToggle: (id) => controller.patch(
                  (s) => s.copyWith(categoryIds: _toggle(s.categoryIds, id)),
                ),
              ),
              loading: () => const KhLoadingView(),
              error: (_, __) => const KhInlineError(message: 'Could not load categories.'),
            ),
            const SizedBox(height: 12),
            const Text('Regions you serve'),
            regions.when(
              data: (nodes) => CategoryRegionPicker(
                nodes: nodes,
                selected: form.servedRegionIds.toSet(),
                locale: 'en',
                onToggle: (id) => controller.patch(
                  (s) => s.copyWith(servedRegionIds: _toggle(s.servedRegionIds, id)),
                ),
              ),
              loading: () => const KhLoadingView(),
              error: (_, __) => const KhInlineError(message: 'Could not load regions.'),
            ),
            const SizedBox(height: 16),
            KhButton(
              label: 'Continue',
              busy: form.busy,
              onPressed: form.detailsComplete ? controller.sendOtp : null,
            ),
            TextButton(
              onPressed: () => context.go('/vendor/login'),
              child: const Text('Back to sign in'),
            ),
          ],
        ],
      ),
    );
  }

  static List<T> _toggle<T>(List<T> list, T value) {
    final next = [...list];
    next.contains(value) ? next.remove(value) : next.add(value);
    return next;
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

class _OtpStep extends StatefulWidget {
  const _OtpStep({required this.busy, required this.onVerify, required this.onResend});
  final bool busy;
  final Future<void> Function(String code) onVerify;
  final Future<void> Function() onResend;

  @override
  State<_OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends State<_OtpStep> {
  String _code = '';

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const Text('We sent a code to your mobile number.'),
          const SizedBox(height: 12),
          OtpField(onChanged: (v) => _code = v, onResend: widget.onResend),
          const SizedBox(height: 12),
          KhButton(
            label: 'Verify & create account',
            busy: widget.busy,
            onPressed: () => widget.onVerify(_code),
          ),
        ],
      );
}
