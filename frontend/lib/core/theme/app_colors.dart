import 'package:flutter/material.dart';

/// The single source of truth for every color in the app.
///
/// The palette is a provisional "night stadium" look: deep indigo
/// backgrounds so translucent glass panels read clearly, lit by the three
/// classic Pokémon accents (Poké Ball red, Pikachu yellow, Squirtle blue).
/// When the final brand colors arrive, only the values in this file (and
/// the gradients built from them in `app_gradients.dart`) need to change.
abstract final class AppColors {
  // Backgrounds
  static const Color backgroundDeep = Color(0xFF0A0D26);
  static const Color backgroundMid = Color(0xFF171447);
  static const Color backgroundHigh = Color(0xFF2C1A5E);

  // Brand accents
  static const Color pokeRed = Color(0xFFFF4D5E);
  static const Color pokeRedDeep = Color(0xFFD7263D);
  static const Color electricYellow = Color(0xFFFFCB05);
  static const Color sunsetOrange = Color(0xFFFF8A3D);
  static const Color aquaBlue = Color(0xFF3D7DFF);
  static const Color skyCyan = Color(0xFF4FD8FF);
  static const Color mysticPurple = Color(0xFF8B5CF6);
  static const Color leafGreen = Color(0xFF2EE59D);
  static const Color leafGreenDeep = Color(0xFF10B981);

  // Semantic
  static const Color success = leafGreen;
  static const Color danger = pokeRed;
  static const Color warning = electricYellow;

  // Text on dark/glass surfaces
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xC7FFFFFF); // ~78%
  static const Color textMuted = Color(0x8AFFFFFF); // ~54%
  static const Color textOnAccent = Color(0xFF1A1033);

  // Glass surfaces
  static const Color glassFill = Color(0x1FFFFFFF); // ~12%
  static const Color glassFillStrong = Color(0x2EFFFFFF); // ~18%
  static const Color glassFillSubtle = Color(0x0FFFFFFF); // ~6%
  static const Color glassBorder = Color(0x38FFFFFF); // ~22%
  static const Color glassShadow = Color(0x59000000); // ~35%

  // Leaderboard medals
  static const Color gold = Color(0xFFFFD54F);
  static const Color silver = Color(0xFFCFD8DC);
  static const Color bronze = Color(0xFFE0A06B);
}
