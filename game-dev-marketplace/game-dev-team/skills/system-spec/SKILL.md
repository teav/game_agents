---
name: system-spec
description: |
  The framework-neutral contract between Conceptual Tier and Platform Tier. Owned by systems-architect, consumed by platform-lead. Lives at docs/game/spec/system-spec.md.

  Invoke this skill when:
  - Creating, reading, or updating a System Spec
  - About to lock a spec version (run the self-check)
  - Reviewing a spec for engine leakage
  - An agent asks "what does the spec say about X" or "where does X live in the spec"
  - The user mentions "spec", "system spec", "the contract", "spec lock", or "spec template"
---

# system-spec

## When to load what

| Trigger                                     | Load                          |
| ------------------------------------------- | ----------------------------- |
| Creating or updating the spec               | `references/template.md`      |
| About to transition spec status to `locked` | `references/self-check.md`    |
| Reviewing spec for engine leakage           | `references/leakage-check.md` |

## Rules

- Spec lives at `docs/game/spec/system-spec.md`
- Spec must not reference any specific engine, runtime, library, or platform API. Run `references/leakage-check.md` to verify
- Status transitions: `draft` → `in_review` → `locked`. Locked is one-way; changes go in a new version
- Version with semver in the envelope front-matter (see `handoff-envelope` skill)
- If a section can only be expressed in engine-specific vocabulary, escalate to producer

For background on why the spec is structured this way, see `docs/architecture.md`.
