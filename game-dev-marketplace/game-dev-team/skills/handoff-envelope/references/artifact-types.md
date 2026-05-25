# Valid artifact_type values

| Producing agent            | artifact_types this agent emits                                |
| -------------------------- | -------------------------------------------------------------- |
| producer                   | project_brief, routing_decision, adjudication, migration_log   |
| game-designer              | gdd, mechanic_spec, progression_curve, pitch_too_thin           |
| systems-architect          | system_spec                                                    |
| art-director               | style_guide, asset_spec, palette                               |
| narrative                  | world_bible, character, dialogue, content_data                 |
| playtest-planner           | playtest_plan, playtest_report, playtest_finding               |
| design-critic              | critique                                                       |
| market-analyst             | market_assessment                                              |
| fact-checker-conceptual    | verification                                                   |
| accessibility-critic       | accessibility_critique                                          |
| platform-lead              | architecture, task_breakdown, perf_plan                        |
| implementation             | pr, build                                                      |
| performance                | profile_report, regression_alert, optimization_pr              |
| build-pipeline             | build_config, pipeline_doc, release_artifact                   |
| execution-realist          | estimate_critique                                              |
| constraints-critic         | constraint_analysis                                            |
| fact-checker-platform      | verification                                                   |

If you need a new `artifact_type`, raise it to the Producer first. New types affect routing and review queue mapping.

## Example envelope

```markdown
---
from:           systems-architect
to:             platform-lead
artifact_type:  system_spec
version:        0.3.0
based_on:       [docs/game/design/gdd.md@0.5.0]
status:         locked
---

# System Spec — Harvest Loop

## 0. Header
...
```
