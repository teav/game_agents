# Scaling up at the polish phase

When the project enters the polish phase, you may add specialist agents that were deliberately deferred. This doc describes them — what they do, where they sit, and which existing agents they pair with. Build them when you commit to polishing toward MVP.

The framework reserves these names. Don't claim them for other roles.

## sound-designer

Owns the game's sonic identity, the audio palette, mix architecture, and audio accessibility implementation.

- **Tier:** Conceptual
- **Tools:** Read, Write, Edit, Glob, Grep
- **Color:** blue (unused so far)
- **Skills:** handoff-envelope
- **Owns:** `docs/game/audio/{bible.md, palette.md, sfx/, music/, mix-architecture.md, accessibility.md}`
- **Inputs:** GDD (emotional intent), style guide from art-director (aesthetic alignment), narrative content (voice work and audio drama elements), performance budgets, constraints-critic feedback on audio feasibility
- **Outputs:** sound bible, audio specs (referenced by logical handle like `sfx.jump`), mix bus architecture, audio accessibility plan (subtitles, visual sound cues, captioning conventions)
- **Hard boundaries:** No middleware names (FMOD, Wwise), no engine-specific APIs, no codec specifications — logical handles only, same discipline as art-director
- **Pairing:** existing adversaries (design-critic, fact-checker-conceptual, market-analyst, constraints-critic) cover its outputs; playtest-planner can include audio observation prompts in plans
- **New artifact types:** `sound_bible`, `audio_spec`, `mix_architecture`, `audio_accessibility_plan`

## accessibility-specialist

Takes over from accessibility-critic when the project enters polish. Where the critic catches structural traps at concept/prototype, the specialist implements depth at polish.

- **Tier:** Conceptual (direction); pairs closely with implementation for execution
- **Tools:** Read, Write, Edit, Glob, Grep
- **Color:** green (matches playtest-planner — both are hypothesis/measurement-oriented)
- **Skills:** handoff-envelope
- **Owns:** `docs/game/accessibility/{plan.md, audits/, conformance.md}`
- **Inputs:** locked System Spec, art-director style guide (contrast targets), GDD (control schemes), sound-designer audio accessibility plan, playtest-planner findings from a11y-focused tests
- **Outputs:** accessibility plan, conformance assessments against standards (WCAG 2.2 AA for any UI text/web shell, CVAA for any audio/video), audit reports
- **Pairing:** explicit handoff from accessibility-critic at phase entry — the critic's structural findings become the specialist's implementation backlog; playtest-planner generates accessibility-focused test plans
- **New artifact types:** `accessibility_plan`, `accessibility_audit`, `conformance_assessment`

## localization-lead

Engaged when the project scopes target languages beyond the development language.

- **Tier:** Conceptual
- **Tools:** Read, Write, Edit, Glob, Grep
- **Color:** orange variant — coordinate with existing oranges
- **Skills:** handoff-envelope
- **Owns:** `docs/game/localization/{plan.md, glossary.md, strings/, cultural-notes/}`
- **Inputs:** narrative (text to localize), art-director (text in art assets), GDD (target market context from market-analyst)
- **Outputs:** localization plan (target languages, scope, vendor strategy if applicable), translation glossary, externalized strings inventory, cultural adaptation notes
- **Pairing:** narrative receives localization-friendly guidance from this agent ("don't embed character names in metaphors that don't translate"); build-pipeline handles string externalization tooling
- **New artifact types:** `localization_plan`, `translation_glossary`, `cultural_note`

## telemetry-lead

Engaged when the project decides to instrument for live data.

- **Tier:** Platform
- **Tools:** Read, Write, Edit, Glob, Grep, Bash
- **Color:** cyan (matches platform-tier)
- **Skills:** handoff-envelope
- **Owns:** `docs/game/telemetry/{plan.md, events.md, dashboards.md, privacy.md}`
- **Inputs:** GDD (what player behaviors matter), playtest-planner findings (what's worth measuring at scale), build-pipeline (instrumentation hooks), legal/compliance constraints
- **Outputs:** event taxonomy, dashboard specs, privacy policy alignment, retention policies
- **Pairing:** fact-checker-platform verifies tech claims about telemetry SDKs; build-pipeline implements the instrumentation
- **New artifact types:** `telemetry_plan`, `event_taxonomy`, `dashboard_spec`

## monetization-lead

Engaged when the project is commercial and has decisions to make about pricing, IAP, ads, or other revenue models.

- **Tier:** Conceptual
- **Tools:** Read, Write, Edit, Glob, Grep, WebSearch, WebFetch
- **Color:** yellow variant — coordinate with producer
- **Skills:** handoff-envelope
- **Owns:** `docs/game/monetization/{strategy.md, pricing.md, store-presence.md}`
- **Inputs:** GDD (player fantasy), market-analyst (genre monetization norms), platform constraints (app store rules), legal constraints (regional regulations like COPPA, GDPR)
- **Outputs:** monetization strategy, pricing rationale, IAP/ad/subscription specs as appropriate, store listing copy
- **Pairing:** market-analyst informs; fact-checker-conceptual verifies regulatory claims; build-pipeline implements the integration
- **New artifact types:** `monetization_strategy`, `pricing_rationale`, `store_listing`

## When to add these

Run `/game-dev-team:doctor` after committing to the polish phase. If any of these domains has work-in-progress that isn't being routed (e.g., audio assets accumulating with no owner, accessibility findings stuck in design-critic's queue, untranslated strings in narrative files), add the corresponding agent.

You don't add all five. You add the ones your project's polish scope demands. A free-to-play mobile game probably wants four of five (sound, accessibility, telemetry, monetization). A premium console title probably wants three (sound, accessibility, localization). A solo-dev itch.io release might want only sound and accessibility-specialist.

## How to add one

1. Copy the matching section from this doc into an `agents/<name>.md` file
2. Use the existing agents' structure (Identity → Owns → Inputs → What you do → Hard boundaries → Handoff → Style → Escalation → Per phase)
3. Add the new artifact types to `skills/handoff-envelope/references/artifact-types.md`
4. Add a path matcher to `scripts/queue-review.sh` for the new workspace subdirectory
5. Update `init-workspace/SKILL.md` to scaffold the new workspace subdirectory
6. Update `docs/agents.md` with the role
7. Bump the team count
8. Re-run `/plugin install` to pick up the new agent

The handoff-envelope, system-spec, and phase model don't need changes — they're stack-stable and polish-stable.
