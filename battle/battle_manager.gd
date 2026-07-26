class_name BattleManager
extends Node
## Orchestrator: owns the current BattleState and the shared execution path
## for actions (`execute_action`). Contains no combat math or targeting
## logic itself — that all lives in Skill/BattleContext. This class only
## coordinates *when* things happen, not *what* happens.

enum Phase { PLAYER, ENEMY, ENDED }
enum BattleResult { NONE, VICTORY, DEFEAT }

## Roles a board orb can roll. Enemy is deliberately excluded — orbs only
## ever gate player actions.
const ORB_COLORS: Array[BattleEnums.Role] = [
	BattleEnums.Role.TANK,
	BattleEnums.Role.DPS,
	BattleEnums.Role.SUPPORT,
]

## Board layout: 7 columns x 2 rows = 14 orbs.
const GRID_COLUMNS: int = 7
const GRID_ROWS: int = 2

## The only orb-selection sizes that trigger an action (1 -> A, 2 -> B,
## 4 -> C, matched against a skill's orb_cost).
const VALID_SELECTION_SIZES: Array[int] = [1, 2, 4]

signal phase_changed(phase: Phase)
signal action_pool_changed(remaining: int, total: int)
signal orb_grid_changed(grid: Array[BattleEnums.Role])
signal log_message(text: String)
signal battle_ended(victory: bool)

var context: BattleContext
var player_units: Array[BattleUnit] = []
var enemy_units: Array[BattleUnit] = []
var action_pool_size: int = 0
var orb_grid: Array[BattleEnums.Role] = []

var current_state: BattleState

func start_battle(p_player_units: Array[BattleUnit], p_enemy_units: Array[BattleUnit]) -> void:
	player_units = p_player_units
	enemy_units = p_enemy_units
	context = BattleContext.new(player_units, enemy_units)
	action_pool_size = player_units.size()
	change_state(PlayerPhaseState.new())

## Called by the UI layer when the player selects a set of same-colored
## board indices and confirms. Delegates to whatever state is active; only
## PlayerPhaseState actually reacts.
func submit_orb_selection(indices: Array[int]) -> void:
	current_state.handle_orb_selection(self, indices)

## Fills every cell of the board with a fresh random color. Called once when
## the player phase begins.
func fill_orb_grid() -> void:
	orb_grid.clear()
	for i in range(GRID_COLUMNS * GRID_ROWS):
		orb_grid.append(_random_orb_color())
	orb_grid_changed.emit(orb_grid)

## Replaces the orbs at the given indices (the ones just spent on an action)
## with fresh random colors, match-3 style.
func refill_orbs(indices: Array[int]) -> void:
	for i in indices:
		orb_grid[i] = _random_orb_color()
	orb_grid_changed.emit(orb_grid)

func _random_orb_color() -> BattleEnums.Role:
	return ORB_COLORS[randi() % ORB_COLORS.size()]

## Validates a proposed board selection and resolves it to the actor + skill
## it would trigger. Returns an empty Dictionary if the selection is invalid:
## mixed colors, an unsupported count, no living unit of that role, or no
## skill on that unit costing that many orbs.
func resolve_orb_selection(indices: Array[int]) -> Dictionary:
	if indices.is_empty() or not VALID_SELECTION_SIZES.has(indices.size()):
		return {}
	var seen: Dictionary = {}
	for i in indices:
		if i < 0 or i >= orb_grid.size() or seen.has(i):
			return {}
		seen[i] = true
	var color: BattleEnums.Role = orb_grid[indices[0]]
	for i in indices:
		if orb_grid[i] != color:
			return {}
	var actor: BattleUnit = null
	for unit in player_units:
		if unit.role == color and unit.is_alive():
			actor = unit
			break
	if actor == null:
		return {}
	var skill: Skill = null
	for s in actor.skills:
		if s.orb_cost == indices.size():
			skill = s
			break
	if skill == null:
		return {}
	return {"actor": actor, "skill": skill}

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
