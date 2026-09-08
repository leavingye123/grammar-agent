import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grammar_agent/core/widgets/grammar_tree_widgets.dart';
import 'package:grammar_agent/core/widgets/tree_layout.dart';
import 'package:grammar_agent/features/course/domain/grammar_tree.dart';

void main() {
  group('GrammarTreeLayoutTest', () {
    for (final count in [1, 3, 6, 12]) {
      test('$count node layout stays inside bounds without overlap', () {
        final result = GrammarTreeLayout.calculate(
          ids: List.generate(count, (index) => 'node-$index'),
          width: 320,
        );

        expect(result.nodes, hasLength(count));
        for (final node in result.nodes) {
          expect(node.rect.left, greaterThanOrEqualTo(0));
          expect(node.rect.right, lessThanOrEqualTo(result.size.width));
          expect(node.rect.top, greaterThanOrEqualTo(0));
          expect(node.rect.bottom, lessThanOrEqualTo(result.size.height));
        }
        for (var i = 0; i < result.nodes.length; i++) {
          for (var j = i + 1; j < result.nodes.length; j++) {
            expect(
              result.nodes[i].rect.overlaps(result.nodes[j].rect),
              isFalse,
              reason: '${result.nodes[i].id} overlaps ${result.nodes[j].id}',
            );
          }
        }

        // Curriculum order grows upward: the first foundation node is lower
        // than the final advanced node.
        if (count > 1) {
          expect(
            result.node('node-0')!.center.dy,
            greaterThan(result.node('node-${count - 1}')!.center.dy),
          );
        }
      });
    }

    test('explicit prerequisites are preserved as branch edges', () {
      final result = GrammarTreeLayout.calculate(
        ids: const ['foundation', 'present', 'past', 'mixed'],
        width: 320,
        prerequisites: const {
          'mixed': ['present', 'past'],
        },
      );
      expect(
        result.edges
            .where((edge) => edge.to == 'mixed')
            .map((edge) => edge.from),
        containsAll(['present', 'past']),
      );
    });

    testWidgets('branch tree with 12 points fits a 320px viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OrganicGrammarTree(
                locateCurrent: false,
                nodes: List.generate(
                  12,
                  (index) => TreeVisualNode(
                    id: '$index',
                    title: index == 3 ? '这是一个很长的语法知识点标题' : '知识点 $index',
                    progress: '$index/12',
                    icon: Icons.eco,
                    stage: index < 3 ? GrowthStage.mastered : GrowthStage.seed,
                    onTap: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GrammarNode), findsNWidgets(12));
      expect(tester.takeException(), isNull);
    });
  });
}
