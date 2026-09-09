import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_data_table.dart';

Widget _buildTestTable() {
  return const SizedBox(
    width: 800,
    height: 350,
    child: KhDataTable(
      columns: [
        KhTableColumn('Queue Item', flex: 3),
        KhTableColumn('Category', flex: 2),
        KhTableColumn('Status', flex: 2),
      ],
      rows: [
        KhTableRow(
          cells: [
            Text('Al Noor Jewellery LLC'),
            Text('Bridal Necklaces'),
            Text('PENDING'),
          ],
        ),
        KhTableRow(
          cells: [
            Text('Dubai Gold Souk Store'),
            Text('Bullion 24K'),
            Text('VERIFIED'),
          ],
        ),
        KhTableRow(
          cells: [
            Text('Emirates Diamond Trading'),
            Text('Rings & Bands'),
            Text('REJECTED'),
          ],
        ),
      ],
    ),
  );
}

Future<void> _pumpTable(
  WidgetTester tester, {
  required TextDirection textDirection,
  double textScaleFactor = 1.0,
}) async {
  await tester.binding.setSurfaceSize(const Size(840, 400));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      theme: buildKhAdminTheme(),
      home: Directionality(
        textDirection: textDirection,
        child: MediaQuery(
          data: MediaQueryData(
            size: const Size(840, 400),
            textScaler: TextScaler.linear(textScaleFactor),
          ),
          child: Scaffold(
            body: Center(
              child: _buildTestTable(),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('KhDataTable LTR golden', (tester) async {
    await _pumpTable(tester, textDirection: TextDirection.ltr);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/kh_data_table_ltr.png'),
    );
  });

  testWidgets('KhDataTable RTL golden', (tester) async {
    await _pumpTable(tester, textDirection: TextDirection.rtl);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/kh_data_table_rtl.png'),
    );
  });

  testWidgets('KhDataTable 200% text scale golden', (tester) async {
    await _pumpTable(
      tester,
      textDirection: TextDirection.ltr,
      textScaleFactor: 2.0,
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/kh_data_table_200.png'),
    );
  });
}
