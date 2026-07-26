class_name BattleState
extends RefCounted
## Base of the battle flow's State pattern. Each concrete phase
## (Player / Enemy / End) owns its own entry behavior and reacts to events
## in whatever way makes sense for that phase — BattleManager just forwards.

func enter(_manager: BattleManager) -> void:
	pass

func exit(_manager: BattleManager) -> void:
	pass

## Only PlayerPhaseState responds to this; other phases ignore stray input.
func handle_orb_selection(_manager: BattleManager, _indices: Array[int]) -> void:
	pass
