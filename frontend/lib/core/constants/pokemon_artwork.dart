/// Decorative Pokémon artwork used across the UI (login hero, game mode
/// cards). Uses the same PokeAPI official-artwork source the backend
/// already serves for gameplay sprites, so no image assets need to be
/// bundled with the app.
abstract final class PokemonArtwork {
  static const String _officialArtworkBase =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork';

  static String officialArtwork(int nationalDexId) =>
      '$_officialArtworkBase/$nationalDexId.png';

  // National Pokédex ids of the mascots used for decoration.
  static const int charizard = 6;
  static const int pikachu = 25;
  static const int gengar = 94;
  static const int mewtwo = 150;
  static const int lucario = 448;
}
