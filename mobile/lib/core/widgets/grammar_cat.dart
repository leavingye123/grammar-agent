import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// A lightweight vector mascot, independent of emoji fonts and network assets.
class GrammarCat extends StatelessWidget {
  const GrammarCat({super.key, this.size = 64, this.celebrating = false});
  final double size;
  final bool celebrating;
  @override
  Widget build(BuildContext context) => Semantics(
    label: celebrating ? 'Grammar Cat 为你庆祝' : 'Grammar Cat 学习伙伴',
    image: true,
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _CatPainter(celebrating)),
    ),
  );
}

class _CatPainter extends CustomPainter {
  _CatPainter(this.happy);
  final bool happy;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    final p = Paint()..color = AppColors.mint;
    canvas.drawCircle(const Offset(50, 50), 49, p);
    p.color = const Color(0xFF8A978E);
    canvas.drawPath(
      Path()
        ..moveTo(18, 47)
        ..lineTo(16, 10)
        ..quadraticBezierTo(35, 14, 42, 31)
        ..close(),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(61, 30)
        ..quadraticBezierTo(78, 9, 86, 12)
        ..lineTo(83, 51)
        ..close(),
      p,
    );
    p.color = const Color(0xFFEAB9AE);
    canvas.drawPath(
      Path()
        ..moveTo(22, 34)
        ..lineTo(21, 19)
        ..lineTo(35, 31)
        ..close(),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(69, 32)
        ..lineTo(80, 20)
        ..lineTo(79, 39)
        ..close(),
      p,
    );
    p.color = const Color(0xFF8A978E);
    canvas.drawOval(const Rect.fromLTWH(12, 28, 78, 58), p);
    p.color = const Color(0xFFFFFBF2);
    canvas.drawOval(const Rect.fromLTWH(23, 47, 58, 38), p);
    canvas.drawPath(
      Path()
        ..moveTo(50, 32)
        ..lineTo(65, 64)
        ..lineTo(37, 63)
        ..close(),
      p,
    );
    p.color = AppColors.ink;
    if (happy) {
      p
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(
        Path()
          ..moveTo(28, 54)
          ..quadraticBezierTo(35, 45, 42, 54),
        p,
      );
      canvas.drawPath(
        Path()
          ..moveTo(60, 54)
          ..quadraticBezierTo(67, 45, 74, 54),
        p,
      );
      p.style = PaintingStyle.fill;
    } else {
      canvas.drawOval(const Rect.fromLTWH(29, 46, 12, 16), p);
      canvas.drawOval(const Rect.fromLTWH(62, 46, 12, 16), p);
      p.color = Colors.white;
      canvas.drawCircle(const Offset(33, 50), 3, p);
      canvas.drawCircle(const Offset(66, 50), 3, p);
    }
    p.color = const Color(0xFFD18E87);
    canvas.drawPath(
      Path()
        ..moveTo(46, 64)
        ..lineTo(56, 64)
        ..lineTo(51, 69)
        ..close(),
      p,
    );
    p
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(
      Path()
        ..moveTo(51, 69)
        ..quadraticBezierTo(46, 77, 42, 70)
        ..moveTo(51, 69)
        ..quadraticBezierTo(56, 77, 60, 70),
      p,
    );
    for (final y in [62.0, 68.0]) {
      canvas.drawLine(Offset(7, y - 3), Offset(27, y), p);
      canvas.drawLine(Offset(77, y), Offset(95, y - 3), p);
    }
    p
      ..style = PaintingStyle.fill
      ..color = AppColors.primary;
    canvas.drawPath(
      Path()
        ..moveTo(30, 82)
        ..lineTo(72, 82)
        ..lineTo(51, 98)
        ..close(),
      p,
    );
    p.color = AppColors.softGreen;
    canvas.drawOval(const Rect.fromLTWH(48, 86, 9, 5), p);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CatPainter oldDelegate) => happy != oldDelegate.happy;
}
