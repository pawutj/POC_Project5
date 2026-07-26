class_name HealSkill
extends Skill
## Support's signature skill: restores HP to the ally with the lowest HP
## ratio. Demonstrates the LOWEST_HP_ALLY target rule.

@export var heal_power: float = 0.8

func _init(p_heal_power: float = 0.8) -> void:
	skill_name = "Heal"
	target_rule = BattleEnums.TargetRule.LOWEST_HP_ALLY
	heal_power = p_heal_power
	orb_cost = 2

func apply(caster: BattleUnit, targets: Array[BattleUnit]) -> String:
	var parts: Array[String] = []
	var amount := int(round(caster.stats.atk * heal_power))
	for target in targets:
		var healed := target.heal(amount)
		parts.append("%s recovers %d HP" % [target.display_name, healed])
	if parts.is_empty():
		return "%s uses %s but no one needs healing" % [caster.display_name, skill_name]
	return "%s uses %s: %s" % [caster.display_name, skill_name, ", ".join(parts)]
