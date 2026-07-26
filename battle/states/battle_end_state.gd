class_name BattleEndState
extends BattleState
## Terminal state. Player input is ignored automatically since this class
## doesn't override handle_orb_selection (base is a no-op).

var victory: bool

func _init(p_victory: bool) -> void:
	victory = p_victory

func enter(manager: BattleManager) -> void:
	manager.phase_changed.emit(BattleManager.Phase.ENDED)
	manager.battle_ended.emit(victory)
