import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Named gradients built only from [AppColors] tokens, so swapping the
/// palette later re-tints every gradient automatically.
abstract final class AppGradients {
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.backgroundHigh,
      AppColors.backgroundMid,
      AppColors.backgroundDeep,
    ],
    stops: [0.0, 0.45, 1.0],
  );

  /// Default sheen for glass panels: brighter top-left fading out, which
  /// mimics light catching the edge of a frosted pane.
  static const LinearGradient glass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.glassFillStrong, AppColors.glassFillSubtle],
  );

  static const LinearGradient pokeBall = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.pokeRed, AppColors.pokeRedDeep],
  );

  static const LinearGradient electric = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.electricYellow, AppColors.sunsetOrange],
  );

  static const LinearGradient ocean = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.skyCyan, AppColors.aquaBlue],
  );

  static const LinearGradient mystic = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.mysticPurple, AppColors.aquaBlue],
  );

  static const LinearGradient blaze = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.sunsetOrange, AppColors.pokeRedDeep],
  );

  static const LinearGradient success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.leafGreen, AppColors.leafGreenDeep],
  );

  static const LinearGradient danger = pokeBall;

  /// Used for headline/brand text via [ShaderMask].
  static const LinearGradient brandText = LinearGradient(
    colors: [
      AppColors.electricYellow,
      AppColors.sunsetOrange,
      AppColors.pokeRed,
    ],
  );
}
