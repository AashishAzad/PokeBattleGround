import {
  BattleParticipant,
  TypeClashBattleService,
} from './type-clash-battle.service';

// TypeClashBattleService has no injected dependencies (no Redis, no DB) —
// it's pure logic, so we can instantiate it directly with `new` instead of
// going through Nest's TestingModule machinery.
describe('TypeClashBattleService', () => {
  let service: TypeClashBattleService;

  beforeEach(() => {
    service = new TypeClashBattleService();
  });

  function makeParticipants(types: string[]): BattleParticipant[] {
    return types.map((type, index) => ({
      type,
      ownerId: `user-${index}`,
      ownerUsername: `player-${index}`,
    }));
  }

  it('spawns exactly 6 bubbles per participant type', () => {
    const participants = makeParticipants(['fire', 'water', 'grass']);
    const result = service.simulateBubbleBattle(participants);

    expect(result.initialBubbles).toHaveLength(18); // 3 types x 6 bubbles

    for (const participant of participants) {
      const bubblesOfType = result.initialBubbles.filter(
        (b) => b.type === participant.type,
      );
      expect(bubblesOfType).toHaveLength(6);
    }
  });

  // Since the simulation is randomized, we don't assert an exact outcome —
  // we assert invariants that must hold true regardless of which random
  // path the battle took. This is the right testing style for
  // intentionally non-deterministic code.
  it('always declares a winner that was one of the actual participants', () => {
    const participants = makeParticipants([
      'fire',
      'water',
      'grass',
      'electric',
    ]);
    const result = service.simulateBubbleBattle(participants);

    if (result.winnerType) {
      expect(participants.map((p) => p.type)).toContain(result.winnerType);
    }
  });

  it("never lets a bubble's remaining power go negative", () => {
    const participants = makeParticipants(['fire', 'water']);
    const result = service.simulateBubbleBattle(participants);

    for (const event of result.events) {
      expect(event.aRemainingPower).toBeGreaterThanOrEqual(0);
      expect(event.bRemainingPower).toBeGreaterThanOrEqual(0);
    }
  });

  it('only awards scores to participants with a real ownerId, skipping computer-controlled types', () => {
    const participants: BattleParticipant[] = [
      { type: 'fire', ownerId: 'real-user-1', ownerUsername: 'Ash' },
      { type: 'water', ownerId: null, ownerUsername: null }, // single-player bot opponent
    ];

    const result = service.simulateBubbleBattle(participants);

    expect(Object.keys(result.scoresByUserId)).toEqual(['real-user-1']);
  });

  it("gives the winner a score at least as high as any other participant's", () => {
    const participants = makeParticipants(['fire', 'water', 'grass']);
    const result = service.simulateBubbleBattle(participants);

    if (!result.winnerType) return; // extremely rare MAX_ROUNDS draw

    const winnerParticipant = participants.find(
      (p) => p.type === result.winnerType,
    )!;
    const winnerScore = result.scoresByUserId[winnerParticipant.ownerId!];

    for (const participant of participants) {
      if (participant.type === result.winnerType) continue;
      const otherScore = result.scoresByUserId[participant.ownerId!];
      expect(winnerScore).toBeGreaterThanOrEqual(otherScore);
    }
  });

  it('resolves immediately with that type as the winner when there is a single participant', () => {
    // A single-type "battle" has no opponent to clash with.
    const participants = makeParticipants(['fire']);
    const result = service.simulateBubbleBattle(participants);

    expect(result.winnerType).toBe('fire');
    expect(result.events).toHaveLength(0);
  });
});
