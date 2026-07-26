class_name DamagingSkill
extends Skill
## Template Method for any skill that deals damage. Subclasses only need to
## set target_rule and power_multiplier — the damage loop itself is shared
## so BasicAttack and SweepingStrike (and any future attack skill) can't
## drift out of sync.

@export var power_multiplier: float = 1.0

func apply(caster: BattleUnit, targets: Array[BattleUnit]) -> String:
	var parts: Array[String] = []
	for target in targets:
		var amount := DamageCalculator.calculate(caster.stats.atk, target.stats.def, power_multiplier)
		var dealt := target.take_damage(amount)
		parts.append("%s takes %d damage" % [target.display_name, dealt])
	return "%s uses %s: %s" % [caster.display_name, skill_name, ", ".join(parts)]
