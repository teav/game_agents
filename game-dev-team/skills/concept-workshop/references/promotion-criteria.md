# promotion-criteria

Run this before invoking `game-designer` to promote a workshop product into a formal GDD draft. All must be checked.

## Checklist

- [ ] **Player verb** is named and specific (not "you do things in the world")
- [ ] **Stakes** are named — the player desire is articulated in one sentence
- [ ] **Loop** is described in one to two sentences
- [ ] **Hook test passed** — at least one STRONG hook category (see `hook-test.md`)
- [ ] **User has agreed** this is the candidate to formalize (no live disagreement)
- [ ] **Reference games** identified — one to three closest neighbors
- [ ] **Open questions are bounded** — no more than five explicit unknowns
- [ ] **Engine vocabulary is absent** from the workshop notes (no Phaser/Godot/Unity)

If any box is unchecked, continue iterating in workshop. Do not invoke game-designer yet.

## What game-designer receives at promotion

Pass to game-designer as the input brief:

```yaml
workshop_product:
  player_verb:        <one sentence>
  stakes:             <one sentence>
  loop:               <one to two sentences>
  hook_categories:    [<list of categories scored STRONG>]
  reference_games:    [<one to three titles>]
  open_questions:     [<bounded list, ≤5>]
  user_agreement:     confirmed
```

Game-designer's job at this point is to formalize, not to iterate further. Iteration was the workshop's job.

## What happens after promotion

1. game-designer writes `docs/game/design/gdd.md@0.1.0 status=draft`
2. PostToolUse hook queues for review
3. Parent fans out adversaries in parallel: design-critic, market-analyst, accessibility-critic, fact-checker-conceptual
4. Each adversary writes a critique to `docs/game/reviews/<adversary>/`
5. PostToolUse hook auto-closes queue entries as reviews land
6. Producer adjudicates critiques
7. If resolved, producer proposes concept lock to user
8. User commits → phase transitions to prototype

## When NOT to promote

- The user is still arguing for a different loop direction — finish that conversation first
- The hook test scored everything WEAK or ABSENT
- The workshop notes contain engine-specific vocabulary (Phaser, Godot, etc.) — clean it up first
- Open questions outnumber answered ones — the workshop isn't done

Promotion is a one-way commitment for the GDD version. Iterate until ready, then promote.
