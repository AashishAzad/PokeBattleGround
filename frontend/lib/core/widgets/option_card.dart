import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import 'glass_container.dart';
import 'pressable_scale.dart';

/// A tappable glass card with an accent-colored icon, title and subtitle.
/// Used for any "choose one" step (game mode, difficulty, …).
class OptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double width;

  /// Minimum height, chosen to fit a title plus a two-line subtitle, so
  /// sibling cards line up whether their subtitle wraps or not. It's a
  /// minimum rather than a fixed height so the card can still grow (e.g.
  /// with a larger system text size) instead of overflowing.
  final double minHeight;

  const OptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.width = 280,
    this.minHeight = 108,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: PressableScale(
        onTap: onTap,
        borderRadius: AppRadii.lgAll,
        semanticLabel: '$title. $subtitle',
        child: GlassContainer(
          constraints: BoxConstraints(minHeight: minHeight),
          blur: 0,
          borderColor: color.withValues(alpha: 0.6),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withValues(alpha: 0.3), AppColors.glassFillSubtle],
          ),
          shadows: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 10),
              spreadRadius: -8,
            ),
          ],
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.25),
                  border: Border.all(color: color.withValues(alpha: 0.7)),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
