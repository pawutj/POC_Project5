class_name PlayerPhaseState
extends BattleState
## The player may spend the party's shared action pool on any living
## character, in any combination, until it runs out.

var actions_remaining: int = 0

func enter(manager: BattleManager) -> void:
	actions_remaining = manager.action_pool_size
	manager.phase_changed.emit(BattleManager.Phase.PLAYER)
	manager.action_pool_changed.emit(actions_remaining, manager.action_pool_size)

func handle_player_action(manager: BattleManager, actor: BattleUnit, skill: Skill) -> void:
	if not actor.is_alive():
		return
	var ended := manager.execute_action(actor, skill)
	if ended:
		return
	actions_remaining -= 1
	manager.action_pool_changed.emit(actions_remaining, manager.action_pool_size)
	if actions_remaining <= 0:
		manager.change_state(EnemyPhaseState.new())
