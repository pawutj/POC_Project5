class_name UnitFactory
extends RefCounted
## Single place that assembles a role's stats + skill loadout into a
## BattleUnit. Adding a 4th player role or a new enemy type means adding
## one function here — nothing else in the battle system needs to change.

static func create_tank(id: String) -> BattleUnit:
	var stats := UnitStats.new()
	stats.max_hp = 160
	stats.atk = 10
	stats.def = 12
	stats.spd = 8
	var unit := BattleUnit.new(id, "Tank", BattleEnums.Team.PLAYER, BattleEnums.Role.TANK, stats)
	unit.skills = [BasicAttackSkill.new(1.0), GuardSkill.new(), ShieldBashSkill.new()]
	return unit

static func create_dps(id: String) -> BattleUnit:
	var stats := UnitStats.new()
	stats.max_hp = 100
	stats.atk = 18
	stats.def = 6
	stats.spd = 12
	var unit := BattleUnit.new(id, "DPS", BattleEnums.Team.PLAYER, BattleEnums.Role.DPS, stats)
	unit.skills = [BasicAttackSkill.new(1.2), SweepingStrikeSkill.new(0.7), ExecuteSkill.new()]
	return unit

static func create_support(id: String) -> BattleUnit:
	var stats := UnitStats.new()
	stats.max_hp = 90
	stats.atk = 14
	stats.def = 5
	stats.spd = 10
	var unit := BattleUnit.new(id, "Support", BattleEnums.Team.PLAYER, BattleEnums.Role.SUPPORT, stats)
	unit.skills = [BasicAttackSkill.new(0.6), HealSkill.new(0.8), MassHealSkill.new()]
	return unit

static func create_slime(id: String) -> BattleUnit:
	var stats := UnitStats.new()
	stats.max_hp = 60
	stats.atk = 9
	stats.def = 3
	stats.spd = 7
	var unit := BattleUnit.new(id, "Slime", BattleEnums.Team.ENEMY, BattleEnums.Role.ENEMY, stats)
	unit.skills = [BasicAttackSkill.new(0.8)]
	return unit

## Builds the full default POC encounter: [Tank, DPS, Support] vs 3 Slimes.
## Formation order (index 0 = front) is significant — see BattleContext.
static func create_default_player_party() -> Array[BattleUnit]:
	var units: Array[BattleUnit] = [
		create_tank("player_tank"),
		create_dps("player_dps"),
		create_support("player_support"),
	]
	return units

static func create_default_enemy_wave() -> Array[BattleUnit]:
	var units: Array[BattleUnit] = [
		create_slime("enemy_slime_1"),
		create_slime("enemy_slime_2"),
		create_slime("enemy_slime_3"),
	]
	return units
