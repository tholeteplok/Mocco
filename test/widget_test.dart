import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocco/domain/entities/counting_question.dart';
import 'package:mocco/domain/services/counting_question_generator.dart';
import 'package:mocco/main.dart';
import 'package:mocco/presentation/screens/counting/counting_screen.dart';
import 'package:mocco/presentation/screens/letter/letter_onboarding_screen.dart';
import 'package:mocco/presentation/screens/letter/letter_quiz_screen.dart';
import 'package:mocco/presentation/screens/map/adventure_map_screen.dart';
import 'package:mocco/presentation/widgets/buttons/audio_prompt_button.dart';
import 'package:mocco/presentation/widgets/buttons/bubble_icon_button.dart';
import 'package:mocco/presentation/widgets/cards/flashcard_answer.dart';
import 'package:mocco/presentation/widgets/counting/counting_basket.dart';
import 'package:mocco/presentation/widgets/counting/counting_object_item.dart';
import 'package:mocco/presentation/widgets/dialogs/parent_gate_dialog.dart';
import 'package:mocco/presentation/widgets/map/map_node_button.dart';
import 'package:mocco/presentation/widgets/tracing/tracing_canvas.dart';

class MockCountingGenerator extends CountingQuestionGenerator {
  const MockCountingGenerator();

  @override
  CountingQuestion generate({int? targetCount, String? objectType, dynamic random}) {
    return const CountingQuestion(
      objectType: 'assets/images/objects/apple.png',
      count: 3,
      correctAnswer: 3,
      options: [2, 3, 4, 6],
    );
  }
}

void main() {
  testWidgets('AdventureMapScreen renders, toggles zones, and opens ParentGate', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AdventureMapScreen(
          unlockedNumberIndex: 2,
          unlockedLetterIndex: 2,
        ),
      ),
    );
    await tester.pump();

    // Verify map node buttons for numbers are rendered
    expect(find.byType(MapNodeButton), findsWidgets);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    // Tap Parent Gate lock button to open ParentGateDialog
    final parentGateFinder = find.descendant(
      of: find.byType(BubbleIconButton),
      matching: find.byIcon(Icons.lock_rounded),
    );
    await tester.tap(parentGateFinder);
    await tester.pump();

    expect(find.byType(ParentGateDialog), findsOneWidget);
    expect(find.text('Area Orang Tua'), findsOneWidget);

    // Close ParentGateDialog
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();

    // Switch to Letters zone
    await tester.tap(find.byIcon(Icons.sort_by_alpha_rounded));
    await tester.pump();

    // Verify letter nodes (e.g. 'Aa', 'Bb') are rendered
    expect(find.text('Aa'), findsOneWidget);
    expect(find.text('Bb'), findsOneWidget);

    // Switch to Words zone
    await tester.tap(find.byIcon(Icons.auto_stories_rounded));
    await tester.pump();

    // Verify word nodes (e.g. 'bu-ku') are rendered
    expect(find.text('bu-ku'), findsOneWidget);
  });

  testWidgets('CountingScreen renders and supports basket drag/tap interaction', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CountingScreen(
          generator: MockCountingGenerator(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(AudioPromptButton), findsOneWidget);
    expect(find.byType(CountingObjectItem), findsNWidgets(3));
    expect(find.byType(CountingBasket), findsOneWidget);
    expect(find.byType(FlashcardAnswer), findsNWidgets(4));

    // Tap first object to drop into basket
    await tester.tap(find.byType(CountingObjectItem).first);
    await tester.pump();

    // Tap correct flashcard '3'
    await tester.tap(find.text('3'));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('LetterOnboardingScreen renders uppercase+lowercase and toggles tracing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LetterOnboardingScreen(letterIndex: 0),
      ),
    );
    await tester.pump();

    expect(find.text('Aa'), findsOneWidget);
    expect(find.byType(AudioPromptButton), findsOneWidget);

    // Tap toggle tracing button
    await tester.tap(find.byIcon(Icons.gesture_rounded));
    await tester.pump();

    expect(find.byType(TracingCanvas), findsOneWidget);
  });

  testWidgets('LetterQuizScreen renders and responds to option selection', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LetterQuizScreen(totalSteps: 3),
      ),
    );
    await tester.pump();

    expect(find.byType(AudioPromptButton), findsOneWidget);
    expect(find.byType(FlashcardAnswer), findsNWidgets(4));

    await tester.tap(find.byType(FlashcardAnswer).first);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('MoccoApp boots into AdventureMapScreen cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(const MoccoApp());
    await tester.pump();

    expect(find.byType(AdventureMapScreen), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(BubbleIconButton),
        matching: find.byIcon(Icons.lock_rounded),
      ),
      findsOneWidget,
    );
    expect(find.byType(MapNodeButton), findsWidgets);
  });
}
