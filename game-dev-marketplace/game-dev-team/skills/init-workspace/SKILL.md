---
name: init-workspace
description: |
  Scaffold the docs/game/ workspace structure for the game-dev-team plugin.

  Invoke when:
  - User says "set up the game dev workspace", "init the game dev team", "scaffold the docs structure"
  - The team is being used in a project that doesn't yet have docs/game/ directories
  - The producer or any agent tries to read docs/game/ and finds it missing
---

# init-workspace

## Steps

1. Create the directory structure:

```bash
mkdir -p docs/game/{design,spec,art,narrative,playtest/{plans,reports,findings},platform,perf,reviews/{design-critic,market-analyst,fact-checker-conceptual,accessibility-critic,execution-realist,constraints-critic,fact-checker-platform,transitions},logs,migration-ledger}
```

2. Initialize the phase tracker:

```bash
cat > docs/game/phase.md <<'INNER_EOF'
# Phase state

Current phase: concept
Entered: <set on first commit>
Entered by: <human>

## Open exit criteria
- [ ] Core loop articulated in one paragraph
- [ ] Three or more retention hypotheses written
- [ ] Market-analyst differentiation statement signed
- [ ] Design-critic critique addressed or deferred (logged)
- [ ] Accessibility-critic structural review passed
- [ ] Reference games identified
- [ ] Open questions bounded
- [ ] Human commits to prototyping

## Transition history
(empty — record transitions here as they happen)
INNER_EOF
```

3. Create the workspace orientation file:

```bash
cat > docs/game/README.md <<'INNER_EOF'
# Game workspace

Canonical workspace for the game-dev-team plugin. Each subdirectory is owned by specific agents.

| Path                   | Owner             | Purpose                                              |
| ---------------------- | ----------------- | ---------------------------------------------------- |
| `design/`              | game-designer     | GDD, mechanic specs, progression                     |
| `spec/`                | systems-architect | System Spec (framework-neutral contract)             |
| `art/`                 | art-director      | Style guide, asset specs, palette                    |
| `narrative/`           | narrative         | World bible, characters, dialogue, content data      |
| `platform/`            | platform-lead     | Stack-specific architecture, task breakdown          |
| `perf/`                | performance       | Profile reports, regression alerts                   |
| `reviews/<adversary>/` | adversaries       | Gate critiques, verifications                        |
| `logs/`                | producer          | Routing log, adjudication log, invocations log       |
| `migration-ledger/`    | producer          | Stack-specific decisions                             |

Every artifact file starts with a handoff envelope.
INNER_EOF
```

4. Initialize the producer's tracking files:

```bash
cat > docs/game/logs/adjudication.log <<'INNER_EOF'
# Adjudication log
# Format: <timestamp> | <adversary> | <objection> | <decision: address|defer|override> | <reasoning>
INNER_EOF

cat > docs/game/logs/routing.log <<'INNER_EOF'
# Routing log
# Format: <timestamp> | <from-agent> | <to-agent> | <artifact_type> | <reason>
INNER_EOF

cat > docs/game/migration-ledger/README.md <<'INNER_EOF'
# Migration ledger

Every stack-specific decision goes here. When migrating stacks, this file is the diff to address.

Per entry: date, decision, alternatives considered, portability impact, reversible (yes/no).
INNER_EOF
```

5. Confirm with `ls -la docs/game/`.
6. Tell the user the workspace is ready and they can start with `@producer`.
