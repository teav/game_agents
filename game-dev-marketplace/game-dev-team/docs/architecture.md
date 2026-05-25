# Architecture

The plugin implements a two-tier multi-agent team for game development, connected by a single contract artifact and guarded by paired adversaries.

## The two tiers

**Conceptual Tier** is framework-neutral. Its artifacts (GDD, system spec, style guide, world bible) describe *what the game is*, in language that survives engine changes. Agents in this tier are forbidden from referencing any specific engine, runtime, or library — the System Spec enforces this with a regex check at lock time.

**Platform Tier** is stack-specific. Its artifacts (architecture, task breakdown, perf plan, code, builds) describe *how the game is built* in the current target stack — initially Bun, Vite, Phaser, and TypeScript. Agents here know their stack at expert depth.

The tiers communicate through one interface only: the **System Spec**.

## The System Spec as hot-swap contract

The Spec is the single artifact that flows from Conceptual to Platform. When migrating from Phaser to Godot or native, you replace the Platform Tier agents wholesale but the Spec — and every other Conceptual artifact — is unchanged. This is the entire reason the architecture exists.

If the Spec ever contains engine-specific vocabulary, that contract is broken and migration becomes expensive. The `system-spec` skill's `leakage-check.md` reference encodes the prohibited words as a regex. The Systems Architect runs it before locking any version.

## Adversaries paired with tiers

Each tier has three dedicated adversaries that critique work at defined gates:

- **Conceptual adversaries** (design-critic, market-analyst, fact-checker-conceptual) critique design and market claims only. They cannot challenge platform feasibility.
- **Platform adversaries** (execution-realist, constraints-critic, fact-checker-platform) critique stack feasibility, effort estimates, and technical claims only. They cannot challenge design intent.

Two fact-checkers exist intentionally. The conceptual one verifies empirical design and market claims; the platform one verifies API and benchmark claims. Same posture, completely different evidence bases. Merging them would degrade both.

Every adversary output uses the Position / Falsifier / Alternative structure. A critique without a falsifier is invalid by definition — adversaries must either propose how their position could be disproven (a cheap experiment, a playtest, a spike) or an alternative the team could adopt. This prevents adversaries from becoming pure veto powers.

## Hooks: queue, then close

The PostToolUse hook has two paths. When you write to a watched directory (design, spec, art, narrative, playtest, platform, perf), the hook writes a pending entry to `.review-queue.jsonl` and surfaces a suggested adversary to Claude. When an adversary writes a review file under `docs/game/reviews/`, the hook reads the review's `based_on` field and closes matching pending queue entries automatically.

Together, these two paths give you a queue that fills deterministically on writes and drains deterministically on reviews — no manual JSONL editing, no metric drift. The Producer or user decides *when* to invoke a suggested adversary; the closure is mechanical.

The SubagentStart hook logs every team-agent invocation. This data is what makes auto-delegation tunable over time — if an adversary shows zero invocations after a week, its description field needs sharpening.

## Skills: progressive disclosure

Each skill's top-level `SKILL.md` is short and trigger-rich. Heavy reference content (the full Spec template, the lock checklist, the artifact-types lookup table) lives in `references/` subfiles that load only when the skill's procedure actually needs them. This keeps the model's context light during routine work and loads heavy content only when filling out a spec or running a check.

Skill content is strictly directive — templates, checklists, decision rules, lookup tables. Explanatory prose lives in this `docs/` directory, not in skills. Skills tell the model what to do; docs tell humans how the system works.

## Workshop mode vs gate fan-out

The agent-vs-skill calculus drives a specific pattern in concept phase: workshop iteration happens in the parent's context using the `concept-workshop` skill, while adversaries fire at gates as agents. The parent iterates fragment → loop → hook with the user inline, applying the skill's discipline. Only when a candidate is ready for formalization does the parent invoke game-designer (one agent call), and only when the GDD draft lands do the four conceptual adversaries fire in parallel.

This is intentional: workshop work is sequential, context-dependent, and produces no artifacts — exactly the work pattern skills are built for. Gate work is parallel, isolated, and artifact-producing — exactly the work pattern agents are built for. The system uses each where it fits.

## Marketplace wrapper

The plugin sits inside a marketplace catalog rather than being installed directly. This is intentional even for a single-plugin marketplace — adding `web-dev-team` or `mobile-app-team` later is dropping a sibling directory and appending to `plugins[]` in `marketplace.json`. Users keep their existing installs and add new plugins without touching the marketplace they already trust.
