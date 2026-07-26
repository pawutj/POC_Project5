class_name BattleEnums
## Shared enums for the battle system. Kept in one place so Skill/BattleUnit/
## BattleContext all agree on the same values without circular dependencies.

enum Team {
	PLAYER,
	ENEMY,
}

## How a Skill picks its target(s). Rules are resolved relative to the
## caster's team so the same Skill instance works for either side.
enum TargetRule {
	FRONT_ENEMY,
	ALL_ENEMIES,
	SELF,
	LOWEST_HP_ALLY,
}

## Cosmetic/identification only (e.g. UI color-coding). Battle logic never
## branches on Role — behavior comes entirely from stats + equipped Skills.
enum Role {
	TANK,
	DPS,
	SUPPORT,
	ENEMY,
}
