# Migration

The whole point of the two-tier architecture is that switching stacks is cheap. This doc covers the procedure.

## What changes when porting to a new stack

| File                                     | Action                                                    |
| ---------------------------------------- | --------------------------------------------------------- |
| `agents/platform-lead.md`                | Rewrite for the new stack                                 |
| `agents/implementation.md`               | Rewrite for the new stack                                 |
| `agents/performance.md`                  | Rewrite for the new stack                                 |
| `agents/build-pipeline.md`               | Rewrite for the new stack                                 |
| `agents/execution-realist.md`            | Rewrite — failure modes become stack-specific             |
| `agents/constraints-critic.md`           | Rewrite — constraint set becomes stack-specific           |
| `agents/fact-checker-platform.md`        | Rewrite — primary-source list becomes stack-specific      |
| `scripts/queue-review.sh`                | Update path matchers if directory structure changes       |

That's it. Seven agent prompts and possibly one hook script.

## What does not change

- All Conceptual Tier agents (8 files)
- All skills (4 files including references)
- The handoff envelope format
- The System Spec template
- The directory structure under `docs/game/`
- All existing artifacts: GDD, system-spec, style guide, world bible, content data

## The migration ledger

`docs/game/migration-ledger/` is the file the platform-lead and implementation update every time they make a stack-specific decision. When you migrate, this ledger IS the diff to address.

Typical entries:
- "Chose Phaser physics arcade body over matter for collision — Godot equivalent is built-in"
- "Added dependency phaser-tweens-plus — Godot has tweens natively, native may need a library"
- "Wrote scene transition shim around Phaser scene lifecycle — Godot uses node tree"

Each entry has: date, decision, alternatives considered, portability impact, reversible (yes/no).

## Migration procedure

1. **Audit the ledger.** Read every entry. Categorize: trivial (no replacement needed), substitution (find equivalent), rewrite (no analog in new stack).
2. **Identify breaking spec-tier impacts.** If any ledger entry says "had to add to system-spec to support this" — that's a leak that needs un-leaking before migration. Run the leakage check on the Spec.
3. **Replace the seven platform-tier files.** Use the existing ones as a structural template; replace stack-specific content.
4. **Rewrite the implementation.** This is the bulk of the actual work, but it's driven by the unchanged Spec, so the surface area is bounded.
5. **Update the hook script's path matchers** if the new workspace structure differs (it usually shouldn't).
6. **Re-run the new platform-tier agents on the existing locked specs.** They should be implementable without spec changes. If any aren't, that's a real signal the Spec was leaking into the original stack.

## Common pitfalls

- **The Spec contains stack-specific concepts that nobody flagged.** Run `system-spec/references/leakage-check.md` before migrating. Don't trust that the original Spec was clean.
- **The migration ledger is stale.** If the team got busy and stopped logging, you'll discover dependencies the hard way. The doctor skill flags ledger growth weekly; running doctor regularly prevents this.
- **The new stack has constraints the old one didn't.** The new constraints-critic will surface these on the existing Spec. Treat its objections as input to a Spec revision, not as bugs in the migration.
- **Performance budgets need re-validation.** The Spec's performance budgets (Section 2) were derived against the old stack's capabilities. They're still aspirational targets, but the new performance-engineer needs to confirm feasibility on the new stack before the team commits.

## When migration reveals Spec problems

Sometimes the migration surfaces that the Spec was actually leaking — a System assumed a specific engine behavior, or a Resource handle implied a specific format. When this happens:

1. Pause the migration.
2. Route the leak to the original Systems Architect (or whoever is now in that role).
3. Patch the Spec, lock a new version, then resume.

This is rare in practice if the spec lock self-check was run rigorously. But it does happen, and the architecture is built to absorb it — the Spec is the contract, and contracts get amended.
