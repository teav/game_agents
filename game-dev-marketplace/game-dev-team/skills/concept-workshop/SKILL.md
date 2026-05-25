---
name: concept-workshop
description: |
  Discipline for concept-phase workshop iteration. The parent (not a subagent) uses this skill to iterate fragment → loop → hook → ready-for-GDD in-context. Adversaries do not fire during workshop; they fire at the GDD-draft gate.

  Invoke this skill when:
  - Phase is concept and the user pitches a fragment, idea, or partial concept
  - User says "let's workshop X", "I have an idea", "help me think about Y"
  - Currently iterating on a loop or mechanic before formalization
  - About to promote a workshop product to a formal GDD draft (load promotion criteria)
  - The user mentions "concept", "pitch", "workshop", "the loop", or "the hook"
---

# concept-workshop

## When to load what

| Trigger                                     | Load                                      |
| ------------------------------------------- | ----------------------------------------- |
| Starting a workshop on a fresh pitch        | This file (readiness check)               |
| Pressure-testing a candidate loop           | `references/hook-test.md`                 |
| About to invoke game-designer to formalize  | `references/promotion-criteria.md`        |

## Pitch readiness check

Run this on every new pitch before iteration. The pitch needs all three:

1. **Player verb** — what does the player do?
2. **Stakes** — why does the player care?
3. **Loop hint** — what's the rhythm of play?

If any are absent or contradictory: do not iterate, do not propose loops. Ask the user for the missing essentials with one-sentence clarifying questions. Workshop only begins when readiness passes.

## The workshop loop (parent runs this in-context)

Once readiness passes, iterate with the user:

1. **Propose a candidate loop.** Concrete enough to evaluate, vague enough to revise.
2. **Apply the hook test.** Does this loop have a "one more turn" pull? Load `references/hook-test.md`.
3. **Critique inline.** What's weak, untested, likely to fall apart.
4. **Iterate.** Adjust based on user reactions and your own critique. Multiple rounds are expected.
5. **Stop when the loop has a hook.** A clear "one more turn" mechanism, a stake the player cares about, and a rhythm that survives the first imagined hour of play.

## Rules during workshop

- Adversaries do NOT fire during workshop. The discipline is in this skill; the parent applies it inline. Adversaries fire at the GDD-draft gate.
- No file artifacts are produced during workshop. Workshop output lives in conversation until promotion.
- The parent may use `web_search` for landscape spot-checks ("are there games like X?") and `web_fetch` for specific titles the user references. Do not invoke `market-analyst` for this — inline search is sufficient at workshop level.
- Do not invoke `game-designer`, `systems-architect`, `art-director`, or `narrative` during iteration. Those are dormant in concept phase except for the one game-designer invocation at promotion.

## When to promote

When the workshop product passes the promotion criteria (see `references/promotion-criteria.md`), invoke `game-designer` once with the workshop product as input. Game-designer writes the formal GDD draft, the PostToolUse hook queues it, and the parent fans out adversaries in parallel for the gate review.

The handoff from workshop to game-designer should include: the candidate loop, the named hook categories, identified reference games, and the bounded open questions.
