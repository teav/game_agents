# Phases

The team operates in three phases. Each phase has different active agents, different artifact depths, and explicit exit criteria. Transitions are manual — proposed by anyone, gated by adversary review, committed by the human.

## Why phases

Different concerns matter at different times. Audio identity matters for ship; it doesn't matter for proving the core loop works. Localization matters for global launch; it doesn't matter for verifying the concept has legs. Without a phase model, every agent would fire constantly and polish concerns would pollute concept work. With phases, concerns surface when they're cheap to address and decisive to ignore.

## The three phases

### Concept

Prove the idea has legs. Get to a defensible answer for "is this worth building?"

**Workshop mode:** Concept-phase iteration happens in the parent's context, not in subagent fan-outs. The producer (running as the parent) loads the `concept-workshop` skill, runs the pitch readiness check, and iterates with the user on fragment → loop → hook until a promotion-ready candidate emerges. Agents are reserved for gates and formal artifacts.

**Active agents (invoked at gate only, not during workshop):**
- producer (orchestrator, running in parent context with `concept-workshop` skill loaded)
- game-designer (invoked once per concept attempt — to promote the workshop product into a formal GDD draft)
- design-critic (gate fan-out on the GDD draft)
- market-analyst (gate fan-out on the GDD draft)
- accessibility-critic (gate fan-out on the GDD draft)
- fact-checker-conceptual (gate fan-out on the GDD draft)

**Dormant agents:**
- art-director, narrative, systems-architect — workshop-level reasoning about visuals, tone, and system shape happens inline in the parent context. Full engagement begins at prototype.
- platform-lead, implementation, performance, build-pipeline, playtest-planner — no platform work in concept.
- Platform-tier adversaries — nothing platform to critique.

**The concept flow:**

```
User pitch
   ↓
Parent runs pitch readiness check (concept-workshop skill)
   ├─ fails → escalate to user for missing essentials
   └─ passes
       ↓
Parent iterates with user in-context
   • propose candidate loop
   • apply hook test
   • critique inline
   • iterate until loop has a hook
       ↓
Workshop product passes promotion criteria
   ↓
Producer invokes game-designer (one agent call)
   ↓
game-designer writes docs/game/design/gdd.md@0.1.0 status=draft
   ↓
PostToolUse hook queues GDD for review
   ↓
Producer fans out four adversaries in parallel:
   design-critic, market-analyst, accessibility-critic, fact-checker-conceptual
   ↓
Auto-closure marks queue entries addressed as reviews land
   ↓
Producer adjudicates critiques
   ↓
If resolved → propose concept lock to user → user commits → phase transition
```

**Exit criteria (all must be checked):**
- [ ] Core loop articulated in one paragraph
- [ ] Three or more retention hypotheses written
- [ ] Market-analyst differentiation statement signed
- [ ] Design-critic critique addressed or deferred (logged)
- [ ] Accessibility-critic structural review passed
- [ ] Reference games identified
- [ ] Open questions bounded
- [ ] Human commits to prototyping

### Prototype

Build the vertical slice. Prove the core loop works in the target stack.

**Active agents:**
- All concept agents continue (with deeper output)
- platform-lead (architecture, task breakdown, perf plan)
- implementation (vertical slice code)
- performance (profile reports against budgets)
- build-pipeline (build configs, test builds)
- playtest-planner (hypothesis-driven test plans against playable builds)
- All platform-tier adversaries (execution-realist, constraints-critic, fact-checker-platform)
- accessibility-critic (spec-level traps — gates the spec lock)

**Output depth shifts:**
- systems-architect locks the spec at 0.x.0
- art-director writes full style guide, palette, asset specs
- narrative writes main story beats and character bibles (full dialogue waits for polish)
- design-critic does mechanic lock reviews
- accessibility-critic gates spec lock — any structural a11y trap blocks the lock

**Exit criteria (all must be checked):**
- [ ] Vertical slice is playable on the lowest target device tier
- [ ] Core loop hypotheses tested via playtest-planner — at least the top 3 confirmed or revised
- [ ] System Spec locked at a stable version
- [ ] Performance budgets met for the vertical slice scope
- [ ] No unresolved at-risk items in the spec
- [ ] Adversary gate review passed (design-critic, constraints-critic, accessibility-critic, execution-realist)
- [ ] Human commits to polishing toward MVP

### Polish (MVP)

Make it shippable. Address the breadth of concerns that don't matter until launch is in sight.

**Active agents:** All prototype agents continue, plus the polish-phase specialists documented in `scaling-up.md`:
- sound-designer (audio identity, mix architecture)
- accessibility-specialist (deep a11y implementation — subtitles, control remapping, color-blind modes, motor accommodations)
- localization-lead (if scoping multilanguage)
- telemetry-lead (if instrumenting for live data)
- monetization-lead (if commercial)

**Phase changes:**
- accessibility-critic goes dormant — handoff to accessibility-specialist
- design-critic shifts to feature-level critique (polish-pass concerns)
- narrative writes full dialogue and branching content
- art-director adds polish passes and accessibility refinements

**Exit criteria:** MVP-specific, defined by the human at phase entry.

## Transitions

Phase transitions are commitments to spend resources differently. They are:

1. **Proposed by anyone.** Producer, specialist, adversary, or human.
2. **Gated by adversary review.** A transition triggers a coordinated critique from the relevant adversaries (concept→prototype: design-critic, market-analyst, accessibility-critic, fact-checker-conceptual; prototype→polish: constraints-critic, execution-realist, accessibility-critic, design-critic).
3. **Adjudicated by producer.** Each adversary objection is addressed, deferred (with deadline), or overridden (with reasoning logged in `adjudication.log`).
4. **Committed by the human.** The final transition is a human decision, not an agent decision. The producer records the commitment in `docs/game/phase.md` with timestamp.

## Phase state

The current phase lives in `docs/game/phase.md`, owned by the producer. It records:

```markdown
# Phase state

Current phase: concept | prototype | polish
Entered: <ISO date>
Entered by: <human commit reference>

## Open exit criteria
- [ ] <unchecked item from current phase>
- [ ] <unchecked item>

## Transition history
- 2026-05-23: concept → prototype (committed by <user>, gate review at docs/game/reviews/transitions/concept-to-prototype.md)
```

## Phase-aware behavior in agents

Each agent's prompt includes a `## Per phase` section specifying its activity and output depth at each phase. The producer reads these alongside the current phase to route work correctly.

If a user request would activate a dormant agent — e.g., asking platform-lead about Phaser specifics during concept — the producer should either (a) defer the request as "premature, queue for prototype," or (b) escalate to the human as "this is a polish/prototype concern surfacing in concept; is that intentional?"
