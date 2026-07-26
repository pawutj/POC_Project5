class_name Skill
extends Resource
## Abstract base for every action a BattleUnit can take. A Skill is pure
## data + behavior — it knows how to pick its targets and what to do to
## them, but nothing about turns, phases, or UI.

@export var skill_name: String = "Skill"
@export var target_rule: BattleEnums.TargetRule = BattleEnums.TargetRule.FRONT_ENEMY

## Resolves target_rule relative to the caster's team so the same Skill
## instance behaves correctly whether cast by a player unit or an enemy.
func resolve_targets(caster: BattleUnit, context: BattleContext) -> Array[BattleUnit]:
	var targets: Array[BattleUnit] = []
	match target_rule:
		BattleEnums.TargetRule.FRONT_ENEMY:
			var front := context.get_front_unit(BattleContext.opposite_team(caster.team))
			if front != null:
				targets.append(front)
		BattleEnums.TargetRule.ALL_ENEMIES:
			targets = context.get_alive_units(BattleContext.opposite_team(caster.team))
		BattleEnums.TargetRule.SELF:
			targets.append(caster)
		BattleEnums.TargetRule.LOWEST_HP_ALLY:
			var lowest := context.get_lowest_hp_unit(caster.team)
			if lowest != null:
				targets.append(lowest)
	return targets

## Applies this skill's effect to the given targets. Returns a human-readable
## log line describing what happened. Must be overridden by subclasses.
func apply(_caster: BattleUnit, _targets: Array[BattleUnit]) -> String:
	push_error("Skill.apply() is abstract and must be overridden by %s" % get_script().resource_path)
	return ""
