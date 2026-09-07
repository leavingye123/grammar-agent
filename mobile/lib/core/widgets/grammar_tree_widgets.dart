import 'package:flutter/material.dart';

import '../../features/course/domain/grammar_tree.dart';
import '../theme/design_tokens.dart';

class GrammarNode extends StatelessWidget {
  const GrammarNode({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.stage = GrowthStage.seed,
    this.onTap,
    this.preview = false,
  });
  final String title, subtitle;
  final IconData icon;
  final GrowthStage stage;
  final VoidCallback? onTap;
  final bool preview;
  @override
  Widget build(BuildContext context) {
    final active =
        !preview &&
        (stage == GrowthStage.mastered || stage == GrowthStage.practicing);
    final color = preview
        ? AppColors.surfaceGreen
        : switch (stage) {
            GrowthStage.mastered => AppColors.deepGreen,
            GrowthStage.practicing => AppColors.primary,
            GrowthStage.learning => AppColors.softGreen,
            GrowthStage.dueForReview => AppColors.softOrange,
            GrowthStage.seed => AppColors.mint,
          };
    return Semantics(
      button: !preview,
      enabled: !preview,
      child: AnimatedContainer(
        duration: AppMotion.duration(context),
        decoration: BoxDecoration(
          color: color,
          borderRadius: AppRadius.node,
          border: Border.all(
            color: preview
                ? AppColors.border
                : AppColors.primary.withValues(alpha: .25),
            width: 1.5,
          ),
          boxShadow: preview ? [] : AppShadows.soft,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppRadius.node,
            onTap: preview ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: active ? AppColors.softGreen : AppColors.primary,
                    size: 26,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: active ? Colors.white : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    preview ? '即将推出' : subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: active ? Colors.white : AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Each row measures its children. Branches grow with text instead of relying
/// on fixed canvas coordinates that clip translated or enlarged labels.
class TreeRow extends StatelessWidget {
  const TreeRow({super.key, required this.left, this.right, this.root = false});
  final Widget left;
  final Widget? right;
  final bool root;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final stacked =
          constraints.maxWidth < 300 ||
          MediaQuery.textScalerOf(context).scale(14) > 21;
      return CustomPaint(
        painter: _BranchPainter(paired: right != null && !stacked, root: root),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: right == null || stacked
              ? Column(
                  children: [
                    FractionallySizedBox(
                      widthFactor: stacked ? .85 : .64,
                      child: left,
                    ),
                    if (right != null) ...[
                      const SizedBox(height: 28),
                      FractionallySizedBox(widthFactor: .85, child: right),
                    ],
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: left),
                    const SizedBox(width: 44),
                    Expanded(child: right!),
                  ],
                ),
        ),
      );
    },
  );
}

class _BranchPainter extends CustomPainter {
  _BranchPainter({required this.paired, required this.root});
  final bool paired, root;
  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    final p = Paint()
      ..color = const Color(0xFFB4C6A4)
      ..strokeWidth = root ? 9 : 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(x, size.height)
        ..cubicTo(x - 12, size.height * .7, x + 8, size.height * .3, x, 0),
      p,
    );
    if (paired) {
      p.strokeWidth = 4;
      canvas.drawPath(
        Path()
          ..moveTo(x, size.height * .8)
          ..quadraticBezierTo(
            x,
            size.height * .5,
            size.width * .2,
            size.height * .5,
          )
          ..moveTo(x, size.height * .8)
          ..quadraticBezierTo(
            x,
            size.height * .5,
            size.width * .8,
            size.height * .5,
          ),
        p,
      );
    }
    p
      ..style = PaintingStyle.fill
      ..color = AppColors.softGreen;
    canvas.drawPath(
      Path()
        ..moveTo(x + 2, 17)
        ..quadraticBezierTo(x + 24, 18, x + 18, 1)
        ..quadraticBezierTo(x + 3, 2, x + 2, 17),
      p,
    );
  }

  @override
  bool shouldRepaint(_BranchPainter oldDelegate) =>
      paired != oldDelegate.paired || root != oldDelegate.root;
}
