import { Injectable } from '@nestjs/common';
import { getEffectiveness } from './type-effectiveness';

// A participant is one claimed (or, in single-player, computer-picked)
// type. ownerId is null for computer-controlled types in single-player —
// those types spawn bubbles and fight, but we never score or attribute a
// "win" to a real user for them.
export interface BattleParticipant {
  type: string;
  ownerId: string | null;
  ownerUsername: string | null;
}

interface Bubble {
  id: string;
  type: string;
  power: number;
}

export interface InitialBubble {
  id: string;
  type: string;
  power: number;
  ownerUsername: string | null;
}

export interface BubbleClashEvent {
  round: number;
  bubbleAId: string;
  bubbleBId: string;
  sameType: boolean;
  damageToA: number;
  damageToB: number;
  aRemainingPower: number;
  bRemainingPower: number;
  eliminatedBubbleIds: string[];
}

export interface BubbleBattleResult {
  initialBubbles: InitialBubble[];
  events: BubbleClashEvent[];
  winnerType: string | null;
  winnerOwnerUsername: string | null;
  scoresByUserId: Record<string, number>;
}

const BUBBLES_PER_TYPE = 6;
const MIN_POWER = 1;
const MAX_POWER = 100;
// Tuning knob, not a fixed rule: scales down raw damage so a battle with
// dozens of bubbles (Hard mode: 10 types x 6 bubbles = 60) lasts a
// believable number of rounds instead of resolving almost instantly.
const DAMAGE_SCALE = 0.3;
const MAX_ROUNDS = 1000; // safety valve against a pathological infinite loop
const WINNER_BONUS = 50;
const POINTS_PER_ROUND_SURVIVED = 10;

// Runs the Type Clash bubble simulation: every claimed type spawns several
// bubbles, each with independent random power, and bubbles collide in
// random pairs until only one type has any survivors left. Deliberately
// probability-based and server-authoritative — the backend computes ONE
// deterministic script of collision events, and every client plays back
// the exact same sequence of outcomes, even though each client renders the
// bubbles' idle floating motion independently.
@Injectable()
export class TypeClashBattleService {
  simulateBubbleBattle(participants: BattleParticipant[]): BubbleBattleResult {
    let bubbles: Bubble[] = [];
    for (const participant of participants) {
      for (let i = 0; i < BUBBLES_PER_TYPE; i++) {
        bubbles.push({
          id: `${participant.type}-${i}`,
          type: participant.type,
          power: this.randomPower(),
        });
      }
    }

    const initialBubbles: InitialBubble[] = bubbles.map((bubble) => {
      const owner = participants.find((p) => p.type === bubble.type);
      return {
        id: bubble.id,
        type: bubble.type,
        power: bubble.power,
        ownerUsername: owner?.ownerUsername ?? null,
      };
    });

    const events: BubbleClashEvent[] = [];
    let round = 0;

    const distinctTypesAlive = () => new Set(bubbles.map((b) => b.type)).size;

    while (
      distinctTypesAlive() > 1 &&
      bubbles.length > 1 &&
      round < MAX_ROUNDS
    ) {
      round++;
      const [indexA, indexB] = this.pickCollisionPair(bubbles);
      const a = bubbles[indexA];
      const b = bubbles[indexB];
      const sameType = a.type === b.type;

      let damageToA = 0;
      let damageToB = 0;

      if (!sameType) {
        const effAtoB = getEffectiveness(a.type, b.type);
        const effBtoA = getEffectiveness(b.type, a.type);
        damageToB = Math.round(a.power * effAtoB * DAMAGE_SCALE);
        damageToA = Math.round(b.power * effBtoA * DAMAGE_SCALE);
        b.power = Math.max(0, b.power - damageToB);
        a.power = Math.max(0, a.power - damageToA);
      }
      // Same-type collisions are a harmless bounce — two bubbles of the
      // same type have no "advantage" over each other, so no damage.

      const eliminatedBubbleIds: string[] = [];
      if (a.power === 0) eliminatedBubbleIds.push(a.id);
      if (b.power === 0) eliminatedBubbleIds.push(b.id);

      events.push({
        round,
        bubbleAId: a.id,
        bubbleBId: b.id,
        sameType,
        damageToA,
        damageToB,
        aRemainingPower: a.power,
        bRemainingPower: b.power,
        eliminatedBubbleIds,
      });

      bubbles = bubbles.filter((bub) => bub.power > 0);
    }

    const remainingTypes = new Set(bubbles.map((b) => b.type));
    const winnerType =
      remainingTypes.size === 1 ? [...remainingTypes][0] : null;
    const winnerParticipant = winnerType
      ? (participants.find((p) => p.type === winnerType) ?? null)
      : null;

    const scoresByUserId = this.computeScores(
      participants,
      events,
      winnerType,
      round,
    );

    return {
      initialBubbles,
      events,
      winnerType,
      winnerOwnerUsername: winnerParticipant?.ownerUsername ?? null,
      scoresByUserId,
    };
  }

  // Biases toward finding a cross-type pair (where a "clash" actually
  // means something) for better pacing, rather than letting the battle
  // stall on repeated same-type bounces by chance. Falls back to any
  // random pair after a handful of attempts.
  private pickCollisionPair(bubbles: Bubble[]): [number, number] {
    for (let attempt = 0; attempt < 15; attempt++) {
      const [i, j] = this.pickTwoDistinctIndices(bubbles.length);
      if (bubbles[i].type !== bubbles[j].type) return [i, j];
    }
    return this.pickTwoDistinctIndices(bubbles.length);
  }

  // Score reflects how long a TYPE survived (its last bubble's elimination
  // round), not individual bubbles — the player is rooting for their whole
  // type. The outright winner gets a bonus on top. Computer-controlled
  // types (ownerId === null) are skipped entirely.
  private computeScores(
    participants: BattleParticipant[],
    events: BubbleClashEvent[],
    winnerType: string | null,
    finalRound: number,
  ): Record<string, number> {
    const aliveCountByType: Record<string, number> = {};
    for (const p of participants) aliveCountByType[p.type] = BUBBLES_PER_TYPE;

    const eliminationRoundByType: Record<string, number> = {};
    for (const event of events) {
      for (const bubbleId of event.eliminatedBubbleIds) {
        // Bubble ids are `${type}-${index}` and our type names never
        // contain hyphens, so splitting on the first hyphen safely
        // recovers the type.
        const type = bubbleId.split('-')[0];
        aliveCountByType[type] -= 1;
        if (aliveCountByType[type] === 0) {
          eliminationRoundByType[type] = event.round;
        }
      }
    }

    const scores: Record<string, number> = {};
    for (const p of participants) {
      if (!p.ownerId) continue; // skip computer-controlled types
      const survivedUntilRound = eliminationRoundByType[p.type] ?? finalRound;
      scores[p.ownerId] = survivedUntilRound * POINTS_PER_ROUND_SURVIVED;
    }

    if (winnerType) {
      const winnerParticipant = participants.find(
        (p) => p.type === winnerType,
      );
      if (winnerParticipant?.ownerId) {
        scores[winnerParticipant.ownerId] =
          (scores[winnerParticipant.ownerId] ?? 0) + WINNER_BONUS;
      }
    }

    return scores;
  }

  private randomPower(): number {
    return (
      Math.floor(Math.random() * (MAX_POWER - MIN_POWER + 1)) + MIN_POWER
    );
  }

  private pickTwoDistinctIndices(length: number): [number, number] {
    const first = Math.floor(Math.random() * length);
    let second = Math.floor(Math.random() * length);
    while (second === first) {
      second = Math.floor(Math.random() * length);
    }
    return [first, second];
  }
}
