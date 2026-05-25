---
name: doctor
description: |
  Health check for the game-dev-team workspace. Inspects artifacts, the review queue, dependency chains, and agent invocation patterns; reports gaps and produces concrete next-action recommendations.

  Invoke this skill when:
  - The user runs `/game-dev-team:doctor`
  - The user asks "is the workspace healthy", "any pending reviews", "which agents have been used", or "what's blocking us"
  - The Producer is about to plan a milestone and needs a status snapshot
  - The SessionStart hook surfaces a non-zero review queue and the user wants details
---

# doctor

## When to use

| Trigger                                                  | Output                                                         |
| -------------------------------------------------------- | -------------------------------------------------------------- |
| `/game-dev-team:doctor` (manual invoke)                  | Full report                                                    |
| User asks about workspace health                          | Full report                                                    |
| Producer planning a milestone                             | Full report + suggested next actions                           |
| Review queue surfaced at session start, user wants detail | Focus on queue + adversary coverage sections                   |

## Procedure

Use the Read, Glob, and Bash tools to gather the data. Output the report inline; do not write it to a file by default unless the user asks.

### 0. Phase state

Read `docs/game/phase.md` first. Report:
- Current phase
- Unchecked exit criteria
- Whether any artifact in the workspace was produced by an agent that should be dormant in the current phase (flag as inconsistency)
- Recent transition history (last 3 entries)

This precedes everything else — phase context shapes what's normal vs anomalous in subsequent sections.

### 1. Artifact inventory

For each directory in `docs/game/{design,spec,art,narrative,platform,perf}/`, list every `.md`, `.yaml`, `.yarn`, and `.ink` file. For each artifact, extract from its envelope front-matter: `from`, `artifact_type`, `version`, `status`, `based_on`. Skip files that have no front-matter (flag them in section 2).

Glob pattern:
```
docs/game/design/**/*.md
docs/game/spec/**/*.md
docs/game/art/**/*.md
docs/game/narrative/**/*
docs/game/playtest/**/*.md
docs/game/platform/**/*.md
docs/game/perf/**/*.md
```

### 2. Envelope validation

For every artifact, verify the envelope includes all required fields:
- `from` (matches a known agent name)
- `artifact_type` (matches the producing agent — see `handoff-envelope/references/artifact-types.md`)
- `version` (semver)
- `status` (one of: draft, in_review, locked)
- `based_on` (required for any non-root artifact — gdd may omit it)

Flag every artifact missing one or more fields. These are returned to the producer.

### 3. Dependency graph

Build the dependency graph from `based_on` fields. For every locked artifact, evaluate its based_on references against cascade semantics (see `handoff-envelope/references/cascade-semantics.md`). Report findings by severity:

- **Broken chains** (blocking): `based_on` references a file that doesn't exist. Downstream artifact is genuinely orphaned.
- **Cycles** (blocking): A based_on B based_on A. Rare but worth flagging.
- **Major divergence** (warning): downstream is locked against a previous major of an upstream that has bumped major (e.g., `based_on: gdd.md@0.5.0` when gdd is now at 1.0.0). Needs review and re-lock.
- **Minor divergence** (info): downstream is locked against a previous minor of an upstream that has bumped minor. Auto-updates on next downstream write; no immediate action.
- **Patch divergence**: not reported. Intentionally ignored.

### 4. Review queue

Read `docs/game/.review-queue.jsonl` (line-delimited JSON). Count entries by status:
- `pending`: queued, no review yet
- `addressed`: an adversary has produced output for it
- `dismissed`: producer adjudicated as no-action

For each pending entry, show: timestamp, file, suggested adversaries, age in hours.

### 5. Adversary coverage

Cross-reference: for every locked artifact, has the relevant adversary produced a review since the artifact was locked? Use `docs/game/reviews/<adversary>/` listings.

Mapping:
- `design/` locked artifacts → expect `design-critic`, `fact-checker-conceptual`, `accessibility-critic` reviews
- `spec/` locked → expect `constraints-critic`, `fact-checker-platform`, `accessibility-critic`
- `platform/` locked → expect `execution-realist`, `constraints-critic`
- `playtest/findings/` synthesized → expect a corresponding update to GDD or open question

Report any locked artifact whose expected review is missing. These are the highest-priority gaps.

### 6. Agent invocation patterns

Read `docs/game/logs/agent-invocations.jsonl`. Compute:
- Invocations per agent in the last 7 days
- Agents never invoked
- Adversaries with zero invocations (probable auto-delegation failure — check their `description` fields)

### 7. Migration ledger

List the last 5 entries in `docs/game/migration-ledger/`. Flag any entries where `reversible: no` and they were added in the last 7 days (recent points of no return).

**Drift check:** Compare write activity in the last 7 days between `docs/game/platform/` and `docs/game/migration-ledger/`. Use these bash commands:

```bash
PLATFORM_WRITES="$(find docs/game/platform -type f -mtime -7 2>/dev/null | wc -l)"
LEDGER_WRITES="$(find docs/game/migration-ledger -type f -mtime -7 2>/dev/null | wc -l)"
```

- If `PLATFORM_WRITES > 0` and `LEDGER_WRITES == 0` → flag as **drift warning**: "Platform tier had N writes this week but migration ledger received none. Either no portability-affecting decisions were made (unlikely under active development) or they're going unlogged."
- If both > 0 → healthy.
- If both == 0 → no activity (normal for concept phase or quiet weeks).

The drift warning is the highest-priority recommendation when it fires. Stale ledger compounds: every undocumented decision is one the future migration has to rediscover.

## Report format

```markdown
# game-dev-team doctor report
Generated: <ISO timestamp>
Project: <project path>

## Artifact inventory
| Path                              | Type           | Version | Status     | Last touched |
| --------------------------------- | -------------- | ------- | ---------- | ------------ |
| design/gdd.md                     | gdd            | 0.5.0   | locked     | 3d ago       |
| spec/system-spec.md               | system_spec    | 0.4.0   | in_review  | today        |
...

## Envelope issues
⚠ design/mechanics/dash.md — missing `based_on`
✓ all others valid

## Dependency graph
- spec/system-spec.md@0.4.0 → design/gdd.md@0.5.0 ✓
- art/style-guide.md@0.2.0 → design/gdd.md@1.0.0 ⚠ **major divergence** (was @0.4.0; needs re-lock review)
- narrative/world-bible.md@0.3.0 → design/gdd.md@0.6.0 ℹ minor divergence (will auto-update on next write)

## Review queue (3 pending)
| File                              | Section | Suggested adversaries        | Age   |
| --------------------------------- | ------- | ---------------------------- | ----- |
| design/gdd.md                     | design  | design-critic, fact-checker  | 2d    |
| spec/system-spec.md               | spec    | constraints-critic           | 4h    |
| platform/architecture.md          | platform| execution-realist            | 1d    |

## Adversary coverage gaps
⚠ design/gdd.md@0.5.0 locked 3d ago — no design-critic review
⚠ spec/system-spec.md — has at_risk item AR-001 — no constraints-critic spike

## Agent invocations (last 7 days)
| Agent                | Invocations |
| -------------------- | ----------- |
| game-designer        | 8           |
| systems-architect    | 4           |
| platform-lead        | 3           |
| design-critic        | 0   ⚠ (auto-delegation may be failing)
| market-analyst       | 1           |
| ...                                |

## Migration ledger
Last entry: 2 days ago — added dependency `phaser-tweens-plus` (reversible: yes)
Recent irreversible: none
⚠ **Drift warning**: platform/ had 4 writes this week, ledger had 0. Likely undocumented decisions.

## Recommendations
1. Invoke `@design-critic` on design/gdd.md@0.5.0 (locked 3d, no review)
2. Run a constraints-critic spike on AR-001 in the spec
3. Address the missing `based_on` in design/mechanics/dash.md
4. Investigate why design-critic has 0 invocations — possibly tighten its description field
```

## Notes

- This skill is read-only by default. It does not modify artifacts or close pending reviews.
- For closing queue entries: ask the user to update `.review-queue.jsonl` by changing `"status":"pending"` to `"status":"addressed"` or `"dismissed"` for the relevant line.
- If the workspace doesn't exist yet, suggest the user run `/game-dev-team:init-workspace`.
