import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocco/core/constants/app_assets.dart';
import 'package:mocco/core/tokens/app_colors.dart';
import 'package:mocco/presentation/widgets/map/map_node_button.dart';
import 'package:mocco/presentation/widgets/map/single_image_map_canvas.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SingleImageMapCanvas Widget Tests', () {
    testWidgets('renders single world map image and all 10 nodes', (tester) async {
      final nodes = List.generate(
        10,
        (i) => MapCanvasNodeData(
          id: i + 1,
          label: '${i + 1}',
          status: i < 2
              ? MapNodeStatus.completed
              : i == 2
                  ? MapNodeStatus.active
                  : MapNodeStatus.locked,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleImageMapCanvas(
              nodes: nodes,
              onNodeTap: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify all 10 nodes are present
      expect(find.byType(MapNodeButton), findsNWidgets(10));

      // Verify single world map image rendered
      expect(
        find.image(const AssetImage(AppAssets.worldMapSingle)),
        findsOneWidget,
      );

      // Verify Mascot badge is displayed next to active node
      expect(find.text('Ayo!'), findsOneWidget);
    });

    testWidgets('triggers onNodeTap when tapping active or completed node', (tester) async {
      int? tappedIndex;

      final nodes = [
        const MapCanvasNodeData(
          id: 1,
          label: '1',
          status: MapNodeStatus.completed,
          primaryColor: AppColors.numberPrimary,
        ),
        const MapCanvasNodeData(
          id: 2,
          label: '2',
          status: MapNodeStatus.active,
          primaryColor: AppColors.numberPrimary,
        ),
        const MapCanvasNodeData(
          id: 3,
          label: '3',
          status: MapNodeStatus.locked,
          primaryColor: AppColors.numberPrimary,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleImageMapCanvas(
              nodes: nodes,
              onNodeTap: (idx) => tappedIndex = idx,
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap completed node (replay) - ensure visible first since it's on a tall map
      await tester.ensureVisible(find.text('1'));
      await tester.tap(find.text('1'));
      await tester.pump();
      expect(tappedIndex, equals(0));

      // Tap active node
      await tester.ensureVisible(find.text('2'));
      await tester.tap(find.text('2'));
      await tester.pump();
      expect(tappedIndex, equals(1));

      // Tap locked node (shows lock icon, should not trigger onNodeTap)
      tappedIndex = null;
      await tester.ensureVisible(find.byIcon(Icons.lock_rounded));
      await tester.tap(find.byIcon(Icons.lock_rounded));
      await tester.pump();
      expect(tappedIndex, isNull);
    });

    test('calculateActiveNodeScrollOffset calculates bottom-to-top scroll offset', () {
      // Level 1 (index 0) is at bottom (t=0), so offset should be near max scroll
      final offsetLevel1 = SingleImageMapCanvas.calculateActiveNodeScrollOffset(
        activeIndex: 0,
        totalNodes: 10,
        screenWidth: 400.0,
        screenHeight: 800.0,
      );

      // Level 10 (index 9) is at mountain peak (t=1), so offset should be near 0 (top)
      final offsetLevel10 = SingleImageMapCanvas.calculateActiveNodeScrollOffset(
        activeIndex: 9,
        totalNodes: 10,
        screenWidth: 400.0,
        screenHeight: 800.0,
      );

      expect(offsetLevel1, greaterThan(offsetLevel10));
    });

    test('calibrated44NodePositions contains 44 valid normalized points', () {
      expect(SingleImageMapCanvas.calibrated44NodePositions.length, equals(44));
      for (final p in SingleImageMapCanvas.calibrated44NodePositions) {
        expect(p.dx, inInclusiveRange(0.0, 1.0));
        expect(p.dy, inInclusiveRange(0.0, 1.0));
      }
    });

    test('getNodePoint returns calibrated positions for 44 nodes', () {
      // Check Node 4 (index 3) adjusted vertically
      final node4 = SingleImageMapCanvas.getNodePoint(3, 44);
      expect(node4.dy, equals(4130.0 / 4800.0));

      // Check Node 7 (index 6) adjusted vertically
      final node7 = SingleImageMapCanvas.getNodePoint(6, 44);
      expect(node7.dy, equals(3650.0 / 4800.0));

      // Check Node 44 / W8 (index 43) adjusted vertically
      final nodeW8 = SingleImageMapCanvas.getNodePoint(43, 44);
      expect(nodeW8.dy, equals(370.0 / 4800.0));

      // Check key letter nodes (Gg, Kk, Pp, Uu)
      final nodeG = SingleImageMapCanvas.getNodePoint(16, 44);
      expect(nodeG.dx, equals(513.4 / 896.0));
      final nodeK = SingleImageMapCanvas.getNodePoint(20, 44);
      expect(nodeK.dx, equals(512.2 / 896.0));
      final nodeP = SingleImageMapCanvas.getNodePoint(25, 44);
      expect(nodeP.dx, equals(448.2 / 896.0));
      final nodeU = SingleImageMapCanvas.getNodePoint(30, 44);
      expect(nodeU.dx, equals(322.6 / 896.0));
    });
  });
}
