import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';
import 'grammar_cat.dart';

class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => GardenBackdrop(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: AppSpacing.page,
          physics: const AlwaysScrollableScrollPhysics(),
          children: children,
        ),
      ),
    ),
  );
}

/// Restrained cream/mint atmosphere shared by the existing product screens.
/// Decorative leaves stay deliberately faint so the UI remains primary.
class GardenBackdrop extends StatelessWidget {
  const GardenBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFEF7), Color(0xFFF2FBF4), Color(0xFFFAFCF4)],
      ),
    ),
    child: CustomPaint(painter: _QuietGardenPainter(), child: child),
  );
}

class _QuietGardenPainter extends CustomPainter {
  const _QuietGardenPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x1477B96A);
    final leaves = [
      Offset(size.width * .06, 80),
      Offset(size.width * .92, 155),
      Offset(size.width * .08, size.height * .72),
      Offset(size.width * .88, size.height * .84),
    ];
    for (var i = 0; i < leaves.length; i++) {
      canvas.save();
      canvas.translate(leaves[i].dx, leaves[i].dy);
      canvas.rotate(i.isEven ? -.55 : .55);
      canvas.drawOval(const Rect.fromLTWH(-24, -9, 48, 18), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_QuietGardenPainter oldDelegate) => false;
}

class GrammarCard extends StatelessWidget {
  const GrammarCard({
    super.key,
    required this.child,
    this.color = AppColors.surface,
  });
  final Widget child;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    padding: const EdgeInsets.all(AppSpacing.lg),
    decoration: BoxDecoration(
      color: color,
      borderRadius: AppRadius.card,
      border: Border.all(color: AppColors.border),
      boxShadow: AppShadows.soft,
    ),
    child: child,
  );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.subtitle});
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.sm),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (subtitle != null)
          Text(
            subtitle!,
            style: const TextStyle(color: AppColors.secondaryText),
          ),
      ],
    ),
  );
}

class CatMessage extends StatelessWidget {
  const CatMessage(this.message, {super.key, this.celebrating = false});
  final String message;
  final bool celebrating;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
    child: Row(
      children: [
        GrammarCat(size: 56, celebrating: celebrating),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: AppColors.deepGreen, height: 1.6),
          ),
        ),
      ],
    ),
  );
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon = Icons.eco_outlined,
  });
  final String label, value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => GrammarCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: AppSpacing.sm),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}

class StatGrid extends StatelessWidget {
  const StatGrid({super.key, required this.items});
  final List<StatCard> items;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns =
          constraints.maxWidth < 340 ||
              MediaQuery.textScalerOf(context).scale(14) > 20
          ? 2
          : 3;
      return Wrap(
        spacing: AppSpacing.sm,
        children: [
          for (final item in items)
            SizedBox(
              width:
                  (constraints.maxWidth - (columns - 1) * AppSpacing.sm) /
                  columns,
              child: item,
            ),
        ],
      );
    },
  );
}

class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.title,
    required this.value,
    required this.fraction,
    this.caption,
  });
  final String title, value;
  final double fraction;
  final String? caption;
  @override
  Widget build(BuildContext context) => GrammarCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.md),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: fraction.clamp(0, 1)),
          duration: AppMotion.duration(context),
          builder: (_, value, _) => LinearProgressIndicator(value: value),
        ),
        if (caption != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(caption!),
          ),
      ],
    ),
  );
}

class FutureFeature extends StatelessWidget {
  const FutureFeature({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.auto_awesome_outlined,
  });
  final String title, description;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Semantics(
    enabled: false,
    child: GrammarCard(
      color: AppColors.surfaceGreen,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.secondaryText),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title · 即将推出',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: const TextStyle(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.status,
    this.showStatus = true,
  });
  final String title, subtitle;
  final String? status;
  final bool showStatus;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.all(AppSpacing.lg),
      leading: Icon(
        status == 'COMPLETED' ? Icons.check_circle : Icons.play_circle_outline,
        color: AppColors.primary,
      ),
      title: Text(title),
      subtitle: Text(
        showStatus ? '$subtitle\n${lessonStatusLabel(status)}' : subtitle,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}

String lessonStatusLabel(String? status) => switch (status) {
  'COMPLETED' => '已完成',
  'IN_PROGRESS' => '进行中',
  _ => '未开始',
};

String languageLabel(String code) => switch (code.toLowerCase()) {
  'en' => '英语',
  'ja' => '日语',
  'ko' => '韩语',
  'de' => '德语',
  _ => code,
};
