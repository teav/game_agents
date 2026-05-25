# Operations

How to use the team day to day, what the hooks do, and what to tune as you go.

## Daily flow

1. **Start any new feature with the producer.** `@producer` reads pending queue entries, the migration ledger, and routes work to the right specialist. Running an entire session as the producer (`claude --agent producer`) is the recommended default for ongoing coordination.

2. **Specialists work in their owned subdirectories.** Game designer writes to `docs/game/design/`, systems architect to `docs/game/spec/`, etc. Each artifact begins with a handoff envelope (see the `handoff-envelope` skill).

3. **Writes to watched paths get queued automatically.** The PostToolUse hook detects any write under `docs/game/{design,spec,art,narrative,platform,perf}/` and appends an entry to `.review-queue.jsonl`. The hook surfaces a suggested adversary to Claude via `additionalContext`.

4. **Adversaries fire at gates.** Either Claude acts on the hook's suggestion, the producer drains the queue between tasks, or you invoke an adversary explicitly (`@design-critic review docs/game/design/gdd.md`). Adversary outputs go to `docs/game/reviews/<adversary>/` and the queue entry is **auto-closed by the PostToolUse hook** when the review file's `based_on` matches the queued artifact. No manual JSONL editing required.

5. **Producer adjudicates objections.** Every adversary objection lands as a Position/Falsifier/Alternative. Producer decides: address (route back to specialist), defer (with a deadline), or override (with reasoning logged in `adjudication.log`). For overrides without further review, the producer may mark a queue entry `dismissed` manually; otherwise auto-closure handles it.

6. **Parallel routing is the default for independent work.** When multiple specialists can work without depending on each other's output, the producer spawns them in a single turn (multiple Task calls). Serialization happens only where dependencies require it.

## Hook behavior in practice

| Hook            | Fires on                       | Writes to                                | Surfaces to Claude                              |
| --------------- | ------------------------------ | ---------------------------------------- | ----------------------------------------------- |
| `PostToolUse`   | `Write`/`Edit`/`MultiEdit`     | `.review-queue.jsonl`                    | "Queued review for <path>; suggested: <agent>"  |
| `SessionStart`  | Session begins                 | (none — read-only)                       | Queue depth + recent ledger growth summary      |
| `SubagentStart` | Any plugin agent invoked        | `agent-invocations.jsonl`                | (silent — data for /doctor)                     |

Hooks never block tool calls. They queue and inform. If a hook crashes, work continues — the script is wrapped to exit 0 in all error paths.

The hooks need `jq` on the system. If `jq` is missing, the hook scripts silently no-op so they don't break the session. Doctor will report if recent writes weren't queued.

## Doctor

Run `/game-dev-team:doctor` to get a workspace health snapshot. The skill walks `docs/game/`, validates envelopes, builds the dependency graph from `based_on` fields, reports queue depth, and reads `agent-invocations.jsonl` to surface usage patterns.

Run it before any milestone or when something feels off. The Producer preloads this skill so it can run mid-session without context overhead.

## Maintenance — what to tune after using the team for a few days

These are the operational refinements that come up in practice. None of them require touching the agents or skills; they're configuration adjustments.

### 1. Tune the hook's path-to-adversary mapping

The PostToolUse hook's static path mapping in `scripts/queue-review.sh` is a starting point, not a permanent answer. As you learn which reviews matter for your specific game, edit the `case` block:

```bash
*/docs/game/design/economy.md)
  SECTION="economy"
  ADVERSARIES="design-critic, market-analyst"   # add market-analyst for economy work
  ;;
```

Common refinements: routing economy files to market-analyst, routing narrative changes that affect mechanics to game-designer for review, distinguishing tutorial design (needs design-critic) from late-game design (needs both critics).

Edit the script, re-validate, no plugin reinstall needed — Claude Code picks up hook script changes on the next event.

### 2. Watch `agent-invocations.jsonl` for auto-delegation gaps

After a week of real use, run doctor and look at the "Agent invocations" section. Any adversary at zero invocations is almost certainly an auto-delegation failure. The most common cause: the `description` field in the agent's frontmatter isn't matching the user's natural phrasing.

Fixes, in order of effectiveness:

1. Add explicit trigger phrases to the description. "Use proactively when..." beats "Specialist for...".
2. Include the exact words users tend to use. If users say "is this realistic to build", add that phrase to execution-realist's description.
3. Add the file paths the agent operates on, so Claude correlates path-based requests with the right delegate.

### 3. Sharpen under-invoked agent descriptions

If a specialist (not an adversary) is under-invoked, it might be that the producer is absorbing work that should be routed. Check `routing.log` — if producer is making design decisions instead of routing to game-designer, that's the symptom. Tighten the producer's "Hard boundaries" section to be more explicit about what it does *not* do.

### 4. Factor shared hook scripts before adding sibling plugins

The first sibling plugin (`web-dev-team`, `mobile-app-team`, etc.) will want the same hook architecture: queue reviews on writes to a watched directory, log invocations, surface a queue at session start, provide a doctor. Before building the second plugin, move the shared scripts to `game-dev-marketplace/lib/` and have each plugin's `scripts/` reference them by path.

The plugin's `hooks/hooks.json` can call any script on disk, not just those inside the plugin. `${CLAUDE_PLUGIN_ROOT}/../lib/queue-review.sh` works.

### 5. Periodically clear the queue

If `.review-queue.jsonl` grows past ~50 pending entries, the team isn't running adversaries at the rate of writes. Either:
- The producer needs to drain the queue between tasks more aggressively
- The hook's path mapping is too broad and is queueing trivial edits
- Some adversaries should fire automatically rather than on suggestion (in which case, add a SubagentStop hook that fires the next pending review — but consider this carefully; auto-firing is the design choice the plugin explicitly avoided)

### 6. Migrate the team prompt when the project's scope changes

The 17 agents are generic enough for most game projects, but their descriptions reference "game" extensively. If you fork this for non-game work, the producer prompt and the adversary descriptions are where most of the editing happens — the System Spec template structure is mostly domain-neutral and survives the move.

### 7. Version bumps follow cascade semantics

Version bumps on artifacts are not equal. The `handoff-envelope/references/cascade-semantics.md` skill defines three bump types — PATCH (cosmetic, no downstream action), MINOR (additive, `based_on` auto-updates), MAJOR (breaking, downstream must re-lock). When you find yourself unsure whether a change is minor or major, default to major. The cost is one extra review cycle; the benefit is preventing silent invalidation of downstream specs and assets.

Doctor reports cascade divergence at three severity levels: broken chains and cycles are blocking, major divergence is a warning needing review, minor divergence is info-only and self-heals on next write. Patch divergence is intentionally not reported.

### 8. Model assignments per agent

Agents are pre-assigned to model tiers in their `model:` frontmatter:

- **inherit** (4 hinges): producer, game-designer, systems-architect, platform-lead. Use the session model — Opus when you're on Opus. Hinges define cascading work; their reasoning depth matters.
- **sonnet** (11 workhorses): art-director, narrative, playtest-planner, implementation, performance, build-pipeline, design-critic, market-analyst, accessibility-critic, constraints-critic, execution-realist. Explicit downgrade from Opus when the parent session is on Opus. Sonnet handles structured outputs, code, creative writing, and bounded critique well.
- **haiku** (2 procedural): fact-checker-conceptual, fact-checker-platform. Verification follows a fixed procedure — search, synthesize, report in a defined format. Haiku is sufficient and much cheaper for high-volume use.

To override per agent for a specific project, edit the `model:` line in that agent's `.md` file. Common overrides:

- Bump market-analyst to inherit if commercial differentiation analysis is recurring bottleneck
- Bump accessibility-critic to inherit if shipping to populations where a11y risk is high
- Force hinges to opus explicitly if you want guaranteed reasoning depth even when running Sonnet sessions (locks you into Opus billing for those agents)

Token cost shape: running a parent session on Opus with the default assignments cuts subagent token spend ~50-70% versus all-Opus, with no observable quality drop. Exact savings depend on agent activation mix.
