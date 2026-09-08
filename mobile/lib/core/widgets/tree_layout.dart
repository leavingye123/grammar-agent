import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class TreeLayoutNode {
  const TreeLayoutNode({
    required this.id,
    required this.position,
    required this.size,
    required this.row,
  });

  final String id;
  final Offset position;
  final Size size;
  final int row;

  Rect get rect => position & size;
  Offset get center => rect.center;
}

class TreeLayoutEdge {
  const TreeLayoutEdge({required this.from, required this.to});

  /// The lower (earlier) node and the upper (later) node.
  final String from;
  final String to;
}

class TreeLayoutResult {
  const TreeLayoutResult({
    required this.size,
    required this.nodes,
    required this.edges,
  });

  final Size size;
  final List<TreeLayoutNode> nodes;
  final List<TreeLayoutEdge> edges;

  TreeLayoutNode? node(String id) {
    for (final node in nodes) {
      if (node.id == id) return node;
    }
    return null;
  }
}

/// Computes a compact bottom-to-top tree from ordered curriculum data.
///
/// [ids] are foundation-first. This algorithm deliberately knows nothing
/// about grammar topics. Explicit prerequisite edges are accepted for future
/// API data; adjacent rows are connected when that data is not available.
abstract final class GrammarTreeLayout {
  static TreeLayoutResult calculate({
    required List<String> ids,
    required double width,
    Map<String, List<String>> prerequisites = const {},
  }) {
    final safeWidth = math.max(240.0, width);
    if (ids.isEmpty) {
      return TreeLayoutResult(
        size: Size(safeWidth, 260),
        nodes: const [],
        edges: const [],
      );
    }

    final nodeWidth = (safeWidth * .35).clamp(112.0, 148.0).toDouble();
    const nodeHeight = 88.0;
    const rowGap = 120.0;
    const topPadding = 48.0;
    const bottomPadding = 116.0;

    // Alternating 1 / 2 nodes reads as a branching tree and keeps four to six
    // nodes visible on an ordinary phone viewport.
    final rows = <List<String>>[];
    var cursor = 0;
    var takeTwo = false;
    while (cursor < ids.length) {
      final count = takeTwo && cursor + 1 < ids.length ? 2 : 1;
      rows.add(ids.sublist(cursor, cursor + count));
      cursor += count;
      takeTwo = !takeTwo;
    }

    final height = math.max(
      350.0,
      topPadding + bottomPadding + (rows.length - 1) * rowGap + nodeHeight,
    );
    final nodes = <TreeLayoutNode>[];
    for (var visualRow = 0; visualRow < rows.length; visualRow++) {
      final sourceRow = rows.length - 1 - visualRow;
      final row = rows[sourceRow];
      final y = topPadding + visualRow * rowGap;
      for (var column = 0; column < row.length; column++) {
        final centerX = row.length == 1
            ? safeWidth / 2
            : safeWidth * (column == 0 ? .27 : .73);
        nodes.add(
          TreeLayoutNode(
            id: row[column],
            position: Offset(centerX - nodeWidth / 2, y),
            size: Size(nodeWidth, nodeHeight),
            row: sourceRow,
          ),
        );
      }
    }

    final byId = {for (final node in nodes) node.id: node};
    final edges = <TreeLayoutEdge>[];
    for (final upper in nodes) {
      final explicit = prerequisites[upper.id]
          ?.where(byId.containsKey)
          .toList(growable: false);
      if (explicit != null && explicit.isNotEmpty) {
        edges.addAll(
          explicit.map(
            (lowerId) => TreeLayoutEdge(from: lowerId, to: upper.id),
          ),
        );
        continue;
      }
      if (upper.row == 0) continue;
      final lowerCandidates = nodes.where((node) => node.row == upper.row - 1);
      if (lowerCandidates.isEmpty) continue;
      final lower = lowerCandidates.reduce(
        (a, b) =>
            (a.center.dx - upper.center.dx).abs() <
                (b.center.dx - upper.center.dx).abs()
            ? a
            : b,
      );
      edges.add(TreeLayoutEdge(from: lower.id, to: upper.id));
    }

    return TreeLayoutResult(
      size: Size(safeWidth, height),
      nodes: nodes,
      edges: edges,
    );
  }
}
