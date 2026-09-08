import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// GrammarAgent's reusable, locally bundled learning companion.
class GrammarCat extends StatelessWidget {
  const GrammarCat({super.key, this.size = 64, this.celebrating = false});

  final double size;
  final bool celebrating;

  @override
  Widget build(BuildContext context) => Semantics(
    label: celebrating ? 'Grammar Cat 为你庆祝' : 'Grammar Cat 学习伙伴',
    image: true,
    child: SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/grammar_cat.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          if (celebrating) ...[
            Positioned(
              left: 0,
              top: 2,
              child: Icon(
                Icons.auto_awesome,
                color: AppColors.yellow,
                size: size * .22,
              ),
            ),
            Positioned(
              right: -2,
              top: size * .2,
              child: Icon(
                Icons.eco,
                color: AppColors.primary,
                size: size * .18,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
