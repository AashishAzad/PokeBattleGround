import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'pressable_scale.dart';

/// Circular frosted icon button for app bar / header actions.
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final double size;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: PressableScale(
        onTap: onPressed,
        semanticLabel: tooltip,
        borderRadius: BorderRadius.circular(size),
        pressedScale: 0.9,
        hoverScale: 1.08,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.glassFill,
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: size * 0.48),
        ),
      ),
    );
  }
}
