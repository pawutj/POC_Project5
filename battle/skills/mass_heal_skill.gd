class_name MassHealSkill
extends HealSkill
## Support's ultimate: Heal's effect extended to the whole party at once.
## Reuses HealSkill.apply() as-is since it already loops over whatever
## targets it's given.

func _init(p_heal_power: float = 0.6) -> void:
	super._init(p_heal_power)
	skill_name = "Mass Heal"
	target_rule = BattleEnums.TargetRule.ALL_ALLIES
	orb_cost = 4
