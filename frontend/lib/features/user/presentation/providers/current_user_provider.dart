import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../data/models/app_user.dart';

/// The signed-in user, derived from the auth session. Every screen that
/// needs "who is playing" watches THIS provider instead of reaching into
/// the auth notifier directly.
///
/// Behind the AuthGate this always has a user; the StateError is a loud
/// safety net for the "should be impossible" case of a screen being
/// reached while signed out.
final currentUserProvider = FutureProvider<AppUser>((ref) async {
  final user = ref.watch(authNotifierProvider.select((s) => s.user));
  if (user == null) {
    throw StateError('currentUserProvider read while signed out');
  }
  return user;
});
