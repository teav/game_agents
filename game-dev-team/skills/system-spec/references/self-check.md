# Spec lock self-check

Run this before transitioning a spec version to `locked`. Any unchecked box → status stays `draft` or `in_review`.

## Structural checks

- [ ] Section 0 (Header) has a `spec_id`, `version`, `status`, `owners.architect`, and `last_updated`
- [ ] Section 1 (Concept summary) has all three sub-fields filled (pitch, target session, genre frame)
- [ ] Section 2 (Performance budgets) has numeric values for `target_fps`, `min_fps`, `frame_budget_ms`, `peak_memory_mb`
- [ ] Section 2 has at least one target device tier with a concrete description
- [ ] Section 3 (Resources) uses logical handles only, no file paths or extensions
- [ ] Section 4 (Entities & Components) declares data shapes for every component
- [ ] Section 5 (Systems) — every system declares its `reads`, `writes`, and (if applicable) `emits`
- [ ] Section 6 (Events) — every event declares its `payload`, `emitted_by`, and `listened_by`
- [ ] Section 7 (State machines) — every machine declares its `initial` state and all transitions
- [ ] Section 8 (Data flows) describes a complete per-tick sequence
- [ ] Section 9 (Invariants) lists at least three concrete invariants
- [ ] Section 11 — every `open` question has an `owner` and `resolve_by`
- [ ] Section 11 — every `at_risk` item has a `falsifier`
- [ ] Section 12 (Changelog) records this version

## Portability checks

- [ ] Run the engine-leakage regex from `leakage-check.md` — no hits anywhere in the doc
- [ ] No reference to file formats, codecs, bundlers, or asset pipelines
- [ ] No prescriptive game loop implementation (only per-tick data flow)
- [ ] Tier 1 (low) devices can plausibly run every System listed

## Process checks

- [ ] Reviewers (Section 0) have actually reviewed
- [ ] Producer has been notified of the impending lock
- [ ] If the spec affects the platform tier, platform-lead has confirmed feasibility within budget

If any box is unchecked, write a comment in the spec stating what's outstanding and keep status at `draft` or `in_review`. Do not silently lock.
