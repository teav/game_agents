# game-dev-team

A 17-agent Claude Code plugin for game development from concept to MVP. Two-tier architecture (Conceptual + Platform) connected by a System Spec contract, with paired adversaries at each tier. Initial stack: Bun, Vite, Phaser, TypeScript. Designed to remain portable when switching to Godot or native.

## Install

This plugin is distributed via the `game-dev-marketplace` marketplace:

```
/plugin marketplace add /path/to/game-dev-marketplace
/plugin install game-dev-team@game-dev-marketplace
```

Restart your Claude Code session after install.

## First-run setup

In your game project root:

```
/game-dev-team:init-workspace
```

This scaffolds `docs/game/` with the canonical directory structure each agent reads from and writes to.

## Quickstart

```
@producer Plan the work for a stamina-gated dash mechanic.
```

Or run the whole session as the producer:

```
claude --agent producer
```

## Documentation

| File                     | What's inside                                                          |
| ------------------------ | ---------------------------------------------------------------------- |
| `docs/architecture.md`   | Why the two-tier design exists; the System Spec philosophy; adversaries |
| `docs/phases.md`         | Concept → Prototype → Polish phase model and transition gates           |
| `docs/agents.md`         | Full inventory of all 17 agents, their tools, and how to invoke them   |
| `docs/operations.md`     | Daily flow, hook behavior, doctor usage, maintenance tips              |
| `docs/scaling-up.md`     | Specialist agents added at polish (sound, accessibility-specialist, localization, telemetry, monetization) |
| `docs/migration.md`      | Procedure for porting to a new stack (Godot, native, etc.)             |
| `docs/troubleshooting.md`| Common issues and fixes                                                |

## Components

```
game-dev-team/
├── agents/             # 17 subagent definitions (.md with YAML frontmatter)
├── skills/             # 5 skills with progressive disclosure
│   ├── system-spec/
│   ├── handoff-envelope/
│   ├── init-workspace/
│   ├── concept-workshop/
│   └── doctor/
├── hooks/              # Lifecycle hook configuration
├── scripts/            # Hook scripts (queue-review, surface-queue, log-invocation)
└── docs/               # Human-facing documentation
```

## License

MIT.
