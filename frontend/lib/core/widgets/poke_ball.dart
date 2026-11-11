import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum PokeBallStyle {
  /// Full-color Poké Ball (logos, loaders).
  filled,

  /// Single-color line art for decorative watermarks and backgrounds.
  outline,
}

/// A vector Poké Ball drawn with a [CustomPainter] — crisp at any size and
/// no image asset to bundle.
class PokeBall extends StatelessWidget {
  final double size;
  final PokeBallStyle style;

  /// Line color for [PokeBallStyle.outline].
  final Color outlineColor;

  const PokeBall({
    super.key,
    this.size = 48,
    this.style = PokeBallStyle.filled,
    this.outlineColor = const Color(0x22FFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: PokeBallPainter(style: style, outlineColor: outlineColor),
      ),
    );
  }
}

class PokeBallPainter extends CustomPainter {
  final PokeBallStyle style;
  final Color outlineColor;

  const PokeBallPainter({required this.style, required this.outlineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    final c = size.center(Offset.zero);
    final rect = Rect.fromCircle(center: c, radius: r);

    if (style == PokeBallStyle.outline) {
      final stroke = Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.09;
      canvas.drawCircle(c, r * 0.95, stroke);
      canvas.drawLine(
        Offset(c.dx - r * 0.95, c.dy),
        Offset(c.dx - r * 0.3, c.dy),
        stroke,
      );
      canvas.drawLine(
        Offset(c.dx + r * 0.3, c.dy),
        Offset(c.dx + r * 0.95, c.dy),
        stroke,
      );
      canvas.drawCircle(c, r * 0.3, stroke);
      canvas.drawCircle(c, r * 0.12, Paint()..color = outlineColor);
      return;
    }

    const ink = Color(0xFF1B1530);
    // Top (red) and bottom (white) halves with a little shading for depth.
    canvas.drawArc(
      rect,
      math.pi,
      math.pi,
      true,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B78), AppColors.pokeRedDeep],
        ).createShader(rect),
    );
    canvas.drawArc(
      rect,
      0,
      math.pi,
      true,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFD9DCEB)],
        ).createShader(rect),
    );

    // Gloss highlight on the red half.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(c.dx - r * 0.38, c.dy - r * 0.5),
        width: r * 0.5,
        height: r * 0.26,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );

    // Center band, outer ring and button.
    canvas.drawRect(
      Rect.fromCenter(center: c, width: r * 2, height: r * 0.16),
      Paint()..color = ink,
    );
    canvas.drawCircle(
      c,
      r - r * 0.04,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.08,
    );
    canvas.drawCircle(c, r * 0.32, Paint()..color = ink);
    canvas.drawCircle(c, r * 0.22, Paint()..color = Colors.white);
    canvas.drawCircle(
      c,
      r * 0.22,
      Paint()
        ..color = const Color(0xFFBFC3D9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.03,
    );
  }

  @override
  bool shouldRepaint(PokeBallPainter oldDelegate) =>
      oldDelegate.style != style || oldDelegate.outlineColor != outlineColor;
}

/// The app's loading indicator: a Poké Ball doing the "wobble while
/// catching" shake. Replaces the default circular spinner everywhere so
/// waiting moments still feel on-theme.
class PokeBallLoader extends StatefulWidget {
  final double size;

  const PokeBallLoader({super.key, this.size = 48});

  @override
  State<PokeBallLoader> createState() => _PokeBallLoaderState();
}

class _PokeBallLoaderState extends State<PokeBallLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Two quick wobbles, then a pause — like a real capture attempt.
          final t = _controller.value;
          final wobble = t < 0.6 ? math.sin(t / 0.6 * math.pi * 4) : 0.0;
          return Transform.rotate(
            angle: wobble * 0.35,
            alignment: Alignment.bottomCenter,
            child: child,
          );
        },
        child: PokeBall(size: widget.size),
      ),
    );
  }
}
