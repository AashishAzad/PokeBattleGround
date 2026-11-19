import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_gradients.dart';

/// The core Glassmorphism surface: a translucent, frosted panel with a
/// soft light-catching border.
///
/// [blur] applies a real backdrop blur. It's the most expensive part of
/// the effect, so pass `blur: 0` for many small repeated items (list rows,
/// chips) — over the app's smooth background the tint + border alone
/// already read as glass.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius borderRadius;
  final double blur;
  final Gradient? gradient;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? shadows;
  final double? width;
  final double? height;

  /// Optional size limits, e.g. a max width so panels shrink on phones.
  final BoxConstraints? constraints;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
    this.borderRadius = AppRadii.lgAll,
    this.blur = 18,
    this.gradient,
    this.borderColor,
    this.borderWidth = 1.2,
    this.shadows,
    this.width,
    this.height,
    this.constraints,
  });

  static const List<BoxShadow> defaultShadows = [
    BoxShadow(
      color: AppColors.glassShadow,
      blurRadius: 30,
      offset: Offset(0, 16),
      spreadRadius: -12,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    Widget panel = DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient ?? AppGradients.glass,
        borderRadius: borderRadius,
        border: Border.all(
          color: borderColor ?? AppColors.glassBorder,
          width: borderWidth,
        ),
      ),
      child: Padding(padding: padding, child: child),
    );

    if (blur > 0) {
      panel = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: panel,
      );
    }

    return Container(
      width: width,
      height: height,
      constraints: constraints,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: shadows ?? defaultShadows,
      ),
      child: ClipRRect(borderRadius: borderRadius, child: panel),
    );
  }
}
