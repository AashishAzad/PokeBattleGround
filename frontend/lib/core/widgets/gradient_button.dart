import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/app_gradients.dart';
import 'poke_ball.dart';
import 'pressable_scale.dart';

/// The app's primary call-to-action: a glowing gradient button with press
/// feedback. Disabled when [onPressed] is null; shows a Poké Ball loader
/// in place of the label while [isLoading].
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final LinearGradient gradient;
  final Color foregroundColor;
  final bool isLoading;
  final double height;
  final double fontSize;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.gradient = AppGradients.pokeBall,
    this.foregroundColor = Colors.white,
    this.isLoading = false,
    this.height = 56,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final glow = gradient.colors.first;

    return AnimatedOpacity(
      duration: AppDurations.fast,
      opacity: enabled || isLoading ? 1 : 0.45,
      child: PressableScale(
        onTap: enabled ? onPressed : null,
        borderRadius: AppRadii.mdAll,
        semanticLabel: label,
        child: AnimatedContainer(
          duration: AppDurations.medium,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: AppRadii.mdAll,
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: glow.withValues(alpha: enabled ? 0.45 : 0.0),
                blurRadius: 22,
                offset: const Offset(0, 10),
                spreadRadius: -6,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: isLoading
              ? PokeBallLoader(size: height * 0.5)
              : ExcludeSemantics(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: foregroundColor, size: fontSize + 6),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: foregroundColor,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
