---
name: handoff-envelope
description: |
  YAML front-matter that prefixes every artifact in the game-dev-team workspace. The Producer routes work by reading these envelopes.

  Invoke this skill when:
  - About to write a deliverable file (any agent producing an artifact)
  - Reading an artifact to determine where it should be routed
  - Validating that an artifact has a complete envelope (the Producer's pre-routing check)
  - Looking up which `artifact_type` value an agent should emit
  - The user or another agent mentions "envelope", "front-matter", "routing", or "handoff"
---

# handoff-envelope

## When to load what

| Trigger                                            | Load                                |
| -------------------------------------------------- | ----------------------------------- |
| Need the envelope format right now                 | This file                           |
| Need the full list of valid `artifact_type` values | `references/artifact-types.md`      |
| Writing an adversary critique                       | `references/adversary-format.md`    |
| Bumping a version, or deciding what bump to apply   | `references/cascade-semantics.md`   |
| Updating a `based_on` after upstream changed        | `references/cascade-semantics.md`   |

## Envelope format

```yaml
---
from:           <agent-id>             # producing agent's name
to:             <agent-id> | [list]    # recipients
artifact_type:  <see references/artifact-types.md>
version:        <semver>
gate:           <gate name, if for a gate review>
based_on:       [<file paths or refs this depends on>]
status:         draft | in_review | locked
---
```

## Rules

- Every artifact file begins with the envelope. Files without one are returned to the producer
- `based_on` is required for any derived artifact
- `status: locked` is one-way; changes require a new version
- Adversary outputs include `gate` naming which gate triggered them
- Producer reads only envelopes for routing

For background on routing and the dependency graph, see `docs/architecture.md`.
