import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocco/core/tokens/app_colors.dart';
import 'package:mocco/domain/entities/journey_node.dart';
import 'package:mocco/presentation/screens/letter/letter_onboarding_screen.dart';
import 'package:mocco/presentation/screens/node/node_detail_screen.dart';
import 'package:mocco/presentation/widgets/cards/flashcard_answer.dart';
import 'package:mocco/presentation/widgets/feedback/celebration_banner.dart';
import 'package:mocco/presentation/widgets/tracing/guided_tracing_canvas.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Letter Flow Tests (Metode Angka ke Huruf)', () {
    testWidgets('NodeDetailScreen for Letter renders living stage, tactile 3D object, and Ayo Latihan button', (tester) async {
      bool started = false;

      const letterNode = JourneyNode(
        globalIndex: 11,
        label: 'Aa',
        type: NodeType.letters,
        typeIndex: 0, // Letter A
        primaryColor: AppColors.letterPrimary,
        bevelColor: AppColors.letterBevel,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: NodeDetailScreen(
            node: letterNode,
            onStartActivity: () => started = true,
          ),
        ),
      );
      await tester.pump();

      // Verify glyph "Aa" rendered prominently
      expect(find.text('Aa'), findsOneWidget);
      expect(find.text('Ketuk untuk mendengar'), findsOneWidget);

      // Verify tactile interactive object prompt & example word
      expect(find.text('Sentuh benda untuk mengenal huruf! 👇'), findsOneWidget);
      expect(find.text('A untuk Apel'), findsOneWidget);

      // Verify single prominent CTA button
      expect(find.text('Ayo Latihan!'), findsOneWidget);

      // Tap "Ayo Latihan!"
      await tester.ensureVisible(find.text('Ayo Latihan!'));
      await tester.tap(find.text('Ayo Latihan!'));
      await tester.pump();

      expect(started, isTrue);
    });

    testWidgets('LetterOnboardingScreen executes Step 1 Tracing and advances to Step 2 Quiz', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LetterOnboardingScreen(
            letterIndex: 0, // Letter A
            totalSteps: 5,
          ),
        ),
      );
      await tester.pump();

      // Step 1: Verify GuidedTracingCanvas for 'A'
      expect(find.text('Tebalkan huruf Aa!'), findsOneWidget);
      expect(find.byType(GuidedTracingCanvas), findsOneWidget);
      expect(find.text('Tebalkan Dulu Ya ✏️'), findsOneWidget);

      // Simulate completion of tracing via canvas key
      final canvasFinder = find.byType(GuidedTracingCanvas);
      final canvasState = tester.state<GuidedTracingCanvasState>(canvasFinder);
      canvasState.widget.onCompleted?.call();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify celebration banner with "Lanjut Latihan"
      expect(find.byType(CelebrationBanner), findsOneWidget);
      expect(find.text('Lanjut Latihan'), findsOneWidget);

      // Tap "Lanjut Latihan" to enter Step 2 Matching (Huruf Besar & Huruf Kecil)
      await tester.tap(find.text('Lanjut Latihan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Step 2: Verify Uppercase to Lowercase matching stage
      expect(find.text('Pasangkan huruf A! 🧩'), findsOneWidget);
      expect(find.text('A'), findsAtLeast(1));
      expect(find.byType(FlashcardAnswer), findsNWidgets(4));

      // Tap correct lowercase option ('a')
      final lowerOptionFinder = find.widgetWithText(FlashcardAnswer, 'a');
      await tester.tap(lowerOptionFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify matching celebration banner with "Lanjut"
      expect(find.byType(CelebrationBanner), findsOneWidget);
      expect(find.text('Lanjut'), findsOneWidget);

      // Tap "Lanjut" to enter Step 3 Audio-Visual Quiz
      await tester.tap(find.text('Lanjut'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Step 3: Verify audio-visual letter recognition quiz
      expect(find.text('Mana huruf Aa?'), findsOneWidget);
      expect(find.text('A untuk Apel'), findsOneWidget);
      expect(find.byType(FlashcardAnswer), findsNWidgets(4));

      // Tap correct option ('A' or 'a' depending on balanced mixedCase)
      final upperFinder = find.widgetWithText(FlashcardAnswer, 'A');
      final optionFinder = upperFinder.evaluate().isNotEmpty
          ? upperFinder
          : find.widgetWithText(FlashcardAnswer, 'a');
      await tester.tap(optionFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify dopamine celebration banner
      expect(find.byType(CelebrationBanner), findsOneWidget);
      expect(find.text('Kamu menemukan huruf A!'), findsOneWidget);
    });
  });
}
