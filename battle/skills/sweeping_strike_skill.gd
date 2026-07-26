class_name SweepingStrikeSkill
extends DamagingSkill
## DPS's AoE: hits every living enemy for reduced power. Demonstrates the
## ALL_ENEMIES target rule (the exception to "always hit the front unit").

func _init(p_power_multiplier: float = 0.7) -> void:
	skill_name = "Sweeping Strike"
	target_rule = BattleEnums.TargetRule.ALL_ENEMIES
	power_multiplier = p_power_multiplier
	orb_cost = 2
