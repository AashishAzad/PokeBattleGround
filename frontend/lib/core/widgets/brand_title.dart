import 'package:flutter/material.dart';

import 'gradient_text.dart';

/// The "PokéBattleGround" wordmark, shared by the splash, login and home
/// header so the brand renders identically everywhere.
class BrandTitle extends StatelessWidget {
  final double fontSize;
  final TextAlign textAlign;

  const BrandTitle({
    super.key,
    this.fontSize = 34,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: 'PokeBattleGround',
      child: ExcludeSemantics(
        child: Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Poké'),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: GradientText(
                  'Battle',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const TextSpan(text: 'Ground'),
            ],
          ),
          textAlign: textAlign,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
            shadows: const [Shadow(color: Colors.black38, blurRadius: 16)],
          ),
        ),
      ),
    );
  }
}
