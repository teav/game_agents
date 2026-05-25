# Troubleshooting

## Auto-delegation isn't firing for a specific agent

**Symptom:** `agent-invocations.jsonl` shows zero or very few invocations for an agent that should be active.

**Diagnose:** Run `/game-dev-team:doctor` and look at the agent invocations section. Also check `routing.log` — if the producer is making decisions in that domain instead of routing, that's the symptom.

**Fix:** Sharpen the agent's `description` field in its frontmatter. Specifically:

- Add explicit "Use proactively when..." or "Use immediately when..." patterns
- Include the exact phrases users type ("is this realistic to build" for execution-realist, "what's the genre saturation" for market-analyst)
- Reference the file paths the agent owns so Claude correlates path-based requests with the agent
- Avoid generic words like "specialist" or "expert" without context

Reload the session after editing.

## Adversary returned an invalid critique

**Symptom:** Producer or fact-checker reports an adversary output is missing a required field.

**Cause:** Adversary outputs require Position, Falsifier, and Alternative sections. A critique without a falsifier is invalid by definition.

**Fix:** Return it to the adversary with the missing field named. The skill `handoff-envelope/references/adversary-format.md` has the canonical structure.

## Hook isn't queuing reviews

**Symptom:** You write to `docs/game/design/gdd.md` and nothing appears in `.review-queue.jsonl`.

**Diagnose, in order:**

1. **Is `jq` installed?** The hook scripts require it. The SessionStart hook now warns explicitly at session start if `jq` is missing — check session start output for "⚠️ game-dev-team: `jq` is not installed." Install with `apt-get install jq` (Debian/Ubuntu) or `brew install jq` (macOS).
2. **Is the file actually under `docs/game/{watched-subdir}/`?** The hook only fires for design/, spec/, art/, narrative/, playtest/, platform/, perf/. Edits to `docs/game/logs/` or `docs/game/migration-ledger/` are intentionally not queued.
3. **Is the script executable?** `ls -l scripts/queue-review.sh` should show `-rwxr-xr-x`. If not, `chmod +x scripts/*.sh`.
4. **Did Claude Code load the hooks?** Restart the session — hooks load at session start.

## Queue keeps growing

**Symptom:** `.review-queue.jsonl` has 50+ pending entries.

**Cause:** Adversaries aren't being run at the rate of writes. The auto-closure hook closes entries when adversaries write reviews whose `based_on` matches the queued file — so a growing queue means reviews aren't being written, not that closures are being missed.

**Fix:**

- Run `/game-dev-team:doctor` to see the pending list
- For each old entry: invoke the suggested adversary (auto-closure marks the entry `addressed` on review write)
- If most entries are trivial edits (typo fixes, formatting), tighten the hook's path matching in `scripts/queue-review.sh` to exclude minor edits
- If the producer wants to skip review on a specific entry without invoking an adversary, set `"status":"dismissed"` directly in the JSONL with reasoning in `adjudication.log`
- Consider running `claude --agent producer` for a dedicated drain session

The queue is the system of record. The auto-closure hook means the only manual queue edits are explicit dismissals.

## Engine names appearing in System Spec

**Symptom:** The leakage-check regex hits in `docs/game/spec/system-spec.md`.

**Cause:** Either the Systems Architect leaked, or content from an earlier stack-coupled session crept in.

**Fix:** Section by section, rewrite the leaks using the replacement table in `skills/system-spec/references/leakage-check.md`. The most common leaks are:

- `GameObject` → `entity`
- `Tween` → "interpolation over time" with start/end/duration
- `Phaser.Scene` → "state machine state" or "game phase"
- `requestAnimationFrame` → "per-frame tick"

If a leak resists rewriting, the design itself is likely engine-coupled. Route to producer to decide whether to revise the design or accept stack-specific commitment (logged in migration ledger).

## SessionStart hook didn't surface anything

**Symptom:** You started a session, expected the hook to mention pending reviews, but saw nothing.

**Possible reasons (in order of likelihood):**

1. There are genuinely no pending reviews and no recent ledger growth — the hook exits silently in that case.
2. PWD at session start wasn't inside a project with `docs/game/`. The hook walks up from PWD looking for it.
3. `jq` is missing.
4. Hook script lost executable bit.

## Doctor reports broken `based_on` chains

**Symptom:** Doctor flags artifacts whose `based_on` references don't exist.

**Cause:** Usually one of:

- Someone renamed or moved an artifact without updating downstream `based_on` fields
- An artifact's version got bumped but downstream artifacts still reference the old version
- A draft artifact was deleted but downstream specs were already built on it

**Fix:** Update the `based_on` field in the affected downstream artifacts to point to the current version. If the dependency is genuinely broken (the upstream artifact was deleted), the downstream needs to be revised or invalidated.

## Producer is making design decisions

**Symptom:** `routing.log` shows the producer answering design questions directly instead of routing to game-designer.

**Cause:** The producer's "Hard boundaries" section is being interpreted softly, or the user is asking the producer questions that bypass routing.

**Fix:** Either re-emphasize boundaries in the producer's prompt, or address the user — they may be conflating "produce" with "design." The producer's job is dispatch and adjudication, not creative work.

## Two agents are deadlocked on an adjudication

**Symptom:** An adversary objection has been routed back and forth more than once without resolution.

**Procedure:** This is what the producer escalates to the human stakeholder. The plugin design accepts that some disputes can't be resolved within the agent team — that's the producer's escalation rule.

Log the deadlock in `adjudication.log` with the open questions clearly stated, then ask the user to break the tie.
