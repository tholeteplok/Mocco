import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocco/data/datasources/mastery_local_datasource.dart';
import 'package:mocco/presentation/screens/parent/parent_dashboard_screen.dart';

void main() {
  testWidgets('ParentDashboardScreen displays empty state initially, then real data after sessions', (tester) async {
    final ds = InMemoryMasteryLocalDataSource();

    // 1. Initial State: No practice sessions
    await tester.pumpWidget(
      MaterialApp(
        home: ParentDashboardScreen(dataSource: ds),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Dasbor Orang Tua'), findsOneWidget);
    expect(find.text('Belum ada sesi latihan'), findsOneWidget);
    expect(find.text('Ringkasan'), findsNothing);

    // 2. Simulate child practicing Angka 3, Huruf A, and Kata Buku
    await ds.recordSessionResult(
      id: 'number_3',
      attempts: 5,
      correct: 5,
    );
    await ds.recordSessionResult(
      id: 'letter_a',
      attempts: 4,
      correct: 3,
    );
    await ds.recordSessionResult(
      id: 'word_buku',
      attempts: 2,
      correct: 2,
    );

    // 3. Re-render ParentDashboardScreen: Real gameplay statistics must appear
    await tester.pumpWidget(
      MaterialApp(
        home: ParentDashboardScreen(
          key: const Key('dashboard_with_data'),
          dataSource: ds,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Belum ada sesi latihan'), findsNothing);
    expect(find.text('Ringkasan'), findsOneWidget);
    expect(find.text('Kemajuan per Zona'), findsOneWidget);

    // Verify 3 items trained
    expect(find.text('Item dilatih'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    // Verify zone rows
    expect(find.text('Angka'), findsOneWidget);
    expect(find.text('Huruf'), findsOneWidget);
    expect(find.text('Kata'), findsOneWidget);

    // Verify correct totals (5 + 3 + 2 = 10 correct from 11 attempts)
    expect(find.text('Jawaban benar 10 dari 11 percobaan.'), findsOneWidget);
  });
}
