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

  testWidgets('KhNumericField LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'kh_numeric_field',
      builder: () => const KhNumericField(label: 'Weight', unit: 'g'),
    );
  });

  testWidgets('KhSelectField LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'kh_select_field',
      builder: () => KhSelectField<String>(
        label: 'Purity',
        emptyLabel: 'Choose',
        options: const [
          KhSelectOption(value: '24K', label: '24 karat'),
        ],
        onChanged: (_) {},
      ),
    );
  });

  testWidgets('KhConfirmDialog LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'kh_confirm_dialog',
      size: const Size(400, 400),
      builder: () => const KhConfirmDialog(
        title: 'Mark as Interested',
        body: 'This cannot be undone.',
        confirmLabel: 'Confirm',
        cancelLabel: 'Cancel',
        destructive: true,
      ),
    );
  });

  testWidgets('KhBadge LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'kh_badge',
      builder: () => const KhBadge(count: 3),
    );
  });

  testWidgets('KhStatusChip LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'kh_status_chip',
      builder: () => const KhStatusChip(label: 'LIVE', tone: KhStatusTone.success),
    );
  });

  testWidgets('KhAppBar LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'kh_app_bar',
      builder: () => const SizedBox(
        height: kToolbarHeight,
        child: KhAppBar(title: 'Home', actions: [Icon(Icons.filter_list)]),
      ),
    );
  });

  testWidgets('KhBottomNav LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'kh_bottom_nav',
      size: const Size(400, 120),
      builder: () => KhBottomNav(
        destinations: const [
          KhNavDestination(label: 'Home', icon: Icons.home_outlined),
          KhNavDestination(label: 'Alerts', icon: Icons.notifications_outlined, badgeCount: 2),
        ],
        currentIndex: 0,
        onDestinationSelected: (_) {},
      ),
    );
  });

  testWidgets('KhAppShell LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'kh_app_shell',
      size: const Size(400, 640),
      builder: () => SizedBox(
        width: 400,
        height: 640,
        child: KhAppShell(
          title: 'Home',
          destinations: const [
            KhNavDestination(label: 'Home', icon: Icons.home_outlined),
            KhNavDestination(label: 'Alerts', icon: Icons.notifications_outlined),
          ],
          currentIndex: 0,
          onDestinationSelected: (_) {},
          body: const Center(child: Text('body')),
        ),
      ),
    );
  });

  testWidgets('KhPullToRefresh LTR+RTL golden', (tester) async {
    await expectKhGoldens(
      tester,
      name: 'kh_pull_to_refresh',
      size: const Size(400, 240),
      builder: () => SizedBox(
        height: 200,
        child: KhPullToRefresh(
          lastUpdated: 'Updated 2 m ago',
          onRefresh: () async {},
          child: ListView(children: const [ListTile(title: Text('Item'))]),
        ),
      ),
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
}
