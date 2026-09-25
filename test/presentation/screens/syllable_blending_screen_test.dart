import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocco/domain/entities/word_entity.dart';
import 'package:mocco/presentation/screens/blending/syllable_blending_screen.dart';
import 'package:mocco/presentation/widgets/blending/syllable_card.dart';
import 'package:mocco/presentation/widgets/blending/word_slot.dart';
import 'package:mocco/presentation/widgets/buttons/bubble_icon_button.dart';

void main() {
  testWidgets('SyllableBlendingScreen renders slots, icon and syllable cards', (tester) async {
    const testWord = WordEntity(
      id: 'buku',
      word: 'buku',
      syllable1: 'bu',
      syllable2: 'ku',
      icon: Icons.menu_book_rounded,
    );

    bool completed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SyllableBlendingScreen(
          words: const [testWord],
          onCompleted: () => completed = true,
        ),
      ),
    );

    // Verifies icon is displayed
    expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);

    // Verifies 2 word slots are displayed
    expect(find.byType(WordSlot), findsNWidgets(2));

    // Verifies 4 syllable cards are displayed
    expect(find.byType(SyllableCard), findsNWidgets(4));

    // Tap syllable "bu"
    await tester.tap(find.widgetWithText(SyllableCard, 'bu'));
    await tester.pump(const Duration(milliseconds: 100));

    // Verify "bu" is placed in a WordSlot
    expect(
      find.descendant(of: find.byType(WordSlot), matching: find.text('bu')),
      findsOneWidget,
    );

    // Tap syllable "ku"
    await tester.tap(find.widgetWithText(SyllableCard, 'ku'));
    await tester.pump();

    // Child keeps control — tap 3D Next Button on celebration dialog (no auto-advance)
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byType(BubbleIconButton).last);
    await tester.pump();

    expect(completed, isTrue);
  });
}
