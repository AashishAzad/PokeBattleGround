import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/leaderboard_providers.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  // Tab label paired with the backend's gameType string (null = global).
  static const List<(String, String?)> _tabs = [
    ('Global', null),
    ('Higher/Lower', 'higher_or_lower'),
    ('Type Clash', 'type_clash'),
    ('Who Is That?', 'who_is_that_pokemon'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: GlassScaffold(
        title: 'Leaderboard',
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.sm + 4,
            ),
            child: Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.glassFillSubtle,
                borderRadius: AppRadii.pillAll,
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: TabBar(
                isScrollable: true,
                tabs: _tabs.map((t) => Tab(text: t.$1)).toList(),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: _tabs.map((t) {
            return t.$2 == null
                ? const _GlobalRankingTab()
                : _GameLeaderboardTab(gameType: t.$2!);
          }).toList(),
        ),
      ),
    );
  }
}

/// Shared list chrome for every tab: width-capped, pull-to-refresh, and
/// rows that slide in one after another.
class _RankingList extends StatelessWidget {
  final int itemCount;
  final Widget Function(int index) itemBuilder;
  final Future<void> Function() onRefresh;

  const _RankingList({
    required this.itemCount,
    required this.itemBuilder,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.electricYellow,
      backgroundColor: AppColors.backgroundHigh,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppBreakpoints.contentMaxWidth,
          ),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: itemCount,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) => EntranceAnimation(
              // Cap the stagger so long lists don't take ages to appear.
              delay: Duration(milliseconds: 40 * index.clamp(0, 10)),
              child: itemBuilder(index),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlobalRankingTab extends ConsumerWidget {
  const _GlobalRankingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingAsync = ref.watch(globalRankingProvider);

    return rankingAsync.when(
      loading: () => const LoadingView(),
      error: (err, _) => ErrorView(
        message: 'Failed to load: $err',
        onRetry: () => ref.invalidate(globalRankingProvider),
      ),
      data: (entries) {
        if (entries.isEmpty) {
          return const EmptyView(message: 'No scores yet — go play something!');
        }
        return _RankingList(
          itemCount: entries.length,
          onRefresh: () => ref.refresh(globalRankingProvider.future),
          itemBuilder: (index) {
            final entry = entries[index];
            return PlayerTile(
              rank: index + 1,
              username: entry.username,
              trailing: entry.weightedScore.toStringAsFixed(0),
            );
          },
        );
      },
    );
  }
}

class _GameLeaderboardTab extends ConsumerWidget {
  final String gameType;

  const _GameLeaderboardTab({required this.gameType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = gameLeaderboardProvider(gameType);
    final leaderboardAsync = ref.watch(provider);

    return leaderboardAsync.when(
      loading: () => const LoadingView(),
      error: (err, _) => ErrorView(
        message: 'Failed to load: $err',
        onRetry: () => ref.invalidate(provider),
      ),
      data: (entries) {
        if (entries.isEmpty) {
          return const EmptyView(message: 'No scores yet — go play this game!');
        }
        return _RankingList(
          itemCount: entries.length,
          onRefresh: () => ref.refresh(provider.future),
          itemBuilder: (index) {
            final entry = entries[index];
            return PlayerTile(
              rank: index + 1,
              username: entry.username,
              subtitle: entry.mode == 'multi' ? 'Multiplayer' : 'Single player',
              trailing: '${entry.score}',
            );
          },
        );
      },
    );
  }
}
