import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/auth_gate.dart';

void main() {
  runApp(const ProviderScope(child: PokeBattleGroundApp()));
}

class PokeBattleGroundApp extends StatelessWidget {
  const PokeBattleGroundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokeBattleGround',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      // AuthGate decides between the splash, the login screen, and Home.
      home: const AuthGate(),
    );
  }
}
