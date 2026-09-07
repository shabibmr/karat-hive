import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';

import 'golden_runner.dart';

void main() {
  testWidgets('KhButton LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'kh_button',
      builder: () => KhButton(label: 'Continue', onPressed: () {}),
    );
  });

  testWidgets('KhEmptyView LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'kh_empty_view',
      builder: () => const KhEmptyView(message: 'Nothing here yet'),
    );
  });

  testWidgets('DocumentUploadTile empty LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'upload_tile_empty',
      builder: () => DocumentUploadTile(
        label: 'Trade licence',
        state: UploadTileState.empty,
        onPick: () {},
      ),
    );
  });

  testWidgets('KhStatusChip tones LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'kh_status_chip_tones',
      builder: () => const Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          KhStatusChip(label: 'Neutral', tone: KhStatusTone.neutral),
          KhStatusChip(label: 'Accent', tone: KhStatusTone.accent),
          KhStatusChip(label: 'Success', tone: KhStatusTone.success),
          KhStatusChip(label: 'Warning', tone: KhStatusTone.warning),
          KhStatusChip(label: 'Danger', tone: KhStatusTone.danger),
        ],
      ),
    );
  });

  testWidgets('KhSectionHeader with action LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'kh_section_header_action',
      size: const Size(400, 80),
      builder: () => KhSectionHeader(
        title: 'Latest matches',
        actionLabel: 'See all',
        onAction: () {},
      ),
    );
  });

  testWidgets('KhSectionHeader without action LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'kh_section_header',
      size: const Size(400, 80),
      builder: () => const KhSectionHeader(title: 'Latest matches'),
    );
  });

  // Empty state only — Image.network is non-deterministic under goldens.
  testWidgets('KhImageGallery empty LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'kh_image_gallery_empty',
      size: const Size(400, 160),
      builder: () => const SizedBox(
        width: 360,
        child: KhImageGallery(imageUrls: []),
      ),
    );
  });
}
