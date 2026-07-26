class_name SimpleEnemyAI
extends BattleAI
## Every Slime's brain: always use its first skill (Basic Attack). Enough
## for a POC enemy that only ever needs to hit the front-most player unit.

func choose_skill(unit: BattleUnit, _context: BattleContext) -> Skill:
	return unit.skills[0]
