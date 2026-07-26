class_name ExecuteSkill
extends DamagingSkill
## DPS's ultimate: a single devastating blow to the front enemy, far
## stronger than either Basic Attack or Sweeping Strike.

func _init(p_power_multiplier: float = 2.5) -> void:
	skill_name = "Execute"
	target_rule = BattleEnums.TargetRule.FRONT_ENEMY
	power_multiplier = p_power_multiplier
	orb_cost = 4
