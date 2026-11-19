import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import 'poke_ball.dart';

/// The shared backdrop behind every screen: a deep indigo gradient, soft
/// glowing color orbs (which give the glass panels something to frost),
/// and a few outlined Poké Balls drifting slowly.
///
/// Performance: everything is drawn by one [CustomPainter] driven by one
/// slow controller and isolated in a [RepaintBoundary], so the animation
/// never rebuilds widgets or repaints the content on top. The motion stops
/// entirely when the OS "reduce motion" setting is on.
class AppBackground extends StatefulWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  State<AppBackground> createState() => _AppBackgroundState();
}

class _AppBackgroundState extends State<AppBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 40),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: CustomPaint(painter: _BackdropPainter(_controller)),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _Orb {
  final Alignment anchor;
  final double radiusFactor;
  final Color color;
  final double phase;

  const _Orb(this.anchor, this.radiusFactor, this.color, this.phase);
}

class _FloatingBall {
  final Alignment anchor;
  final double sizeFactor;
  final double spin;
  final double phase;

  const _FloatingBall(this.anchor, this.sizeFactor, this.spin, this.phase);
}

class _BackdropPainter extends CustomPainter {
  final Animation<double> animation;

  _BackdropPainter(this.animation) : super(repaint: animation);

  static const _orbs = [
    _Orb(Alignment(-1.0, -0.9), 0.55, AppColors.pokeRed, 0),
    _Orb(Alignment(1.1, -0.2), 0.5, AppColors.aquaBlue, 1.7),
    _Orb(Alignment(-0.6, 1.1), 0.6, AppColors.mysticPurple, 3.1),
    _Orb(Alignment(0.9, 1.0), 0.35, AppColors.electricYellow, 4.4),
  ];

  static const _balls = [
    _FloatingBall(Alignment(-0.85, -0.55), 0.16, 1, 0),
    _FloatingBall(Alignment(0.8, -0.85), 0.1, -1, 1.2),
    _FloatingBall(Alignment(0.95, 0.35), 0.22, 1, 2.3),
    _FloatingBall(Alignment(-0.9, 0.7), 0.12, -1, 3.6),
    _FloatingBall(Alignment(0.2, 0.95), 0.08, 1, 4.8),
  ];

  static const _ballPainter = PokeBallPainter(
    style: PokeBallStyle.outline,
    outlineColor: Color(0x14FFFFFF),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value * 2 * math.pi;
    final shortest = size.shortestSide;

    for (final orb in _orbs) {
      final drift =
          Offset(math.sin(t + orb.phase), math.cos(t + orb.phase)) *
          shortest *
          0.04;
      final center = orb.anchor.alongSize(size) + drift;
      final radius = shortest * orb.radiusFactor;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              orb.color.withValues(alpha: 0.32),
              orb.color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }

    for (final ball in _balls) {
      final ballSize = shortest * ball.sizeFactor;
      final bob = math.sin(t * 2 + ball.phase) * shortest * 0.015;
      final center = ball.anchor.alongSize(size) + Offset(0, bob);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(t * ball.spin);
      canvas.translate(-ballSize / 2, -ballSize / 2);
      _ballPainter.paint(canvas, Size.square(ballSize));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BackdropPainter oldDelegate) =>
      oldDelegate.animation != animation;
}
