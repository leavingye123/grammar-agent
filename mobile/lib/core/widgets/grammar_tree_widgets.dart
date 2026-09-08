import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../features/course/domain/grammar_tree.dart';
import '../theme/design_tokens.dart';
import 'grammar_cat.dart';
import 'tree_layout.dart';

class TreeVisualNode {
  const TreeVisualNode({
    required this.id,
    required this.title,
    required this.progress,
    required this.icon,
    required this.stage,
    required this.onTap,
    this.masteryScore,
    this.current = false,
    this.prerequisiteIds = const [],
    this.widgetKey,
  });

  final String id;
  final String title;
  final String progress;
  final IconData icon;
  final GrowthStage stage;
  final VoidCallback onTap;
  final int? masteryScore;
  final bool current;
  final List<String> prerequisiteIds;
  final Key? widgetKey;
}

/// A data-driven curriculum tree with foundation content at the bottom.
class OrganicGrammarTree extends StatefulWidget {
  const OrganicGrammarTree({
    super.key,
    required this.nodes,
    this.showCat = true,
    this.locateCurrent = true,
  });

  final List<TreeVisualNode> nodes;
  final bool showCat;
  final bool locateCurrent;

  @override
  State<OrganicGrammarTree> createState() => _OrganicGrammarTreeState();
}

class _OrganicGrammarTreeState extends State<OrganicGrammarTree> {
  final _currentAnchor = GlobalKey();
  bool _located = false;

  @override
  void didUpdateWidget(covariant OrganicGrammarTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nodes.map((node) => node.id).join() !=
        widget.nodes.map((node) => node.id).join()) {
      _located = false;
    }
  }

  void _locateCurrent() {
    if (_located || !widget.locateCurrent) return;
    _located = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _currentAnchor.currentContext;
      if (!mounted || context == null) return;
      Scrollable.ensureVisible(
        context,
        alignment: .52,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.nodes.any((node) => node.current)) _locateCurrent();
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final layout = GrammarTreeLayout.calculate(
          ids: widget.nodes.map((node) => node.id).toList(),
          width: width,
          prerequisites: {
            for (final node in widget.nodes)
              if (node.prerequisiteIds.isNotEmpty)
                node.id: node.prerequisiteIds,
          },
        );
        final dataById = {for (final node in widget.nodes) node.id: node};
        final currentId = widget.nodes
            .where((node) => node.current)
            .firstOrNull
            ?.id;
        return ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(34)),
          child: SizedBox(
            key: const Key('organic-grammar-tree'),
            width: layout.size.width,
            height: layout.size.height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: GrammarTreePainter(
                      layout: layout,
                      currentId: currentId,
                    ),
                  ),
                ),
                for (final positioned in layout.nodes)
                  Positioned(
                    left: positioned.position.dx,
                    top: positioned.position.dy,
                    width: positioned.size.width,
                    height: positioned.size.height,
                    child: KeyedSubtree(
                      key: positioned.id == currentId ? _currentAnchor : null,
                      child: GrammarNode(
                        key: dataById[positioned.id]!.widgetKey,
                        title: dataById[positioned.id]!.title,
                        subtitle: dataById[positioned.id]!.progress,
                        icon: dataById[positioned.id]!.icon,
                        stage: dataById[positioned.id]!.stage,
                        masteryScore: dataById[positioned.id]!.masteryScore,
                        current: dataById[positioned.id]!.current,
                        onTap: dataById[positioned.id]!.onTap,
                      ),
                    ),
                  ),
                if (widget.showCat && widget.nodes.isNotEmpty)
                  Positioned(
                    left: layout.size.width * .58,
                    bottom: 9,
                    child: const GrammarCat(size: 92),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class GrammarNode extends StatefulWidget {
  const GrammarNode({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.stage = GrowthStage.seed,
    this.onTap,
    this.masteryScore,
    this.current = false,
    this.preview = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final GrowthStage stage;
  final VoidCallback? onTap;
  final int? masteryScore;
  final bool current;

  /// Kept for source compatibility; curriculum trees no longer render preview
  /// nodes or “coming soon” content.
  final bool preview;

  @override
  State<GrammarNode> createState() => _GrammarNodeState();
}

class _GrammarNodeState extends State<GrammarNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath;
  var _pressed = false;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    if (widget.current) {
      _breath.forward().then((_) {
        if (mounted) _breath.reverse();
      });
    }
  }

  @override
  void didUpdateWidget(covariant GrammarNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.current && !oldWidget.current) {
      _breath.forward(from: 0).then((_) {
        if (mounted) _breath.reverse();
      });
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = !widget.preview && widget.onTap != null;
    final foreground = switch (widget.stage) {
      GrowthStage.mastered || GrowthStage.practicing => Colors.white,
      _ => AppColors.ink,
    };
    return Semantics(
      button: enabled,
      enabled: enabled,
      label: '${widget.title}，${widget.subtitle}，${widget.stage.label}',
      child: AnimatedBuilder(
        animation: _breath,
        builder: (context, child) => Transform.scale(
          scale: (_pressed ? .97 : 1) + (_breath.value * .025),
          child: child,
        ),
        child: GestureDetector(
          onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
          onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
          onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
          onTap: enabled ? widget.onTap : null,
          child: CustomPaint(
            painter: _GrammarNodePainter(
              stage: widget.stage,
              current: widget.current,
              masteryScore: widget.masteryScore,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 7),
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(
                    MediaQuery.textScalerOf(context).scale(1).clamp(1, 1.25),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.icon, size: 19, color: foreground),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            widget.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: foreground,
                                  fontSize: 14,
                                  height: 1.12,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: foreground.withValues(alpha: .16),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        widget.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 12,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GrammarNodePainter extends CustomPainter {
  const _GrammarNodePainter({
    required this.stage,
    required this.current,
    required this.masteryScore,
  });

  final GrowthStage stage;
  final bool current;
  final int? masteryScore;

  Path _blob(Size size) => Path()
    ..moveTo(size.width * .12, size.height * .66)
    ..quadraticBezierTo(
      0,
      size.height * .46,
      size.width * .14,
      size.height * .31,
    )
    ..quadraticBezierTo(
      size.width * .20,
      size.height * .08,
      size.width * .39,
      size.height * .15,
    )
    ..quadraticBezierTo(
      size.width * .53,
      0,
      size.width * .66,
      size.height * .16,
    )
    ..quadraticBezierTo(
      size.width * .91,
      size.height * .09,
      size.width * .88,
      size.height * .36,
    )
    ..quadraticBezierTo(
      size.width,
      size.height * .54,
      size.width * .86,
      size.height * .72,
    )
    ..quadraticBezierTo(
      size.width * .75,
      size.height,
      size.width * .52,
      size.height * .88,
    )
    ..quadraticBezierTo(
      size.width * .29,
      size.height,
      size.width * .12,
      size.height * .66,
    )
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    final path = _blob(size);
    final color = switch (stage) {
      GrowthStage.mastered => const Color(0xFF247A55),
      GrowthStage.practicing => const Color(0xFF42A969),
      GrowthStage.learning => const Color(0xFFDDF3BE),
      GrowthStage.dueForReview => const Color(0xFFFFE9B8),
      GrowthStage.seed => const Color(0xFFE8EFE7),
    };
    canvas.drawShadow(
      path,
      current ? const Color(0xFF76C83D) : const Color(0x40164D3B),
      current ? 13 : 6,
      true,
    );
    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color.lerp(color, Colors.white, .22)!, color],
      ).createShader(Offset.zero & size);
    canvas.drawPath(path, fill);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = current ? 3 : 1.4
        ..color = current
            ? const Color(0xFFB9ED58)
            : AppColors.primary.withValues(alpha: .18),
    );

    final showLeaf = stage == GrowthStage.mastered || (masteryScore ?? 0) >= 85;
    if (showLeaf) {
      final leaf = Path()
        ..moveTo(size.width * .74, 13)
        ..quadraticBezierTo(size.width * .92, 3, size.width * .88, 22)
        ..quadraticBezierTo(size.width * .77, 27, size.width * .74, 13)
        ..close();
      canvas.drawPath(leaf, Paint()..color = const Color(0xFFB7E36A));
    } else if (stage == GrowthStage.seed) {
      final p = Paint()
        ..color = const Color(0xFF789887)
        ..strokeWidth = 1.7
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(size.width * .78, 17),
        Offset(size.width * .78, 8),
        p,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * .82, 8),
          width: 10,
          height: 5,
        ),
        Paint()..color = const Color(0xFF9FBEA6),
      );
    }
  }

  @override
  bool shouldRepaint(_GrammarNodePainter oldDelegate) =>
      stage != oldDelegate.stage ||
      current != oldDelegate.current ||
      masteryScore != oldDelegate.masteryScore;
}

class GrammarTreePainter extends CustomPainter {
  const GrammarTreePainter({required this.layout, this.currentId});

  final TreeLayoutResult layout;
  final String? currentId;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF8FFF9), Color(0xFFE7F8ED), Color(0xFFF8F4DD)],
        stops: [0, .72, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);
    _paintQuietLeaves(canvas, size);
    _paintCanopies(canvas, size);

    final trunk = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [Color(0xFF816345), Color(0xFF9D8059), Color(0xFF6E8D4B)],
      ).createShader(Offset.zero & size);
    final baseX = size.width * .5;
    final bottom = size.height + 5;
    final top = layout.nodes.isEmpty
        ? size.height * .35
        : layout.nodes.map((node) => node.center.dy).reduce(math.min);
    final central = Path()
      ..moveTo(baseX, bottom)
      ..cubicTo(
        baseX - 18,
        size.height * .73,
        baseX + 17,
        size.height * .42,
        baseX - 3,
        math.max(20, top - 20),
      );
    trunk.strokeWidth = 18;
    canvas.drawPath(central, trunk);
    canvas.drawPath(
      central,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 5
        ..color = const Color(0x33FFF2C8),
    );

    if (layout.nodes.length == 1) {
      _paintYoungBranches(canvas, size, trunk);
    }

    for (final edge in layout.edges) {
      final lower = layout.node(edge.from);
      final upper = layout.node(edge.to);
      if (lower == null || upper == null) continue;
      final start = Offset(lower.center.dx, lower.rect.top + 8);
      final end = Offset(upper.center.dx, upper.rect.bottom - 8);
      final middleY = (start.dy + end.dy) / 2;
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
          start.dx + (baseX - start.dx) * .45,
          middleY + 22,
          end.dx + (baseX - end.dx) * .34,
          middleY - 18,
          end.dx,
          end.dy,
        );
      trunk.strokeWidth = 9;
      canvas.drawPath(path, trunk);
      _paintBranchLeaves(canvas, start, end);
    }

    // Join the youngest tree to its single real node.
    if (layout.nodes.length == 1) {
      final node = layout.nodes.single;
      final shoot = Path()
        ..moveTo(baseX, bottom)
        ..cubicTo(
          baseX - 8,
          node.rect.bottom + 40,
          baseX + 5,
          node.rect.bottom,
          node.center.dx,
          node.rect.bottom - 8,
        );
      trunk.strokeWidth = 11;
      canvas.drawPath(shoot, trunk);
      _paintBranchLeaves(
        canvas,
        Offset(baseX, node.rect.bottom + 58),
        node.center,
      );
    }

    _paintRootsAndGrass(canvas, size);
  }

  void _paintQuietLeaves(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x2377B96A);
    const positions = [
      Offset(.10, .13),
      Offset(.86, .08),
      Offset(.91, .38),
      Offset(.07, .55),
      Offset(.18, .80),
      Offset(.83, .71),
    ];
    for (var i = 0; i < positions.length; i++) {
      final center = Offset(
        positions[i].dx * size.width,
        positions[i].dy * size.height,
      );
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i.isEven ? -.5 : .5);
      canvas.drawOval(const Rect.fromLTWH(-10, -4, 20, 8), paint);
      canvas.restore();
    }
  }

  void _paintCanopies(Canvas canvas, Size size) {
    if (layout.nodes.isEmpty) return;
    final clusters = <Offset>[];
    for (final node in layout.nodes) {
      clusters.addAll([
        node.center + Offset(-node.size.width * .48, 5),
        node.center + Offset(node.size.width * .46, 9),
        node.center + const Offset(-24, -25),
        node.center + const Offset(27, -23),
      ]);
    }
    if (layout.nodes.length == 1) {
      final node = layout.nodes.single;
      clusters.addAll([
        Offset(size.width * .24, node.center.dy + 68),
        Offset(size.width * .76, node.center.dy + 70),
        Offset(size.width * .17, node.center.dy + 116),
        Offset(size.width * .83, node.center.dy + 124),
        Offset(size.width * .33, node.center.dy + 104),
        Offset(size.width * .67, node.center.dy + 112),
      ]);
    }
    for (var i = 0; i < clusters.length; i++) {
      final center = clusters[i];
      final radius = layout.nodes.length == 1 ? 36.0 + (i % 3) * 7 : 30.0;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFBCE89C).withValues(alpha: .62),
              const Color(0xFF78BD69).withValues(alpha: .22),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }
  }

  void _paintYoungBranches(Canvas canvas, Size size, Paint trunk) {
    final base = Offset(size.width * .5, size.height * .75);
    final tips = [
      Offset(size.width * .18, size.height * .53),
      Offset(size.width * .31, size.height * .39),
      Offset(size.width * .69, size.height * .42),
      Offset(size.width * .82, size.height * .56),
    ];
    for (final tip in tips) {
      final direction = tip.dx < base.dx ? -1.0 : 1.0;
      final branch = Path()
        ..moveTo(base.dx, base.dy)
        ..cubicTo(
          base.dx + 14 * direction,
          base.dy - 38,
          tip.dx - 18 * direction,
          tip.dy + 24,
          tip.dx,
          tip.dy,
        );
      trunk.strokeWidth = 7;
      canvas.drawPath(branch, trunk);
      final leafPaint = Paint()..color = const Color(0xFF75B85B);
      canvas.save();
      canvas.translate(tip.dx, tip.dy);
      canvas.rotate(direction * .45);
      canvas.drawOval(const Rect.fromLTWH(-12, -6, 24, 12), leafPaint);
      canvas.restore();
    }
  }

  void _paintBranchLeaves(Canvas canvas, Offset start, Offset end) {
    final p = Paint()..color = const Color(0xFF86B95C);
    final center = Offset.lerp(start, end, .52)!;
    final direction = end.dx >= start.dx ? 1.0 : -1.0;
    canvas.save();
    canvas.translate(center.dx + 8 * direction, center.dy);
    canvas.rotate(direction * -.55);
    canvas.drawOval(const Rect.fromLTWH(-8, -4, 16, 8), p);
    canvas.restore();
  }

  void _paintRootsAndGrass(Canvas canvas, Size size) {
    final grass = Paint()..color = const Color(0xFFB5D78A);
    final groundY = size.height - 8;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, groundY),
        width: size.width * .88,
        height: 27,
      ),
      Paint()..color = const Color(0xFFDCE9B7),
    );
    for (var i = 0; i < 18; i++) {
      final x = 18 + i * (size.width - 36) / 17;
      final h = 5.0 + (i % 3) * 3;
      canvas.drawPath(
        Path()
          ..moveTo(x, groundY)
          ..quadraticBezierTo(x - 3, groundY - h, x + 1, groundY - h - 3)
          ..quadraticBezierTo(x + 4, groundY - h, x, groundY),
        grass,
      );
    }
  }

  @override
  bool shouldRepaint(GrammarTreePainter oldDelegate) =>
      layout != oldDelegate.layout || currentId != oldDelegate.currentId;
}
