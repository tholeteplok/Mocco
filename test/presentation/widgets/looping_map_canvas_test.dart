import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocco/core/tokens/app_colors.dart';
import 'package:mocco/presentation/widgets/map/looping_map_canvas.dart';
import 'package:mocco/presentation/widgets/map/map_node_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoopingMapCanvas Widget Tests', () {
    testWidgets('renders correct number of tiles based on node count', (tester) async {
      // 14 nodes should create ceil(14 / 6) = 3 tiles
      final nodes = List.generate(
        14,
        (i) => MapCanvasNodeData(
          id: i + 1,
          label: '${i + 1}',
          status: i == 0
              ? MapNodeStatus.completed
              : i == 1
                  ? MapNodeStatus.active
                  : MapNodeStatus.locked,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoopingMapCanvas(
              nodes: nodes,
              onNodeTap: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify all 14 nodes are present
      expect(find.byType(MapNodeButton), findsNWidgets(14));

      // Verify background canvas tiles rendered (3 tiles)
      expect(
        find.image(const AssetImage('assets/images/ui/map_canvas_loop.png')),
        findsNWidgets(3),
      );
    });

    testWidgets('triggers onNodeTap when tapping completed node (replay feature)', (tester) async {
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
            body: LoopingMapCanvas(
              nodes: nodes,
              onNodeTap: (index) {
                tappedIndex = index;
              },
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap completed node (node 0 / label '1')
      await tester.tap(find.text('1'));
      await tester.pump();

      expect(tappedIndex, equals(0));
    });

    testWidgets('triggers onNodeTap when tapping active node', (tester) async {
      int? tappedIndex;

      final nodes = [
        const MapCanvasNodeData(
          id: 1,
          label: '1',
          status: MapNodeStatus.completed,
        ),
        const MapCanvasNodeData(
          id: 2,
          label: '2',
          status: MapNodeStatus.active,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoopingMapCanvas(
              nodes: nodes,
              onNodeTap: (index) {
                tappedIndex = index;
              },
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap active node (node 1 / label '2')
      await tester.tap(find.text('2'));
      await tester.pump();

      expect(tappedIndex, equals(1));
    });

    testWidgets('does not trigger onNodeTap when tapping locked node', (tester) async {
      int? tappedIndex;

      final nodes = [
        const MapCanvasNodeData(
          id: 1,
          label: '1',
          status: MapNodeStatus.active,
        ),
        const MapCanvasNodeData(
          id: 2,
          label: '2',
          status: MapNodeStatus.locked,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoopingMapCanvas(
              nodes: nodes,
              onNodeTap: (index) {
                tappedIndex = index;
              },
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap locked node (node 1 / second node)
      await tester.tap(find.byType(MapNodeButton).at(1));
      await tester.pump();

      expect(tappedIndex, isNull);
    });

    testWidgets('positions nodes at different horizontal offsets along turns', (tester) async {
      final nodes = List.generate(
        4,
        (i) => MapCanvasNodeData(
          id: i + 1,
          label: '${i + 1}',
          status: MapNodeStatus.completed,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoopingMapCanvas(
              nodes: nodes,
              onNodeTap: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      // Check the centers of node 1 (turn 0: right 0.650) and node 2 (turn 1: left 0.345)
      final pos1 = tester.getCenter(find.text('1'));
      final pos2 = tester.getCenter(find.text('2'));

      // Node 1 should be to the right of node 2
      expect(pos1.dx, greaterThan(pos2.dx));
      // Node 2 should be below node 1 vertically
      expect(pos2.dy, greaterThan(pos1.dy));
    });
  });
}
