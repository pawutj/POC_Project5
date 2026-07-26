class_name ShieldBashSkill
extends DamagingSkill
## Tank's ultimate: a heavy blow to the front enemy that leaves the Tank
## braced afterward, combining Basic Attack and Guard into one action.

func _init(p_power_multiplier: float = 1.6) -> void:
	skill_name = "Shield Bash"
	target_rule = BattleEnums.TargetRule.FRONT_ENEMY
	power_multiplier = p_power_multiplier
	orb_cost = 4

func apply(caster: BattleUnit, targets: Array[BattleUnit]) -> String:
	var text := super.apply(caster, targets)
	caster.activate_guard()
	return text + " and braces for the next hit"
