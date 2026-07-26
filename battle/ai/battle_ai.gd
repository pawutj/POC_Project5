class_name BattleAI
extends RefCounted
## Strategy interface for enemy decision-making. Swapping in a smarter AI
## later (e.g. one that prefers low-HP targets or saves cooldowns) only
## means adding a new subclass — nothing else in the battle system changes.

func choose_skill(_unit: BattleUnit, _context: BattleContext) -> Skill:
	push_error("BattleAI.choose_skill() is abstract and must be overridden")
	return null
