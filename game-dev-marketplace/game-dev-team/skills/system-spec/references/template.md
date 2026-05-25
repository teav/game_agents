# System Spec template

Fill out each section. Engine-specific vocabulary is forbidden — see `leakage-check.md`.

```markdown
# System Spec — <title>

## 0. Header
spec_id:       <slug>
title:         <name>
version:       <semver>
status:        draft | in_review | locked
owners:
  architect:   systems-architect
  reviewers:   [<agent ids>]
last_updated:  <ISO date>
supersedes:    <prior spec_id or none>

## 1. Concept summary
**Pitch (≤3 sentences).** What the game is, what the player does, what makes it interesting.
**Target session.** Length, frequency, end condition.
**Genre frame.** 2–3 reference games + the single sentence that says how this differs.

## 2. Performance budgets
target_fps:           60
min_fps:              45        # frames below this count as a perf bug
frame_budget_ms:      16
peak_memory_mb:       <ceiling>
startup_to_input_ms:  <ms>
target_devices:
  - tier: low      # the floor — everything must run here
    description:   <e.g. "2019 mid-tier Android, 4GB RAM">
  - tier: mid
  - tier: high
network:
  required:          true | false
  offline_tolerant:  true | false

## 3. Resources (logical assets)
textures:
  - handle:    sprite.player.idle
    type:      sprite_sheet
    frames:    8
    source_px: 32x32
audio:
  - handle:    sfx.jump
    type:      one_shot
    loudness_lufs: -14
fonts:
  - handle:    font.ui.primary
    weights:   [400, 500]

## 4. Entities & Components
components:
  Position:    {x: float, y: float, layer: int}
  Velocity:    {vx: float, vy: float, max_speed: float}
  Health:      {current: int, max: int, invuln_ticks: int}
  Sprite:      {handle: ResourceHandle, frame: int, flip_x: bool}
  Hitbox:      {w: float, h: float, offset_x: float, offset_y: float}
  Input:       {intent_x: float, intent_y: float, actions: set[ActionName]}
entities:
  Player:
    components: [Position, Velocity, Health, Sprite, Hitbox, Input]
    constraints: [exactly one exists at runtime]
  Enemy:
    components: [Position, Velocity, Health, Sprite, Hitbox]
    variants: data-driven from data.enemies

## 5. Systems
systems:
  - name: InputSystem
    order: 1
    reads:    [Input (external device state)]
    writes:   [Input component on Player]
  - name: MovementSystem
    order: 2
    reads:    [Position, Velocity, Input]
    writes:   [Position, Velocity]
    constraints:
      - Velocity clamped to Velocity.max_speed
  - name: CollisionSystem
    order: 3
    reads:    [Position, Hitbox]
    writes:   [Position (resolution)]
    emits:    [CollisionEvent]
  - name: CombatSystem
    order: 4
    reads:    [CollisionEvent, Health]
    writes:   [Health]
    emits:    [DamageEvent, DeathEvent]
  - name: RenderSystem
    order: last
    reads:    [Position, Sprite, layer]
    writes:   [framebuffer (abstract)]

## 6. Events
events:
  CollisionEvent:
    payload: {entity_a: EntityId, entity_b: EntityId, normal_x: float, normal_y: float}
    emitted_by: [CollisionSystem]
    listened_by: [CombatSystem, AudioSystem]
  DamageEvent:
    payload: {target: EntityId, amount: int, source: EntityId | null}
    emitted_by: [CombatSystem]
    listened_by: [AudioSystem, FeedbackSystem]
enums:
  ActionName: [jump, interact, attack, dash, pause]

## 7. State machines
state_machines:
  GameState:
    initial: Boot
    states:
      Boot:    {on: {assets_loaded: -> Menu}}
      Menu:    {on: {start_pressed: -> Playing}}
      Playing: {on: {player_died: -> GameOver, paused: -> Paused}}
      Paused:  {on: {resumed: -> Playing, quit: -> Menu}}
      GameOver:{on: {restart_pressed: -> Playing, quit: -> Menu}}

## 8. Data flows (per tick)
1. Sample device input        -> Input component
2. InputSystem                -> updates Input on Player
3. MovementSystem             -> updates Position, Velocity
4. CollisionSystem            -> emits CollisionEvent
5. CombatSystem               -> consumes CollisionEvent, emits Damage/Death
6. GameStateSystem            -> consumes DeathEvent
7. AudioSystem, FeedbackSystem -> consume events
8. RenderSystem               -> draws frame

## 9. Invariants
- Player.Health.current is always in [0, Player.Health.max]
- An entity with DeathEvent emitted is removed by the start of the next tick
- All events emitted in tick T are consumed by the end of tick T

## 10. Content (data-driven)
enemies:
  - id: slime
    health: 3
    speed: 1.5
    sprite: sprite.enemy.slime

## 11. Open questions & at-risk items
open:
  - id: OQ-001
    question: "Does combat use stamina or cooldowns?"
    owner: game-designer
    resolve_by: design lock
at_risk:
  - id: AR-001
    feature: "Dynamic lighting on 200+ entities"
    risk: "May not fit frame budget on low tier"
    owner: platform-lead
    falsifier: "Spike on target device hits 45fps with 200 entities"

## 12. Changelog
0.1.0  Initial draft. (systems-architect)
```
