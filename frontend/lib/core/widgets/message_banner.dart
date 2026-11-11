import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import 'glass_container.dart';

enum MessageTone { error, success, info }

/// Inline status message on a tinted glass strip — replaces the ad-hoc
/// red boxes each screen used to build for itself.
class MessageBanner extends StatelessWidget {
  final String message;
  final MessageTone tone;

  const MessageBanner({
    super.key,
    required this.message,
    this.tone = MessageTone.error,
  });

  const MessageBanner.error(this.message, {super.key})
    : tone = MessageTone.error;

  const MessageBanner.success(this.message, {super.key})
    : tone = MessageTone.success;

  const MessageBanner.info(this.message, {super.key}) : tone = MessageTone.info;

  (Color, IconData) get _style => switch (tone) {
    MessageTone.error => (AppColors.danger, Icons.error_outline_rounded),
    MessageTone.success => (AppColors.success, Icons.check_circle_rounded),
    MessageTone.info => (AppColors.skyCyan, Icons.info_outline_rounded),
  };

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _style;

    return Semantics(
      liveRegion: true,
      child: GlassContainer(
        blur: 0,
        borderRadius: AppRadii.mdAll,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 4,
        ),
        borderColor: color.withValues(alpha: 0.55),
        shadows: const [],
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.22),
            color.withValues(alpha: 0.08),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: AppSpacing.sm + 4),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
