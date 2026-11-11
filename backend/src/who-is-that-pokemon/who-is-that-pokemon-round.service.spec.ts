import { WhoIsThatPokemonRoundService } from './who-is-that-pokemon-round.service';

// This service has real dependencies (Redis, PokemonService) — so instead
// of a TestingModule, we hand it lightweight jest.fn() mocks directly.
// This keeps the test fast and focused purely on THIS service's logic.
describe('WhoIsThatPokemonRoundService', () => {
  let service: WhoIsThatPokemonRoundService;
  let mockRedis: {
    set: jest.Mock;
    get: jest.Mock;
    del: jest.Mock;
    sismember: jest.Mock;
    sadd: jest.Mock;
  };
  let mockPokemonService: { getRandomPokemon: jest.Mock };

  beforeEach(() => {
    mockRedis = {
      set: jest.fn().mockResolvedValue('OK'),
      get: jest.fn(),
      del: jest.fn().mockResolvedValue(1),
      sismember: jest.fn().mockResolvedValue(0),
      sadd: jest.fn().mockResolvedValue(1),
    };

    mockPokemonService = {
      getRandomPokemon: jest.fn().mockResolvedValue({
        id: 25,
        name: 'pikachu',
        spriteUrl: 'https://example.com/pikachu.png',
        types: ['electric'],
        stats: {
          hp: 35,
          attack: 55,
          defense: 40,
          specialAttack: 50,
          specialDefense: 50,
          speed: 90,
        },
      }),
    };

    service = new WhoIsThatPokemonRoundService(
      mockRedis as any,
      mockPokemonService as any,
    );
  });

  const activeRound = () =>
    JSON.stringify({
      pokemonId: 25,
      pokemonName: 'pikachu',
      spriteUrl: 'url',
      startedAt: Date.now(),
    });

  it("withholds the Pokémon's name from startRound's return value", async () => {
    const round = await service.startRound();

    expect(round).toEqual({
      pokemonId: 25,
      spriteUrl: 'https://example.com/pikachu.png',
      durationSeconds: 10,
    });
    expect(round).not.toHaveProperty('pokemonName');
  });

  it('scores a guess made right at round start close to the maximum', async () => {
    mockRedis.get.mockResolvedValue(activeRound());

    const result = await service.submitGuess('user-1', 'pikachu');

    expect(result.correct).toBe(true);
    expect(result.score).toBeGreaterThanOrEqual(90);
  });

  it('is case-insensitive and tolerates surrounding whitespace', async () => {
    mockRedis.get.mockResolvedValue(activeRound());

    const result = await service.submitGuess('user-1', '  PIKACHU  ');

    expect(result.correct).toBe(true);
  });

  it('rejects an incorrect guess and never touches the correct-guessers set', async () => {
    mockRedis.get.mockResolvedValue(activeRound());

    const result = await service.submitGuess('user-1', 'charizard');

    expect(result.correct).toBe(false);
    expect(mockRedis.sadd).not.toHaveBeenCalled();
  });

  it('prevents a second correct guess from the same user in the same round', async () => {
    mockRedis.get.mockResolvedValue(activeRound());
    mockRedis.sismember.mockResolvedValue(1); // already in the set

    const result = await service.submitGuess('user-1', 'pikachu');

    expect(result.correct).toBe(false);
    expect(result.alreadyGuessed).toBe(true);
  });

  it('returns a safe empty result if no round is currently active', async () => {
    mockRedis.get.mockResolvedValue(null);

    const result = await service.submitGuess('user-1', 'pikachu');

    expect(result).toEqual({
      correct: false,
      alreadyGuessed: false,
      score: 0,
    });
  });
});
