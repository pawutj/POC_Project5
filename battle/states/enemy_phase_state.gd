class_name EnemyPhaseState
extends BattleState
## Every living enemy acts once, in formation order, with a short delay
## between each so the battle log/HP changes are readable. Stops
## immediately if either side is wiped mid-phase.

const ACTION_DELAY_SECONDS := 0.5

var _ai: BattleAI = SimpleEnemyAI.new()

func enter(manager: BattleManager) -> void:
	manager.phase_changed.emit(BattleManager.Phase.ENEMY)
	for enemy in manager.context.get_units(BattleEnums.Team.ENEMY):
		if not enemy.is_alive():
			continue
		await manager.get_tree().create_timer(ACTION_DELAY_SECONDS).timeout
		var skill := _ai.choose_skill(enemy, manager.context)
		var ended := manager.execute_action(enemy, skill)
		if ended:
			return
	manager.change_state(PlayerPhaseState.new())
