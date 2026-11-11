import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/bubble_battle_result.dart';
import '../../data/type_clash_rest_api_provider.dart';
import '../widgets/bubble_arena_view.dart';
import '../widgets/difficulty_selector.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Type Clash — Single Player')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
        return const CircularProgressIndicator();
      case _SpPhase.battleReady:
        return BubbleArenaView(result: _result!, onPlayAgain: _reset);
      case _SpPhase.error:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Something went wrong: $_errorMessage'),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _reset, child: const Text('Try Again')),
          ],
        );
    }
  }
}

class _TypePicker extends StatelessWidget {
  final ValueChanged<String> onSelect;

  const _TypePicker({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Choose your type',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: pokemonTypeColors.keys.map((type) {
            return ActionChip(
              label: Text(_capitalize(type)),
              backgroundColor: colorForType(type).withOpacity(0.85),
              labelStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              onPressed: () => onSelect(type),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
