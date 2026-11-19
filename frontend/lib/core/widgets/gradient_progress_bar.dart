import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_gradients.dart';

/// A rounded, glowing progress bar on a glass track. [value] is 0..1 and
/// animates smoothly between updates.
class GradientProgressBar extends StatelessWidget {
  final double value;
  final LinearGradient gradient;
  final double height;
  final Duration duration;

  const GradientProgressBar({
    super.key,
    required this.value,
    this.gradient = AppGradients.electric,
    this.height = 10,
    this.duration = AppDurations.medium,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(height);

    return Semantics(
      value: '${(value.clamp(0.0, 1.0) * 100).round()}%',
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          borderRadius: radius,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) => Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: duration,
              curve: Curves.easeOutCubic,
              width: constraints.maxWidth * value.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: radius,
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.last.withValues(alpha: 0.5),
                    blurRadius: 10,
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
