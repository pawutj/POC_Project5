class_name DamageCalculator
extends RefCounted
## Isolated damage formula so combat math has exactly one place to tune
## (crit, elemental modifiers, etc. would all be added here later).

static func calculate(attacker_atk: int, defender_def: int, power_multiplier: float) -> int:
	var raw := (attacker_atk * power_multiplier) - (defender_def * 0.5)
	return max(1, int(round(raw)))
