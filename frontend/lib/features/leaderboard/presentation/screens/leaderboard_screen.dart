import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Leaderboard'),
          bottom: TabBar(
            isScrollable: true,
            tabs: _tabs.map((t) => Tab(text: t.$1)).toList(),
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

class _GlobalRankingTab extends ConsumerWidget {
  const _GlobalRankingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingAsync = ref.watch(globalRankingProvider);

    return rankingAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Failed to load: $err')),
      data: (entries) {
        if (entries.isEmpty) {
          return const Center(
            child: Text('No scores yet — go play something!'),
          );
        }
        return ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(entry.username),
              trailing: Text(
                entry.weightedScore.toStringAsFixed(0),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
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
    final leaderboardAsync = ref.watch(gameLeaderboardProvider(gameType));

    return leaderboardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Failed to load: $err')),
      data: (entries) {
        if (entries.isEmpty) {
          return const Center(
            child: Text('No scores yet — go play this game!'),
          );
        }
        return ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(entry.username),
              subtitle: Text(
                entry.mode == 'multi' ? 'Multiplayer' : 'Single player',
              ),
              trailing: Text(
                '${entry.score}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        );
      },
    );
  }
}
