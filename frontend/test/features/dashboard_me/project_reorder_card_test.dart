import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/models/project_model.dart';
import 'package:frontend/features/dashboard_me/project_reorder_card.dart';

void main() {
  // Guard regresi C1: kartu proyek dipasang langsung di dalam Wrap, yang
  // memberi anaknya tinggi tak terbatas. Tanpa batasan tinggi pada kartu,
  // Spacer di dalam Column meledak dengan
  // "RenderFlex children have non-zero flex but incoming height constraints
  // are unbounded" — crash deterministik saat tab Proyek aktif.
  testWidgets(
    'ProjectReorderCard lays out inside an unbounded-height Wrap '
    'without a RenderFlex exception',
    (tester) async {
      final project = ProjectModel(
        id: 1,
        title: 'Proyek Uji',
        slug: 'proyek-uji',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                // Tanpa Draggable/DragTarget: cukup bentuk anak Wrap yang
                // memicu constraint tak terbatas — maksudnya menjaga test
                // fokus pada constraint, bukan pada perilaku drag.
                ProjectReorderCard(project: project, index: 0),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Proyek Uji'), findsOneWidget);
      expect(find.text('Urutan 1'), findsOneWidget);
    },
  );
}
