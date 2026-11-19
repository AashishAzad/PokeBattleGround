import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/widgets.dart';

/// Two big thumb-friendly buttons for choosing higher or lower. Disabled
/// while [enabled] is false (e.g. mid-network-call) to prevent a fast
/// double-tap from submitting two guesses for one round.
///
/// On keyboards, ↑ guesses higher and ↓ guesses lower.
class GuessButtons extends StatelessWidget {
  final bool enabled;
  final ValueChanged<String> onGuess;

  const GuessButtons({super.key, required this.enabled, required this.onGuess});

  void _guess(String value) {
    if (enabled) onGuess(value);
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
            _guess('higher'),
        const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
            _guess('lower'),
      },
      child: Focus(
        autofocus: true,
        child: Row(
          children: [
            Expanded(
              child: GradientButton(
                label: 'LOWER',
                icon: Icons.arrow_downward_rounded,
                gradient: AppGradients.danger,
                height: 64,
                fontSize: 18,
                onPressed: enabled ? () => onGuess('lower') : null,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: GradientButton(
                label: 'HIGHER',
                icon: Icons.arrow_upward_rounded,
                gradient: AppGradients.success,
                height: 64,
                fontSize: 18,
                onPressed: enabled ? () => onGuess('higher') : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
