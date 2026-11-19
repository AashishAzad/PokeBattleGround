import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/bubble_battle_result.dart';
import '../../data/type_clash_rest_api_provider.dart';
import '../widgets/bubble_arena_view.dart';
import '../widgets/difficulty_selector.dart';
import '../widgets/type_badge.dart';
import '../widgets/type_colors.dart';

enum _SpPhase { choosingDifficulty, choosingType, loading, battleReady, error }

class TypeClashSinglePlayerScreen extends ConsumerStatefulWidget {
  const TypeClashSinglePlayerScreen({super.key});

  @override
  ConsumerState<TypeClashSinglePlayerScreen> createState() =>
      _TypeClashSinglePlayerScreenState();
}

class _TypeClashSinglePlayerScreenState
    extends ConsumerState<TypeClashSinglePlayerScreen> {
  _SpPhase _phase = _SpPhase.choosingDifficulty;
  String? _difficulty;
  BubbleBattleResult? _result;
  String? _errorMessage;

  Future<void> _startBattle(String chosenType) async {
    setState(() => _phase = _SpPhase.loading);

    try {
      final api = ref.read(typeClashRestApiProvider);
      final result = await api.startSinglePlayer(
        difficulty: _difficulty!,
        chosenType: chosenType,
      );
      setState(() {
        _result = result;
        _phase = _SpPhase.battleReady;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _phase = _SpPhase.error;
      });
    }
  }

  void _reset() {
    setState(() {
      _phase = _SpPhase.choosingDifficulty;
      _difficulty = null;
      _result = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: 'Type Clash — Single Player',
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_phase) {
      case _SpPhase.choosingDifficulty:
        return DifficultySelector(
          onSelect: (difficulty) => setState(() {
            _difficulty = difficulty;
            _phase = _SpPhase.choosingType;
          }),
        );
      case _SpPhase.choosingType:
        return _TypePicker(onSelect: _startBattle);
      case _SpPhase.loading:
        return const LoadingView(message: 'Preparing the arena...');
      case _SpPhase.battleReady:
        return BubbleArenaView(result: _result!, onPlayAgain: _reset);
      case _SpPhase.error:
        return ErrorView(
          message: '$_errorMessage',
          onRetry: _reset,
          retryLabel: 'Try Again',
        );
    }
  }
}

class _TypePicker extends StatelessWidget {
  final ValueChanged<String> onSelect;

  const _TypePicker({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return EntranceAnimation(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Choose your type',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            alignment: WrapAlignment.center,
            children: pokemonTypeColors.keys.map((type) {
              return TypeBadge(
                type: type,
                size: 84,
                onTap: () => onSelect(type),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
