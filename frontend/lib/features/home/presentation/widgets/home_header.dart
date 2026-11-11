import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';

/// Top bar of the Home screen: logo + wordmark, the signed-in trainer, and
/// a log-out action.
class HomeHeader extends StatelessWidget {
  final String? username;
  final VoidCallback onLogout;

  const HomeHeader({super.key, required this.username, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    // On narrow phones only the avatar is shown, so the row never overflows.
    final showName = MediaQuery.sizeOf(context).width >= 480;

    return Row(
      children: [
        const PokeBall(size: 34),
        const SizedBox(width: AppSpacing.sm + 2),
        const Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: BrandTitle(fontSize: 22, textAlign: TextAlign.left),
          ),
        ),
        const Spacer(),
        if (username != null) ...[
          _TrainerChip(username: username!, showName: showName),
          const SizedBox(width: AppSpacing.sm),
        ],
        GlassIconButton(
          icon: Icons.logout_rounded,
          tooltip: 'Log out',
          onPressed: onLogout,
        ),
      ],
    );
  }
}

class _TrainerChip extends StatelessWidget {
  final String username;
  final bool showName;

  const _TrainerChip({required this.username, required this.showName});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Signed in as $username',
      child: ExcludeSemantics(
        child: Container(
          padding: EdgeInsets.fromLTRB(4, 4, showName ? 14 : 4, 4),
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: AppRadii.pillAll,
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.electricYellow, AppColors.sunsetOrange],
                  ),
                ),
                child: Text(
                  username.isEmpty ? '?' : username[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textOnAccent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (showName) ...[
                const SizedBox(width: AppSpacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: Text(
                    username,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
