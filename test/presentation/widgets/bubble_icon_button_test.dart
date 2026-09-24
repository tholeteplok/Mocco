import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocco/core/constants/app_assets.dart';
import 'package:mocco/presentation/widgets/buttons/bubble_icon_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BubbleIconButton 3D Clay Widget Tests', () {
    testWidgets('renders back button asset and triggers callback without container framing', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: BubbleIconButton.back(
                onPressed: () => tapped = true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify normal back button image rendered
      expect(find.image(const AssetImage(AppAssets.btnBack)), findsOneWidget);

      // Verify no artificial BoxDecoration is present
      expect(find.byType(Container), findsNothing);

      // Tap button and verify callback
      await tester.tap(find.byType(BubbleIconButton));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('renders sound button assets correctly according to isMuted state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                BubbleIconButton.sound(
                  isMuted: false,
                  onPressed: () {},
                ),
                BubbleIconButton.sound(
                  isMuted: true,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.image(const AssetImage(AppAssets.btnSoundOn)), findsOneWidget);
      expect(find.image(const AssetImage(AppAssets.btnSoundOff)), findsOneWidget);
    });

    testWidgets('renders parents, play, voice, and replay assets via named constructors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                BubbleIconButton.parents(onPressed: () {}),
                BubbleIconButton.play(onPressed: () {}),
                BubbleIconButton.voice(onPressed: () {}),
                BubbleIconButton.replay(onPressed: () {}),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.image(const AssetImage(AppAssets.btnParents)), findsOneWidget);
      expect(find.image(const AssetImage(AppAssets.btnPlay)), findsOneWidget);
      expect(find.image(const AssetImage(AppAssets.btnVoice)), findsOneWidget);
      expect(find.image(const AssetImage(AppAssets.btnReplay)), findsOneWidget);
    });

    testWidgets('smart auto-mapping converts legacy IconData to appropriate 3D clay asset', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BubbleIconButton(
              icon: Icons.arrow_back_rounded,
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.image(const AssetImage(AppAssets.btnBack)), findsOneWidget);
    });
  });
}
