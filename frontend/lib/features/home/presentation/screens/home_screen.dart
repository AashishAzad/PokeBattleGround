import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../higher_or_lower/presentation/screens/higher_or_lower_screen.dart';
import '../../../leaderboard/presentation/screens/leaderboard_screen.dart';
import '../../../type_clash/presentation/screens/type_clash_screen.dart';
import '../../../who_is_that_pokemon/presentation/screens/who_is_that_pokemon_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.watch(
      authNotifierProvider.select((s) => s.user?.username),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('PokeBattleGround'),
        actions: [
          if (username != null)
            Center(
              child: Text(
                username,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HigherOrLowerScreen()),
              ),
              child: const Text('Higher or Lower'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TypeClashScreen()),
              ),
              child: const Text('Type Clash'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const WhoIsThatPokemonScreen(),
                ),
              ),
              child: const Text('Who Is That Pokémon?'),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
              ),
              icon: const Icon(Icons.leaderboard),
              label: const Text('Leaderboard'),
            ),
          ],
        ),
      ),
    );
  }
}
