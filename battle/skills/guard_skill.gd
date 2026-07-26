class_name GuardSkill
extends Skill
## Tank's signature skill: braces to halve the next hit taken. Deliberately
## a single boolean flag on BattleUnit rather than a full status-effect
## system — the simplest thing that demonstrates the Tank's identity.

func _init() -> void:
	skill_name = "Guard"
	target_rule = BattleEnums.TargetRule.SELF

func apply(caster: BattleUnit, targets: Array[BattleUnit]) -> String:
	for target in targets:
		target.activate_guard()
	return "%s uses %s and braces for the next hit" % [caster.display_name, skill_name]
