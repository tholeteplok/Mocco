import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocco/domain/services/counting_question_generator.dart';
import 'package:mocco/presentation/screens/counting/counting_screen.dart';
import 'package:mocco/presentation/screens/map/adventure_map_screen.dart';
import 'package:mocco/presentation/widgets/map/map_node_button.dart';
import 'package:mocco/presentation/widgets/tracing/guided_tracing_canvas.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Helper untuk mensimulasikan sapuan jari anak secara kontinu di sepanjang garis
  Future<void> dragLine(WidgetTester tester, TestGesture gesture, Offset from, Offset to, {int steps = 15}) async {
    for (int i = 1; i <= steps; i++) {
      final t = i / steps;
      await gesture.moveTo(Offset.lerp(from, to, t)!);
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  group('Counting & Tracing Flow Tests', () {
    testWidgets('CountingScreen with targetNumber: 10 renders GuidedTracingCanvas for 10', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CountingScreen(
            totalSteps: 5,
            targetNumber: 10,
            generator: CountingQuestionGenerator(fixedTargetCount: 10),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verifies Tracing stage is Step 1
      expect(find.text('Tebalkan angka 10!'), findsOneWidget);
      expect(find.byType(GuidedTracingCanvas), findsOneWidget);

      final canvasFinder = find.byType(GuidedTracingCanvas);
      final canvasWidget = tester.widget<GuidedTracingCanvas>(canvasFinder);
      expect(canvasWidget.char, equals('10'));

      // Verifies combined control: [ ▶ Contoh ]
      expect(find.text('Contoh'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });

    testWidgets('CountingScreen with targetNumber: null skips tracing completely', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CountingScreen(
            totalSteps: 5,
            targetNumber: null,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Tracing must NOT appear if targetNumber is null
      expect(find.textContaining('Tebalkan'), findsNothing);
      expect(find.byType(GuidedTracingCanvas), findsNothing);
    });

    testWidgets('GuidedTracingCanvas for 10 requires both stroke 1 and stroke 0 to complete', (tester) async {
      bool isCompleted = false;

      final key = GlobalKey<GuidedTracingCanvasState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GuidedTracingCanvas(
                key: key,
                char: '10',
                size: 290.0,
                autoPlayDemo: false,
                onCompleted: () => isCompleted = true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(key.currentState, isNotNull);
      final state = key.currentState!;

      expect(state.isCompleted, isFalse);
      expect(state.areAllStrokesCompleted, isFalse);

      final gestureFinder = find.descendant(
        of: find.byType(GuidedTracingCanvas),
        matching: find.byType(GestureDetector),
      );
      final canvasOrigin = tester.getTopLeft(gestureFinder.first);
      final scale = 290.0 / 100.0;

      // ── Step 1: Trace only Stroke 0 (Digit '1') ──────────────────────────
      // Koordinat stroke digit 1: (22, 28) -> (34, 14) -> (34, 86)
      final p0 = canvasOrigin + Offset(22 * scale, 28 * scale);
      final p1 = canvasOrigin + Offset(34 * scale, 14 * scale);
      final p2 = canvasOrigin + Offset(34 * scale, 86 * scale);

      final gesture1 = await tester.startGesture(p0);
      await tester.pump();
      await dragLine(tester, gesture1, p0, p1, steps: 10);
      await dragLine(tester, gesture1, p1, p2, steps: 25);
      await gesture1.up();
      await tester.pump();

      // Stroke 0 selesai, tapi Stroke 1 (digit 0) BELUM selesai
      expect(state.isStrokeCompleted(0), isTrue, reason: 'Digit 1 should be completed');
      expect(state.isStrokeCompleted(1), isFalse, reason: 'Digit 0 not yet traced');
      expect(state.areAllStrokesCompleted, isFalse, reason: '10 must not be complete with only digit 1');
      expect(isCompleted, isFalse);

      // ── Step 2: Trace Stroke 1 (Digit '0') ──────────────────────────────
      // Ellipse center: (68, 50), rx=18, ry=36.
      final center0 = canvasOrigin + Offset(68 * scale, 50 * scale);
      final rx = 18.0 * scale;
      final ry = 36.0 * scale;

      final pStart0 = center0 + Offset(0, -ry);
      final gesture0 = await tester.startGesture(pStart0);
      await tester.pump();

      // Sapukan jari mengelilingi elips dengan 24 titik
      for (int i = 1; i <= 24; i++) {
        final angle = -math.pi / 2 - (2 * math.pi * i / 24);
        final pt = center0 + Offset(rx * math.cos(angle), ry * math.sin(angle));
        await gesture0.moveTo(pt);
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture0.up();
      await tester.pump();

      // Sekarang kedua stroke selesai
      expect(state.isStrokeCompleted(1), isTrue, reason: 'Digit 0 should now be completed');
      expect(state.areAllStrokesCompleted, isTrue, reason: 'Both digits 1 and 0 are completed');
      expect(isCompleted, isTrue, reason: 'onCompleted callback should be fired');
    });

    testWidgets('GuidedTracingCanvas for 4 requires both L-stroke and vertical stroke to complete', (tester) async {
      bool isCompleted = false;
      final key = GlobalKey<GuidedTracingCanvasState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GuidedTracingCanvas(
                key: key,
                char: '4',
                size: 290.0,
                autoPlayDemo: false,
                onCompleted: () => isCompleted = true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final state = key.currentState!;
      final gestureFinder = find.descendant(
        of: find.byType(GuidedTracingCanvas),
        matching: find.byType(GestureDetector),
      );
      final canvasOrigin = tester.getTopLeft(gestureFinder.first);
      final scale = 290.0 / 100.0;

      // ── Stroke 0: L-shape [62, 12] -> [24, 62] -> [78, 62] ────────────
      final p0 = canvasOrigin + Offset(62 * scale, 12 * scale);
      final p1 = canvasOrigin + Offset(24 * scale, 62 * scale);
      final p2 = canvasOrigin + Offset(78 * scale, 62 * scale);

      final gesture = await tester.startGesture(p0);
      await tester.pump();
      await dragLine(tester, gesture, p0, p1, steps: 15);
      await dragLine(tester, gesture, p1, p2, steps: 15);
      await gesture.up();
      await tester.pump();

      // Stroke 0 selesai, Stroke 1 BELUM
      expect(state.isStrokeCompleted(0), isTrue);
      expect(state.isStrokeCompleted(1), isFalse);
      expect(state.areAllStrokesCompleted, isFalse);
      expect(isCompleted, isFalse);

      // ── Stroke 1: Vertical line [62, 12] -> [62, 88] ───────────────────
      final p3 = canvasOrigin + Offset(62 * scale, 12 * scale);
      final p4 = canvasOrigin + Offset(62 * scale, 88 * scale);

      final gesture2 = await tester.startGesture(p3);
      await tester.pump();
      await dragLine(tester, gesture2, p3, p4, steps: 25);
      await gesture2.up();
      await tester.pump();

      expect(state.isStrokeCompleted(1), isTrue);
      expect(state.areAllStrokesCompleted, isTrue);
      expect(isCompleted, isTrue);
    });

    testWidgets('Tapping node 10 on AdventureMapScreen launches CountingScreen with targetNumber: 10', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdventureMapScreen(
            unlockedNumberIndex: 10,
          ),
        ),
      );
      await tester.pump();

      // Node 10 is inside a SingleChildScrollView, ensure it is scrolled into view
      final node10Finder = find.widgetWithText(MapNodeButton, '10');
      expect(node10Finder, findsOneWidget);

      await tester.ensureVisible(node10Finder);
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(node10Finder, warnIfMissed: false);
      await tester.pump();
      // Allow navigation transition and GuidedTracingCanvas autoPlay timer (350ms) to complete
      await tester.pump(const Duration(seconds: 1));

      // Verify that CountingScreen is now visible AND Step 1 is Tracing for 10!
      expect(find.byType(CountingScreen), findsOneWidget);
      expect(find.text('Tebalkan angka 10!'), findsOneWidget);
      expect(find.byType(GuidedTracingCanvas), findsOneWidget);
    });

    testWidgets('GuidedTracingCanvas rejects off-path touches and enforces sequential stroke guard', (tester) async {
      final key = GlobalKey<GuidedTracingCanvasState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GuidedTracingCanvas(
                key: key,
                char: '10',
                size: 290.0,
                autoPlayDemo: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final state = key.currentState!;
      final gestureFinder = find.descendant(
        of: find.byType(GuidedTracingCanvas),
        matching: find.byType(GestureDetector),
      );
      final canvasOrigin = tester.getTopLeft(gestureFinder.first);
      final scale = 290.0 / 100.0;

      // 1. Sentuhan yang melenceng jauh di luar garis panduan (deviasi > 15dp)
      // Koordinat (5, 5) berada di sudut kanvas yang jauh dari angka 10
      final farPoint = canvasOrigin + Offset(5 * scale, 5 * scale);
      final farGesture = await tester.startGesture(farPoint);
      await tester.pump();
      await farGesture.up();
      await tester.pump();

      // Progres harus tetap 0.0 (sentuhan asal-asalan ditolak)
      expect(state.progress, equals(0.0), reason: 'Off-path touch must be rejected');

      // 2. Sentuhan langsung ke Stroke 1 (digit 0) sebelum Stroke 0 (digit 1) dikerjakan
      // Titik awal digit 0: (68, 14)
      final pStartDigit0 = canvasOrigin + Offset(68 * scale, 14 * scale);
      final prematureGesture = await tester.startGesture(pStartDigit0);
      await tester.pump();
      await prematureGesture.up();
      await tester.pump();

      // Stroke 1 harus tetap 0 karena Stroke 0 belum mencapai 60%
      expect(state.isStrokeCompleted(1), isFalse);
      expect(state.progress, equals(0.0), reason: 'Premature stroke 1 touch must be blocked by sequential guard');
    });
  });
}
