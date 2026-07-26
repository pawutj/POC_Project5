# Battle System POC (Sdorica-style)

Turn-based battle proof-of-concept built for Godot 4.6. 3 player roles
(Tank / DPS / Support) vs. 3 identical Slime enemies, with a real
interactive UI built entirely in code (no art assets yet).

## Mechanics

- **Turn structure**: the player always acts first. The party shares an
  **action pool** (3 actions — one per party member). Once the pool is
  empty, every living enemy acts once (Enemy phase), then the pool refills
  and control returns to the player. Repeats until one side is wiped.
- **Orb board**: a 7x2 grid of 14 orbs, each randomly colored one of the 3
  player roles (Tank/DPS/Support), is shown each player phase. Per action,
  the player clicks same-colored orbs — **1, 2, or 4** of them — then
  confirms ("Enter"). The color picked selects *which* living unit acts
  (one unit per role); the count picked selects *which* of that unit's
  skills fires, matched against the skill's `orb_cost`:
  - 1 orb -> Action A (Basic Attack)
  - 2 orbs -> Action B (role special)
  - 4 orbs -> Action C (role ultimate)
  The orbs spent on a confirmed action are replaced with fresh random
  colors immediately (match-3 style); the rest of the board is untouched.
- **Targeting**: attacks auto-target the **front-most living unit** of the
  opposing formation by default (formation = array order, index 0 = front).
  No manual target picking — the orb selection only chooses actor + skill.
  Skills can override the default rule:
  - `FRONT_ENEMY` – default, single target
  - `ALL_ENEMIES` – AoE (DPS's Sweeping Strike)
  - `LOWEST_HP_ALLY` – auto-heal target (Support's Heal)
  - `ALL_ALLIES` – party-wide (Support's Mass Heal)
  - `SELF` – self-buff (Tank's Guard)
- **Formation matters**: default player order is `[Tank, DPS, Support]`, so
  the Tank absorbs enemy hits first without needing an explicit taunt
  system.
- Win/loss is checked after **every single action** (not just at phase
  boundaries), so the battle ends immediately if a side is wiped mid-phase.

## Skill roster

| Unit | A (1 orb) | B (2 orbs) | C (4 orbs) |
|---|---|---|---|
| Tank | Attack ×1.0, FRONT_ENEMY | Guard — SELF, halves next hit | Shield Bash — ×1.6 FRONT_ENEMY + self Guard |
| DPS | Attack ×1.2, FRONT_ENEMY | Sweeping Strike ×0.7, ALL_ENEMIES | Execute — ×2.5 FRONT_ENEMY |
| Support | Attack ×0.6, FRONT_ENEMY | Heal — LOWEST_HP_ALLY | Mass Heal — ALL_ALLIES |
| Slime ×3 | ×0.8 power, FRONT_ENEMY (= front player unit) | — | — |

## Architecture

Clean layering, one-way dependency: **Presentation → Orchestration →
Domain**. No presentation script contains combat rules; no domain class
knows Godot's UI nodes exist.

```
battle/
  domain/                    # Pure battle data/rules, no Godot UI dependency
    battle_enums.gd            Team / TargetRule / Role — shared vocabulary
    unit_stats.gd               Resource: max_hp, atk, def, spd
    battle_unit.gd               HP/state + health_changed/died signals
    battle_context.gd            Formation queries (front unit, lowest-HP, defeated?)
    damage_calculator.gd         Single damage formula, isolated for tuning

  skills/                    # Command-like objects: resolve targets + apply effect
    skill.gd                    Abstract base (target_rule, resolve_targets, apply, orb_cost)
    damaging_skill.gd            Template Method: shared damage-application loop
    basic_attack_skill.gd        FRONT_ENEMY — reused by every unit incl. Slimes (orb_cost 1)
    sweeping_strike_skill.gd     ALL_ENEMIES (DPS special, orb_cost 2)
    heal_skill.gd                 LOWEST_HP_ALLY (Support special, orb_cost 2)
    guard_skill.gd                 SELF (Tank special, orb_cost 2)
    shield_bash_skill.gd           FRONT_ENEMY + self Guard (Tank ultimate, orb_cost 4)
    execute_skill.gd                FRONT_ENEMY, high power (DPS ultimate, orb_cost 4)
    mass_heal_skill.gd              ALL_ALLIES (Support ultimate, orb_cost 4)

  ai/                        # Strategy pattern for enemy decisions
    battle_ai.gd                 Interface: choose_skill(unit, context)
    simple_enemy_ai.gd            Always basic attack

  states/                    # State pattern for the battle flow
    battle_state.gd               Base: enter/exit/handle_orb_selection
    player_phase_state.gd          Owns the action pool countdown + orb-selection resolution
    enemy_phase_state.gd            Iterates living enemies with a short delay
    battle_end_state.gd             Terminal state, emits victory/defeat

  unit_factory.gd            # Single place that assembles stats + skill loadout per role
  battle_manager.gd          # Orchestrator (extends Node): owns state machine, orb board, signals

  ui/                        # Presentation only — observes signals, mutates nothing
    unit_view.gd                 Name/HP/front-marker display for one unit
    battle_hud.gd                  7x2 orb grid, selection preview, action counter, log, result overlay

  battle_scene.gd            # Composition root: builds everything and wires signals
  battle_scene.tscn          # Single Control root + script; children built in code
```

### Design decisions worth knowing

- **Role = data, not subclassing.** `BattleUnit` is one concrete class.
  Tank/DPS/Support/Slime differ only by `UnitStats` values and which
  `Skill` instances `UnitFactory` equips them with — adding a 4th role is
  just a new `UnitFactory.create_x()` function.
- **Skills are team-relative, not per-faction.** `Skill.resolve_targets()`
  resolves "enemy"/"ally" relative to the *caster's* team, so
  `BasicAttackSkill` is one class reused by Tank, DPS, Support, and all 3
  Slimes (just constructed with a different power multiplier each time).
- **Signals decouple domain from UI.** `BattleUnit` emits
  `health_changed`/`died`; `BattleManager` emits `phase_changed`,
  `log_message`, `action_pool_changed`, `orb_grid_changed`, `battle_ended`.
  `UnitView` and `BattleHUD` only *observe* these — `battle_scene.gd` is the
  only file that references all three layers and wires HUD input →
  BattleManager.
- **The orb board gates both actor and skill in one query.**
  `BattleManager.resolve_orb_selection()` takes the board indices the
  player clicked and resolves them to a living unit of the matching role
  plus whichever of that unit's skills has a matching `orb_cost` — no
  separate actor-picking step needed since each role has exactly one unit.
- **Guard is intentionally minimal.** A single `is_guarding` flag on
  `BattleUnit`, consumed by the next `take_damage()` call — not a full
  status-effect system, since nothing else in this POC needs one (YAGNI).

## How to test

No Godot binary was available to headlessly verify this while writing it.
To try it:

1. Open the project in Godot 4.6.
2. Press **Play** (F5) — `run/main_scene` is already set to
   `res://battle/battle_scene.tscn`.
3. Expected: 3 Slime boxes on top, 3 player boxes on bottom, an
   "Actions: 3/3" counter, a 7x2 grid of colored orb buttons, a selection
   preview label + "Enter" button, live HP bars, a scrolling battle log, a
   "▶ FRONT" marker on the front unit of each side, and a VICTORY!/DEFEAT...
   overlay when one side is wiped. Click same-colored orbs (1, 2, or 4 of
   them), then press Enter to fire that role's action.

If anything errors or behaves unexpectedly in-editor, paste the error here
to get it fixed.

## Possible extensions

- Real sprites/animations in `UnitView` (currently `ColorRect`-style
  placeholders via `self_modulate`).
- A proper status-effect list instead of the single Guard flag, if more
  buffs/debuffs are needed later.
- Manual target selection UI (currently every skill auto-resolves its
  target via `target_rule`).
- Speed-based initiative if the shared action-pool model needs to coexist
  with individual unit speed later.
