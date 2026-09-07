import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

class OptionCard extends StatelessWidget {
  const OptionCard({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.multiple = false,
  });
  final String label;
  final bool selected, multiple;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: AnimatedContainer(
      duration: AppMotion.duration(context),
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: selected ? AppColors.mint : AppColors.surface,
        borderRadius: AppRadius.small,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.small,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Icon(
                  selected
                      ? (multiple ? Icons.check_box : Icons.check_circle)
                      : (multiple
                            ? Icons.check_box_outline_blank
                            : Icons.radio_button_unchecked),
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(label)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
