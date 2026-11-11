import 'package:flutter/material.dart';

/// Two big thumb-friendly buttons for choosing higher or lower. Disabled
/// while [enabled] is false (e.g. mid-network-call) to prevent a fast
/// double-tap from submitting two guesses for one round.
class GuessButtons extends StatelessWidget {
  final bool enabled;
  final ValueChanged<String> onGuess;

  const GuessButtons({
    super.key,
    required this.enabled,
    required this.onGuess,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GuessButton(
            label: 'Lower',
            icon: Icons.arrow_downward,
            color: Colors.redAccent,
            enabled: enabled,
            onPressed: () => onGuess('lower'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _GuessButton(
            label: 'Higher',
            icon: Icons.arrow_upward,
            color: Colors.green,
            enabled: enabled,
            onPressed: () => onGuess('higher'),
          ),
        ),
      ],
    );
  }
}

class _GuessButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onPressed;

  const _GuessButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
