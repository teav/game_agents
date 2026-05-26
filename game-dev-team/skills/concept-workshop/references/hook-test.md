# hook-test

A loop has a "hook" when the player has a clear reason to start the next loop iteration. Without a hook, the loop is dead — no "one more turn" pull.

## Hook categories

Score each candidate loop against these. A loop should score **strong** on at least one; mature loops are strong on two to three.

| Category         | What it is                                                        | Examples in known games                          |
| ---------------- | ----------------------------------------------------------------- | ------------------------------------------------ |
| Progression      | Visible advance — XP, levels, gear, territory, unlocks            | RPGs, MMOs, *Civilization*                       |
| Mastery          | Player improves their own skill at the input/timing/strategy      | Souls games, fighting games, *Celeste*           |
| Discovery        | Always something new to find                                      | Procedural games, *Outer Wilds*, exploration     |
| Completion       | Collectibles, achievements, dex-style sets                        | *Pokémon*, completionist games                   |
| Social           | Relationships, multiplayer, NPC bonds                             | *Stardew Valley* NPC arcs, MMOs                  |
| Narrative        | What happens next?                                                | Story-rich games, *Disco Elysium*                |
| Power fantasy    | Becoming powerful, dominant                                       | RPGs, action games, *Doom Eternal*               |
| Tension/release  | High-stakes moments resolved                                      | Roguelikes, horror, combat-heavy games           |

## Scoring

For each category, score:

- **STRONG** — the loop activates this category clearly and the player will notice
- **WEAK** — partially activated, but not central
- **ABSENT** — does not engage this category

## Decision

| Score profile                          | Verdict                                                              |
| -------------------------------------- | -------------------------------------------------------------------- |
| No category scored STRONG              | Loop has no hook. Revise or abandon.                                 |
| Exactly one STRONG, others ABSENT      | Single-axis loop. Viable but fragile — depends on that one axis holding. |
| One STRONG, several WEAK supporting    | Promising. Most viable indie loops look like this.                   |
| Two or more STRONG                     | Robust. Multi-axis pull, harder to lose the player.                  |
| Three or more STRONG                   | Likely commercial-grade. Verify it's not over-scoped.                |

## Worked example: cod hunts snails to attract bigger predators

| Category         | Score   | Why                                                                      |
| ---------------- | ------- | ------------------------------------------------------------------------ |
| Progression      | STRONG  | Climbing the ecosystem is explicit, observable progression               |
| Mastery          | WEAK    | Hunting has skill but isn't deep without more design                     |
| Discovery        | STRONG  | Layered ecosystem implies new species/regions to find                    |
| Completion       | ABSENT  | No collection or set mechanic implied                                    |
| Social           | ABSENT  | No relationships described                                               |
| Narrative        | WEAK    | Implied food-chain narrative, not foreground                             |
| Power fantasy    | STRONG  | Becoming a top predator is the explicit arc                              |
| Tension/release  | STRONG  | Predator-prey dynamics are inherently tense                              |

Four STRONG, two WEAK. Robust. Worth formalizing — but the systems-architect will need to make the discovery and tension axes concrete (which species, what predator behaviors, what triggers escalation).

## Rule of thumb

If you can describe a candidate loop and not name the hook category that pulls the player into round 2, the loop isn't ready. Ask the user: "What makes you want to do this loop a second time, right after the first?" If the user can't answer, the workshop needs another round.
