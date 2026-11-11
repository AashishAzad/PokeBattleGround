import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../leaderboard/presentation/screens/leaderboard_screen.dart';
import '../models/game_mode.dart';
import '../widgets/game_mode_card.dart';
import '../widgets/home_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _maxContentWidth = 1100.0;
  static const _staggerStep = Duration(milliseconds: 90);

  void _open(BuildContext context, WidgetBuilder builder) {
    Navigator.of(context).push(MaterialPageRoute(builder: builder));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.watch(
      authNotifierProvider.select((s) => s.user?.username),
    );
    final textTheme = Theme.of(context).textTheme;

    return GlassScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md + 4,
          AppSpacing.md,
          AppSpacing.md + 4,
          AppSpacing.xl,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HomeHeader(
                  username: username,
                  onLogout: () =>
                      ref.read(authNotifierProvider.notifier).logout(),
                ),
                const SizedBox(height: AppSpacing.xl),
                EntranceAnimation(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username != null
                            ? 'Ready to battle, $username?'
                            : 'Ready to battle?',
                        style: textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Choose a game mode to jump in.',
                        style: textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= AppBreakpoints.wide;
                    final cards = [
                      for (var i = 0; i < gameModes.length; i++)
                        EntranceAnimation(
                          delay: _staggerStep * (i + 1),
                          child: GameModeCard(
                            mode: gameModes[i],
                            vertical: wide,
                            onTap: () =>
                                _open(context, gameModes[i].screenBuilder),
                          ),
                        ),
                    ];

                    if (wide) {
                      return Row(
                        children: [
                          for (var i = 0; i < cards.length; i++) ...[
                            if (i > 0) const SizedBox(width: AppSpacing.lg),
                            Expanded(child: cards[i]),
                          ],
                        ],
                      );
                    }
                    return Column(
                      children: [
                        for (var i = 0; i < cards.length; i++) ...[
                          if (i > 0) const SizedBox(height: AppSpacing.md),
                          cards[i],
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                EntranceAnimation(
                  delay: _staggerStep * (gameModes.length + 1),
                  child: _LeaderboardBanner(
                    onTap: () =>
                        _open(context, (_) => const LeaderboardScreen()),
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

class _LeaderboardBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _LeaderboardBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      semanticLabel: 'Leaderboard',
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.md + 2),
        borderColor: AppColors.gold.withValues(alpha: 0.45),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.gold, AppColors.sunsetOrange],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.45),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: AppColors.textOnAccent,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leaderboard',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    "See who's on top across every game",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.gold,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
