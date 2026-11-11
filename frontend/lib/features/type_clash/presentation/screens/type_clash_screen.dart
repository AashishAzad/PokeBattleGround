import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../user/data/models/app_user.dart';
import '../../../user/presentation/providers/current_user_provider.dart';
import '../providers/type_clash_game_notifier.dart';
import '../providers/type_clash_game_state.dart';
import '../widgets/bubble_arena_view.dart';
import '../widgets/difficulty_selector.dart';
import '../widgets/lobby_waiting_view.dart';
import '../widgets/type_selection_view.dart';
import 'type_clash_single_player_screen.dart';

enum _EntryMode { none, multi }

class TypeClashScreen extends ConsumerStatefulWidget {
  const TypeClashScreen({super.key});

  @override
  ConsumerState<TypeClashScreen> createState() => _TypeClashScreenState();
}

class _TypeClashScreenState extends ConsumerState<TypeClashScreen> {
  _EntryMode _mode = _EntryMode.none;

  @override
  void initState() {
    super.initState();
    // Type Clash's arena needs the extra horizontal room landscape gives —
    // locked for the whole feature (both single-player and multiplayer
    // route through this screen, since the single-player screen is pushed
    // ON TOP of this one rather than replacing it).
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Restore all orientations once the player leaves Type Clash entirely,
    // so the rest of the app (Higher or Lower, Home) isn't stuck landscape.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: 'Type Clash',
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _mode == _EntryMode.none
              ? _buildModeSelector()
              : _buildMultiplayerFlow(),
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return EntranceAnimation(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'How do you want to battle?',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            alignment: WrapAlignment.center,
            children: [
              OptionCard(
                title: 'Single Player',
                subtitle: 'Pick a type and battle solo',
                icon: Icons.person_rounded,
                color: AppColors.sunsetOrange,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TypeClashSinglePlayerScreen(),
                  ),
                ),
              ),
              OptionCard(
                title: 'Multiplayer',
                subtitle: 'Claim a type against real trainers',
                icon: Icons.groups_rounded,
                color: AppColors.skyCyan,
                onTap: () => setState(() => _mode = _EntryMode.multi),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultiplayerFlow() {
    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      loading: () => const LoadingView(),
      error: (err, _) => ErrorView(message: 'Failed to load profile: $err'),
      data: (user) => _MultiplayerBody(user: user),
    );
  }
}

class _MultiplayerBody extends ConsumerWidget {
  final AppUser user;

  const _MultiplayerBody({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(typeClashGameProvider(user));
    final notifier = ref.read(typeClashGameProvider(user).notifier);

    final Widget content;
    switch (gameState.phase) {
      case TypeClashPhase.choosingDifficulty:
        content = DifficultySelector(onSelect: notifier.joinLobby);
        break;
      case TypeClashPhase.inLobby:
        content = LobbyWaitingView(
          difficulty: gameState.difficulty ?? '',
          players: gameState.lobbyPlayers,
        );
        break;
      case TypeClashPhase.selectingType:
        content = TypeSelectionView(
          availableTypes: gameState.availableTypes,
          claimedTypeUsernames: gameState.claimedTypeUsernames,
          mySelectedType: gameState.mySelectedType,
          selectionSeconds: gameState.selectionSeconds,
          onSelectType: notifier.selectType,
        );
        break;
      case TypeClashPhase.waitingForBattle:
        content = const LoadingView(message: 'Battle starting...');
        break;
      case TypeClashPhase.battleReady:
        content = BubbleArenaView(
          result: gameState.battleResult!,
          onPlayAgain: notifier.playAgain,
        );
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (gameState.errorMessage != null) ...[
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppBreakpoints.contentMaxWidth,
            ),
            child: MessageBanner.error(gameState.errorMessage!),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        content,
      ],
    );
  }
}
