class_name BattleContext
extends RefCounted
## Read-only-ish view over both formations. Skills and AI query this instead
## of reaching into raw arrays, keeping "who do I hit" logic in one place.
##
## Formation order matters: index 0 is the front of that team. Player order
## is [Tank, DPS, Support] by default, so the Tank naturally takes hits
## first without needing an explicit taunt mechanic.

var _units_by_team: Dictionary = {}

func _init(player_units: Array[BattleUnit], enemy_units: Array[BattleUnit]) -> void:
	_units_by_team[BattleEnums.Team.PLAYER] = player_units
	_units_by_team[BattleEnums.Team.ENEMY] = enemy_units

static func opposite_team(team: BattleEnums.Team) -> BattleEnums.Team:
	return BattleEnums.Team.ENEMY if team == BattleEnums.Team.PLAYER else BattleEnums.Team.PLAYER

func get_units(team: BattleEnums.Team) -> Array[BattleUnit]:
	return _units_by_team[team]

func get_alive_units(team: BattleEnums.Team) -> Array[BattleUnit]:
	var alive: Array[BattleUnit] = []
	for unit in get_units(team):
		if unit.is_alive():
			alive.append(unit)
	return alive

## First living unit in formation order, or null if the team is wiped.
func get_front_unit(team: BattleEnums.Team) -> BattleUnit:
	for unit in get_units(team):
		if unit.is_alive():
			return unit
	return null

## Living unit with the lowest HP ratio on that team, or null if wiped.
func get_lowest_hp_unit(team: BattleEnums.Team) -> BattleUnit:
	var lowest: BattleUnit = null
	var lowest_ratio := INF
	for unit in get_alive_units(team):
		var ratio := float(unit.current_hp) / float(unit.stats.max_hp)
		if ratio < lowest_ratio:
			lowest_ratio = ratio
			lowest = unit
	return lowest

func is_team_defeated(team: BattleEnums.Team) -> bool:
	return get_alive_units(team).is_empty()
