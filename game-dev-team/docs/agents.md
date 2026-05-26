# Agents

Full inventory of the team, organized by tier.

## Conceptual Tier (framework-neutral)

| Agent                       | Role                                                                                |
| --------------------------- | ----------------------------------------------------------------------------------- |
| `producer`                  | Orchestrator, routing, adjudication, migration ledger                               |
| `game-designer`             | GDD, mechanics, loops, progression — all expressed in player-facing terms only      |
| `systems-architect`         | The framework-neutral System Spec (the contract). The most important role on the team. |
| `art-director`              | Style guide, palette, asset specs (engine-neutral, resolution-independent)          |
| `narrative`                 | Story, world, characters, dialogue — delivered as data, not engine calls            |
| `playtest-planner`          | Generates test plans tied to design hypotheses; ingests human playtest reports; synthesizes findings. Paired with design-critic. |
| `design-critic`             | Adversary: design weaknesses, fun-killers, untested retention assumptions           |
| `market-analyst`            | Adversary: competitive landscape, saturation, differentiation                       |
| `accessibility-critic`      | Adversary: structural accessibility traps in concept and prototype; dormant in polish (see `scaling-up.md`) |
| `fact-checker-conceptual`   | Adversary: verifies empirical claims in design and market work                      |

## Platform Tier (stack-specific, swappable)

Initial stack: Bun + Vite + Phaser + TypeScript. Swap these agents when targeting Godot or native.

| Agent                       | Role                                                                                |
| --------------------------- | ----------------------------------------------------------------------------------- |
| `platform-lead`             | Stack architecture, task breakdown, perf plan. The other hinge — consumes the Spec. |
| `implementation`            | Writes the actual code following platform-lead's tasks                              |
| `performance`               | Profiling, optimization, regression alerts (v8 / WebGL specifics in this stack)     |
| `build-pipeline`            | Build configs, asset pipeline, CI, deployment artifacts                             |
| `execution-realist`         | Adversary: challenges effort estimates within the current stack                     |
| `constraints-critic`        | Adversary: surfaces what the stack genuinely cannot do well                         |
| `fact-checker-platform`     | Adversary: verifies API and benchmark claims with primary sources                   |

## Tools and permissions per agent

- **Writers** (producer, game-designer, systems-architect, art-director, narrative, playtest-planner, platform-lead, performance, build-pipeline): `Read, Write, Edit, Glob, Grep` plus `Bash` for platform-tier writers
- **Coder** (implementation): full toolset including `Bash`
- **Adversaries**: `Read, Write, Glob, Grep` only — they can file critiques but cannot modify game artifacts. The market-analyst and both fact-checkers also get `WebSearch, WebFetch` for sourcing.

These restrictions are enforced by the `tools:` field in each agent's frontmatter, not by social contract.

## Invocation

Three ways:

1. **Natural language.** Mention the agent in your prompt; Claude delegates. Best for routine work.
2. **`@-mention`.** Pick from the typeahead; forces delegation to that specific agent for one task.
3. **Session-level.** `claude --agent producer` makes the producer the main thread for the entire session. Recommended for coordination-heavy work.

See the operations doc for how to invoke gate reviews and drain the queue.

## Customizing per-stack

When migrating to a different stack, rewrite these six files:
- `agents/platform-lead.md` — replace stack-specific content
- `agents/implementation.md` — replace stack assumptions
- `agents/performance.md` — replace profiling approach
- `agents/build-pipeline.md` — replace bundler/CI assumptions
- `agents/execution-realist.md` — its failure modes become stack-specific
- `agents/constraints-critic.md` — its constraint set becomes the new stack's
- `agents/fact-checker-platform.md` — its primary-source list becomes the new stack's docs

The other 8 agents and all 4 skills are unchanged across stacks. See the migration doc for the full procedure.
