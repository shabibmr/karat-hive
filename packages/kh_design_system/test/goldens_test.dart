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
}
