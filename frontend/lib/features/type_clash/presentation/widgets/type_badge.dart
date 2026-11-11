import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../../../core/widgets/widgets.dart';
import 'type_colors.dart';

/// A circular, glowing Pokémon-type token: type color, type icon and name,
/// plus an optional owner line. Used by both the single-player type picker
/// and the multiplayer type-claiming view.
class TypeBadge extends StatelessWidget {
  final String type;
  final String? caption;
  final bool selected;
  final bool dimmed;
  final VoidCallback? onTap;
  final double size;

  const TypeBadge({
    super.key,
    required this.type,
    this.caption,
    this.selected = false,
    this.dimmed = false,
    this.onTap,
    this.size = 96,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.leafGreen
        : dimmed
        ? Colors.grey
        : colorForType(type);

    return Opacity(
      opacity: dimmed ? 0.5 : 1,
      child: PressableScale(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size),
        pressedScale: 0.9,
        hoverScale: 1.08,
        semanticLabel: [
          type.capitalized,
          ?caption,
        ].join(', '),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.3, -0.4),
              colors: [
                Color.lerp(color, Colors.white, 0.35)!,
                color,
                Color.lerp(color, Colors.black, 0.25)!,
              ],
              stops: const [0, 0.55, 1],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: selected ? 0.95 : 0.4),
              width: selected ? 3 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: dimmed ? 0 : 0.5),
                blurRadius: selected ? 26 : 16,
                spreadRadius: selected ? 2 : -2,
              ),
            ],
          ),
          child: ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    iconForType(type),
                    color: Colors.white,
                    size: size * 0.28,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    type.capitalized,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
                    ),
                  ),
                  if (caption != null)
                    Text(
                      caption!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
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
