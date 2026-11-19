import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_gradients.dart';

/// A pill-shaped segmented switch with a sliding gradient thumb.
class GlassSegmentedControl extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;
  final double height;

  const GlassSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.height = 48,
  }) : assert(labels.length >= 2);

  @override
  Widget build(BuildContext context) {
    final count = labels.length;

    return Container(
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.glassFillSubtle,
        borderRadius: AppRadii.pillAll,
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: AppDurations.medium,
            curve: Curves.easeOutBack,
            alignment: Alignment(-1 + 2 * selectedIndex / (count - 1), 0),
            child: FractionallySizedBox(
              widthFactor: 1 / count,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppGradients.electric,
                  borderRadius: AppRadii.pillAll,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.electricYellow.withValues(alpha: 0.35),
                      blurRadius: 14,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < count; i++)
                Expanded(
                  child: Semantics(
                    selected: i == selectedIndex,
                    button: true,
                    child: InkWell(
                      borderRadius: AppRadii.pillAll,
                      onTap: onChanged == null ? null : () => onChanged!(i),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: AppDurations.fast,
                          style: TextStyle(
                            color: i == selectedIndex
                                ? AppColors.textOnAccent
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                          child: Text(labels[i]),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
