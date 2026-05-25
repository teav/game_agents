# cascade-semantics

Version bumps in upstream artifacts have defined cascade behavior. The bump type determines what downstream artifacts must do.

## Bump types

| Bump   | Example         | Change                                  | Downstream action                                              |
| ------ | --------------- | --------------------------------------- | -------------------------------------------------------------- |
| PATCH  | 0.5.0 → 0.5.1   | Cosmetic, formatting, typo              | None. `based_on` divergence is intentionally ignored.          |
| MINOR  | 0.5.0 → 0.6.0   | Additive — existing meaning preserved   | `based_on` auto-updates on next downstream write. Locks remain valid. |
| MAJOR  | 0.5.0 → 1.0.0   | Breaking — existing meaning changed     | Downstream must be reviewed; re-lock required against new major. |

## What warrants what bump

### GDD
- **PATCH**: typo, formatting, clarification of existing meaning
- **MINOR**: new mechanic added, new section, expanded existing pillar
- **MAJOR**: core loop changed, pillar redesigned, mechanic redefined, retention hypothesis revised

### System Spec
- **PATCH**: comment fix, formatting, regenerated diagram
- **MINOR**: new entity, new component, new system, new event, new state added to a machine
- **MAJOR**: existing entity restructured, system reorganized, event payload changed, performance budget tightened, state machine transitions altered

### Style guide
- **PATCH**: cosmetic clarification
- **MINOR**: new palette color, new asset spec for existing pillar
- **MAJOR**: aesthetic direction changed, palette overhauled, pillar redefined

### World bible
- **PATCH**: typo, fact clarification
- **MINOR**: new character, new lore expansion, new location
- **MAJOR**: tone changed, established facts contradicted, history rewritten

### Mechanic spec
- **PATCH**: clarification, edge case noted
- **MINOR**: new edge case handling, new variation added
- **MAJOR**: rules changed, input scheme altered, success criteria revised

## Procedure for a MAJOR bump

When an agent commits a major version bump:

1. Lock the new major version normally
2. Notify producer in the handoff envelope's `to:` field
3. Producer queries doctor for downstream artifacts with `based_on: <artifact>@<previous-major>`
4. Producer routes a notification to each downstream owner: "Upstream <X> bumped to <new-major>; your <Y> was based_on the previous major; review and re-lock"
5. Each downstream owner reviews the upstream changes. Three possible outcomes:
   - **Re-lock**: downstream artifact still valid; just update `based_on` to new major version
   - **Revise**: downstream needs changes; status reverts to `in_review` until re-locked against new major
   - **Invalidate**: downstream needs full rewriting; status reverts to `draft`
6. Producer logs the cascade in `migration-ledger/` if the bump affects portability

## Procedure for a MINOR bump

1. Lock the new minor version normally
2. Downstream artifacts with `based_on` the previous minor remain valid
3. Next time any downstream artifact is written, its `based_on` auto-updates to the new minor
4. Doctor reports minor divergence as info-level only; no action required

## Procedure for a PATCH bump

1. Commit the patch
2. Downstream `based_on` references are intentionally not updated
3. Doctor does not flag patch divergence

## Cascade chains

A bump in A may force a major bump in B (which is based_on A). The cascade continues to C (based_on B) and so on. **Each link evaluates independently** — A's major change doesn't automatically make B's change major. The owner of B decides whether A's change forces a major bump in B.

Common pattern:
- GDD major bump (core loop changed) → almost always forces System Spec major bump
- System Spec minor bump (new entity added) → usually no impact on platform-lead architecture; minor at most
- Style guide major bump (aesthetic redirected) → forces re-spec of all asset specs, may or may not affect implementation

## Status during cascade

If a `locked` downstream needs revision after an upstream major bump:
- Default: status reverts to `in_review` (re-lock pending review)
- If revision is non-trivial: status reverts to `draft`
- `based_on` field updates only after re-lock

## When in doubt: prefer the larger bump

If unsure whether a change is minor or major, prefer major. Conservative bumping protects downstream consumers from surprise breakage. Cost: one extra review cycle. Benefit: no silent invalidation.

## What this does not address

- **Concurrent edits**: two agents editing the same artifact at the same time. The envelope's version field doesn't lock against this; the underlying filesystem doesn't either. If parallel work becomes common, add file-level locks or migrate to a versioned store.
- **Branch-based work**: this scheme assumes linear version history. If you start branching specs (e.g., experimenting with two design directions), you'll need to extend the version field to include branch identifiers.
