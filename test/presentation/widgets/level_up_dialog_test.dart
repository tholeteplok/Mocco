import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocco/presentation/widgets/dialogs/level_up_dialog.dart';
import 'package:mocco/presentation/widgets/buttons/bubble_icon_button.dart';
import 'package:mocco/presentation/widgets/mascot/mascot_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LevelUpDialog Widget Tests', () {
    testWidgets('renders standard level milestone with Hore! and 3D next button', (tester) async {
      bool continued = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LevelUpDialog(
              milestoneType: LevelMilestoneType.standard,
              onContinue: () => continued = true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Hore!'), findsOneWidget);
      expect(find.byType(MascotWidget), findsOneWidget);
      expect(find.byType(BubbleIconButton), findsOneWidget);

      await tester.tap(find.byType(BubbleIconButton));
      await tester.pump();

      expect(continued, isTrue);
    });

    testWidgets('renders halfway alphabet milestone with Hebat!', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LevelUpDialog(
              milestoneType: LevelMilestoneType.halfwayAlphabet,
              onContinue: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Hebat!'), findsOneWidget);
      expect(find.byType(MascotWidget), findsOneWidget);
      expect(find.byType(BubbleIconButton), findsOneWidget);
    });

    testWidgets('renders zone angka milestone with Luar Biasa! and trophy', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LevelUpDialog(
              milestoneType: LevelMilestoneType.zoneAngka,
              onContinue: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Luar Biasa!'), findsOneWidget);
      expect(find.byType(MascotWidget), findsOneWidget);
      expect(find.byType(BubbleIconButton), findsOneWidget);
    });

    testWidgets('renders zone huruf milestone correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LevelUpDialog(
              milestoneType: LevelMilestoneType.zoneHuruf,
              onContinue: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Luar Biasa!'), findsOneWidget);
      expect(find.byType(BubbleIconButton), findsOneWidget);
    });

    testWidgets('renders grand completion milestone correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LevelUpDialog(
              milestoneType: LevelMilestoneType.grandCompletion,
              onContinue: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Luar Biasa!'), findsOneWidget);
      expect(find.byType(BubbleIconButton), findsOneWidget);
    });

    testWidgets('LevelUpDialog.show displays modal bottom sheet and dismisses on tap', (tester) async {
      bool continued = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  LevelUpDialog.show(
                    context: context,
                    milestoneType: LevelMilestoneType.standard,
                    onContinue: () => continued = true,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap to open modal
      await tester.tap(find.text('Show Dialog'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(LevelUpDialog), findsOneWidget);
      expect(find.text('Hore!'), findsOneWidget);

      // Tap 3D Clay Next button inside modal
      await tester.tap(find.byType(BubbleIconButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Modal is dismissed and callback executed
      expect(find.byType(LevelUpDialog), findsNothing);
      expect(continued, isTrue);
    });
  });
}
