class_name BattleUnit
extends RefCounted
## A single combatant (player character or enemy). Holds only battle state —
## no rendering, no input. UI observes this purely through signals.

signal health_changed(current_hp: int, max_hp: int)
signal died(unit: BattleUnit)

var id: String
var display_name: String
var team: BattleEnums.Team
var role: BattleEnums.Role
var stats: UnitStats
var skills: Array[Skill] = []

var current_hp: int
var is_guarding: bool = false

func _init(p_id: String, p_display_name: String, p_team: BattleEnums.Team, p_role: BattleEnums.Role, p_stats: UnitStats) -> void:
	id = p_id
	display_name = p_display_name
	team = p_team
	role = p_role
	stats = p_stats
	current_hp = p_stats.max_hp

func is_alive() -> bool:
	return current_hp > 0

## Applies incoming damage, accounting for a pending Guard, and returns the
## actual amount dealt so callers (Skill/log) can report it.
func take_damage(amount: int) -> int:
	var final_amount := amount
	if is_guarding:
		final_amount = int(final_amount / 2.0)
		is_guarding = false
	final_amount = max(0, final_amount)
	current_hp = max(0, current_hp - final_amount)
	health_changed.emit(current_hp, stats.max_hp)
	if current_hp == 0:
		died.emit(self)
	return final_amount

## Restores HP up to max and returns the actual amount healed.
func heal(amount: int) -> int:
	var before := current_hp
	current_hp = min(stats.max_hp, current_hp + amount)
	health_changed.emit(current_hp, stats.max_hp)
	return current_hp - before

func activate_guard() -> void:
	is_guarding = true
