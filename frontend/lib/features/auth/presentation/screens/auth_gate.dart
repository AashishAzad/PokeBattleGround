import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/presentation/screens/home_screen.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';
import 'auth_screen.dart';
import 'splash_screen.dart';

/// The app's single entry decision: no screen anywhere else needs its own
/// "am I logged in?" check, because nothing behind this gate can be
/// reached while signed out.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(authNotifierProvider.select((s) => s.status));

    switch (status) {
      case AuthStatus.unknown:
        return const SplashScreen();
      case AuthStatus.unauthenticated:
        return const AuthScreen();
      case AuthStatus.authenticated:
        return const HomeScreen();
    }
  }
}
