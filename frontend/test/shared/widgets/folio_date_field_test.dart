import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/widgets/folio_date_field.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

void main() {
  test('format tanggal untuk API dan tampilan', () {
    expect(folioIsoDate(DateTime(2023, 1, 5)), '2023-01-05');
    expect(folioDisplayDate(DateTime(2023, 1, 5)), '5 Jan 2023');
    expect(folioDisplayDate(DateTime(2024, 12, 31)), '31 Des 2024');
  });

  testWidgets('menampilkan tanggal yang dipilih lewat date picker', (
    tester,
  ) async {
    DateTime? value = DateTime(2023, 1, 15);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => folioDateField(
              label: 'Mulai*',
              value: value,
              onChanged: (d) => setState(() => value = d),
            ),
          ),
        ),
      ),
    );

    expect(find.text('15 Jan 2023'), findsOneWidget);

    await tester.tap(find.text('15 Jan 2023'));
    await tester.pumpAndSettle();

    expect(find.byType(SfDateRangePicker), findsOneWidget);
    expect(find.text('Pilih'), findsOneWidget);

    await tester.tap(find.text('Pilih'));
    await tester.pumpAndSettle();

    expect(value, DateTime(2023, 1, 15));
    expect(find.text('15 Jan 2023'), findsOneWidget);
  });

  testWidgets('tombol hapus mengosongkan tanggal', (tester) async {
    DateTime? value = DateTime(2023, 1, 15);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => folioDateField(
              label: 'Selesai',
              value: value,
              onChanged: (d) => setState(() => value = d),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Hapus tanggal'));
    await tester.pumpAndSettle();

    expect(value, isNull);
    expect(find.text('15 Jan 2023'), findsNothing);
  });

  testWidgets('field nonaktif tidak membuka date picker', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: folioDateField(
            label: 'Selesai',
            value: DateTime(2023, 1, 15),
            enabled: false,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('15 Jan 2023'));
    await tester.pumpAndSettle();

    expect(find.byType(SfDateRangePicker), findsNothing);
  });
}
