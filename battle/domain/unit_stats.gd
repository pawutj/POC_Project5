class_name UnitStats
extends Resource
## Base stats for a BattleUnit. Pure data so UnitFactory can tune roles
## without touching any behavioral code.

@export var max_hp: int = 100
@export var atk: int = 10
@export var def: int = 5
@export var spd: int = 10
