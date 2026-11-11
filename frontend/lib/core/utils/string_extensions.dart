extension StringCasing on String {
  /// "pikachu" -> "Pikachu". Used for Pokémon names and type names, which
  /// the backend sends lowercase.
  String get capitalized =>
      isEmpty ? this : this[0].toUpperCase() + substring(1);
}
