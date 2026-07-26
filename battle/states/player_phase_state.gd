class_name PlayerPhaseState
extends BattleState
## The player may spend the party's shared action pool on any living
## character, in any combination, until it runs out.

var actions_remaining: int = 0

func enter(manager: BattleManager) -> void:
	actions_remaining = manager.action_pool_size
	manager.phase_changed.emit(BattleManager.Phase.PLAYER)
	manager.action_pool_changed.emit(actions_remaining, manager.action_pool_size)
	manager.fill_orb_grid()

## Board-gated: the selected indices must resolve to a living actor and a
## skill matching the selected orb count (see BattleManager.resolve_orb_selection).
func handle_orb_selection(manager: BattleManager, indices: Array[int]) -> void:
	if actions_remaining <= 0:
		return
	var resolved := manager.resolve_orb_selection(indices)
	if resolved.is_empty():
		return
	var ended := manager.execute_action(resolved.actor, resolved.skill)
	manager.refill_orbs(indices)
	if ended:
		return
	actions_remaining -= 1
	manager.action_pool_changed.emit(actions_remaining, manager.action_pool_size)
	if actions_remaining <= 0:
		manager.change_state(EnemyPhaseState.new())
