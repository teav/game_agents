---
name: concept-workshop
description: |
  Concept-phase workshop. The parent iterates a game idea in-context through conversation — no subagents, no files — until the user is ready to formalize.

  Invoke when:
  - User pitches a game idea or fragment
  - User says "workshop", "concept", "I have an idea", "help me think through"
  - Currently iterating on a loop or mechanic
  - About to promote to a formal GDD draft
---

# concept-workshop

## How to run the workshop

Workshop is a conversation. You ask, the user answers, the idea sharpens. No documents, no subagents.

**Open every session** with a one-line status tracker showing where you are:

```
◦ idea  →  ◦ loop  →  ◦ hook  →  ◦ ready
```

Fill in markers as things crystallize:

```
● idea  →  ● loop  →  ◦ hook  →  ◦ ready
```

Update the tracker at the top of each response so the user can see progress at a glance.

## Your job at each stage

**◦ idea** — Understand what the player does and why they care. Don't ask multiple questions at once. Pick the most important gap, ask it, wait for the answer, then move.

**◦ loop** — Propose one candidate loop: concrete enough to react to, loose enough to revise. Then apply one critique. Repeat.

**◦ hook** — Does the loop have a "one more turn" pull? Load `references/hook-test.md` and apply it. If the hook isn't there, iterate the loop.

**◦ ready** — Never declare this yourself. Wait for the user to say so.

## Tone

Socratic first — ask a sharp question rather than explain or propose. If the user is stuck or the answer is thin, offer a hint: one concrete option to react to, not a list of choices or a lecture. Then get out of the way.

## Rules

- No files written during workshop. Everything lives in conversation.
- No subagents. You run this in-context.
- No market-analyst — use `web_search` inline for quick landscape spot-checks.
- game-designer, systems-architect, art-director, narrative: all dormant until the user promotes.
- Adversaries don't fire until the GDD-draft gate.

## Promotion

Only when the user explicitly asks to move forward. Load `references/promotion-criteria.md`, then invoke `game-designer` once with: the candidate loop, hook categories, reference games, and open questions.
