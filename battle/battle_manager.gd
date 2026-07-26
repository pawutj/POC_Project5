class_name BattleManager
extends Node
## Orchestrator: owns the current BattleState and the shared execution path
## for actions (`execute_action`). Contains no combat math or targeting
## logic itself — that all lives in Skill/BattleContext. This class only
## coordinates *when* things happen, not *what* happens.

enum Phase { PLAYER, ENEMY, ENDED }
enum BattleResult { NONE, VICTORY, DEFEAT }

signal phase_changed(phase: Phase)
signal action_pool_changed(remaining: int, total: int)
signal log_message(text: String)
signal battle_ended(victory: bool)

var context: BattleContext
var player_units: Array[BattleUnit] = []
var enemy_units: Array[BattleUnit] = []
var action_pool_size: int = 0

var current_state: BattleState

func start_battle(p_player_units: Array[BattleUnit], p_enemy_units: Array[BattleUnit]) -> void:
	player_units = p_player_units
	enemy_units = p_enemy_units
	context = BattleContext.new(player_units, enemy_units)
	action_pool_size = player_units.size()
	change_state(PlayerPhaseState.new())

## Called by the UI layer when the player picks an actor + skill. Delegates
## to whatever state is active; only PlayerPhaseState actually reacts.
func submit_player_action(actor: BattleUnit, skill: Skill) -> void:
	current_state.handle_player_action(self, actor, skill)

func change_state(new_state: BattleState) -> void:
	if current_state != null:
		current_state.exit(self)
	current_state = new_state
	current_state.enter(self)

## Shared execution path for both player-submitted and AI-chosen actions.
## Returns true if this action ended the battle.
func execute_action(actor: BattleUnit, skill: Skill) -> bool:
	var targets := skill.resolve_targets(actor, context)
	var text := skill.apply(actor, targets)
	log_message.emit(text)

	var result := _check_result()
	if result != BattleResult.NONE:
		change_state(BattleEndState.new(result == BattleResult.VICTORY))
		return true
	return false

func _check_result() -> BattleResult:
	if context.is_team_defeated(BattleEnums.Team.ENEMY):
		return BattleResult.VICTORY
	if context.is_team_defeated(BattleEnums.Team.PLAYER):
		return BattleResult.DEFEAT
	return BattleResult.NONE
