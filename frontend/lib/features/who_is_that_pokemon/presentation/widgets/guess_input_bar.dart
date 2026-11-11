import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/widgets.dart';

class GuessInputBar extends StatefulWidget {
  final bool enabled;
  final ValueChanged<String> onSubmit;

  const GuessInputBar({
    super.key,
    required this.enabled,
    required this.onSubmit,
  });

  @override
  State<GuessInputBar> createState() => _GuessInputBarState();
}

class _GuessInputBarState extends State<GuessInputBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSubmit(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            enabled: widget.enabled,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              hintText: "Who's that Pokémon?",
              prefixIcon: Icon(Icons.catching_pokemon),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 2),
        GradientButton(
          label: 'Guess',
          icon: Icons.send_rounded,
          gradient: AppGradients.pokeBall,
          onPressed: widget.enabled ? _submit : null,
        ),
      ],
    );
  }
}
