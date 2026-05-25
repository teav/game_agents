# Adversary output format

Adversary artifacts (any agent ending in `-critic`, `-realist`, `-analyst`, or `-checker`) MUST include `Position`, `Falsifier`, and `Alternative` sections in the body. A critique without a falsifier is **invalid** and returned to the adversary for completion.

## Required structure

```markdown
---
from:           <adversary-id>
to:             <agent being critiqued>
artifact_type:  critique | market_assessment | verification | estimate_critique | constraint_analysis
version:        <semver>
gate:           <which gate triggered this>
based_on:       [<artifact being critiqued>]
status:         in_review
---

## Position
[What you object to, in one paragraph. No more than 3 critiques per review.]

## Falsifier
[What evidence, prototype, or playtest result would change your position.
For platform adversaries: spec a concrete spike with inputs and success metric.]

## Alternative
[A concrete alternative the team could adopt, or "I do not see an alternative within current scope."]
```

## Per-adversary variations

| Adversary               | Section adjustments                                                       |
| ----------------------- | ------------------------------------------------------------------------- |
| design-critic           | Standard format                                                           |
| market-analyst          | Replace `Position` with `Competitive set + Saturation read + Differentiation` |
| fact-checker (either)   | Replace with `Verified + Contested + Unverified`                          |
| execution-realist       | Standard format; `Where the pain shows up` instead of `Falsifier` body    |
| constraints-critic      | Standard format; `Falsifier` must spec a concrete spike                   |

## Authority limits (all adversaries)

- Cannot block work. Raises only.
- Producer adjudicates: decisions are logged in `docs/game/logs/adjudication.log`.
- Three critiques per review is the ceiling for design-critic. Pick the strongest three.
- Fact-checkers never assert claims are false — only "verified", "contested", or "unverified".
