import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';

/// Adds tactile, game-like feedback to any tappable surface: it shrinks
/// slightly while pressed and lifts slightly on hover (web/desktop).
///
/// Built on [InkWell], so it keeps keyboard focus, Enter/Space activation,
/// hover and semantics for free. When [onTap] is null the child is shown
/// as-is and receives no interaction.
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final double pressedScale;
  final double hoverScale;
  final String? semanticLabel;

  const PressableScale({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = AppRadii.lgAll,
    this.pressedScale = 0.96,
    this.hoverScale = 1.02,
    this.semanticLabel,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  void didUpdateWidget(PressableScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A surface that becomes disabled mid-press must not stay shrunk.
    if (widget.onTap == null && (_pressed || _hovered)) {
      _pressed = false;
      _hovered = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = _pressed
        ? widget.pressedScale
        : _hovered
        ? widget.hoverScale
        : 1.0;

    return Semantics(
      button: true,
      enabled: widget.onTap != null,
      label: widget.semanticLabel,
      child: AnimatedScale(
        scale: scale,
        duration: AppDurations.fast,
        curve: Curves.easeOut,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: widget.borderRadius,
            splashColor: Colors.white24,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.white12,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            onHover: (value) => setState(() => _hovered = value),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
