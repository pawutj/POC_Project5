class_name BasicAttackSkill
extends DamagingSkill
## Single-target hit on the front of the opposing formation. Shared by every
## unit in the game (Tank/DPS/Support/Slime) — only the power multiplier
## differs per role, set at construction by UnitFactory.

func _init(p_power_multiplier: float = 1.0) -> void:
	skill_name = "Attack"
	target_rule = BattleEnums.TargetRule.FRONT_ENEMY
	power_multiplier = p_power_multiplier
