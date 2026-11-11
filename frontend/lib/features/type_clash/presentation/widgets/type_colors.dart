import 'package:flutter/material.dart';

/// Shared Pokémon-type → color mapping used across Type Clash's UI (type
/// selection bubbles, battle arena bubbles) so a given type reads
/// consistently everywhere it appears on screen.
const Map<String, Color> pokemonTypeColors = {
  'normal': Color(0xFFA8A77A),
  'fire': Color(0xFFEE8130),
  'water': Color(0xFF6390F0),
  'electric': Color(0xFFF7D02C),
  'grass': Color(0xFF7AC74C),
  'ice': Color(0xFF96D9D6),
  'fighting': Color(0xFFC22E28),
  'poison': Color(0xFFA33EA1),
  'ground': Color(0xFFE2BF65),
  'flying': Color(0xFFA98FF3),
  'psychic': Color(0xFFF95587),
  'bug': Color(0xFFA6B91A),
  'rock': Color(0xFFB6A136),
  'ghost': Color(0xFF735797),
  'dragon': Color(0xFF6F35FC),
  'dark': Color(0xFF705746),
  'steel': Color(0xFFB7B7CE),
  'fairy': Color(0xFFD685AD),
};

Color colorForType(String type) => pokemonTypeColors[type] ?? Colors.grey;

// A visual stand-in per type using Flutter's built-in Material icon set —
// not official Pokémon type icons (those are Nintendo IP we can't ship
// icon assets for), but close enough associations that a player learns
// to recognize each type at a glance, exactly like the reference site's
// type badges serve the same purpose.
const Map<String, IconData> pokemonTypeIcons = {
  'normal': Icons.circle,
  'fire': Icons.local_fire_department,
  'water': Icons.water_drop,
  'electric': Icons.bolt,
  'grass': Icons.eco,
  'ice': Icons.ac_unit,
  'fighting': Icons.sports_kabaddi,
  'poison': Icons.science,
  'ground': Icons.landscape,
  'flying': Icons.air,
  'psychic': Icons.remove_red_eye,
  'bug': Icons.bug_report,
  'rock': Icons.terrain,
  'ghost': Icons.nights_stay,
  'dragon': Icons.pets,
  'dark': Icons.dark_mode,
  'steel': Icons.shield,
  'fairy': Icons.auto_awesome,
};

IconData iconForType(String type) =>
    pokemonTypeIcons[type] ?? Icons.help_outline;
