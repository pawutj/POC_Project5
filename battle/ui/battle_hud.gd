class_name BattleHUD
extends Control
## The only interactive surface in the POC: click same-colored orbs on the
## 7x2 board (1, 2, or 4 of them), then confirm to fire that role's Action
## A/B/C. Talks to the outside world purely through `orb_selection_confirmed`;
## battle_scene is responsible for wiring that to BattleManager.

signal orb_selection_confirmed(indices: Array[int])

var _player_units: Array[BattleUnit] = []
var _orb_grid: Array[BattleEnums.Role] = []
var _orb_buttons: Array[Button] = []
var _selected_indices: Array[int] = []
var _input_enabled: bool = true
var _actions_remaining: int = 0

var _pool_label: Label
var _preview_label: Label
var _confirm_button: Button
var _orb_grid_container: GridContainer
var _result_label: Label
var _log: RichTextLabel

func _ready() -> void:
	var vbox := VBoxContainer.new()
	add_child(vbox)

	_pool_label = Label.new()
	_pool_label.text = "Actions: - / -"
	vbox.add_child(_pool_label)

	_orb_grid_container = GridContainer.new()
	_orb_grid_container.columns = BattleManager.GRID_COLUMNS
	vbox.add_child(_orb_grid_container)

	for i in range(BattleManager.GRID_COLUMNS * BattleManager.GRID_ROWS):
		var orb_button := Button.new()
		orb_button.custom_minimum_size = Vector2(48, 48)
		orb_button.toggle_mode = true
		orb_button.toggled.connect(_on_orb_toggled.bind(i))
		_orb_grid_container.add_child(orb_button)
		_orb_buttons.append(orb_button)

	var confirm_row := HBoxContainer.new()
	vbox.add_child(confirm_row)

	_preview_label = Label.new()
	_preview_label.text = "Select matching orbs (1, 2, or 4)"
	confirm_row.add_child(_preview_label)

	_confirm_button = Button.new()
	_confirm_button.text = "Enter"
	_confirm_button.disabled = true
	_confirm_button.pressed.connect(_on_confirm_pressed)
	confirm_row.add_child(_confirm_button)

	_result_label = Label.new()
	_result_label.visible = false
	_result_label.add_theme_font_size_override("font_size", 28)
	vbox.add_child(_result_label)

	_log = RichTextLabel.new()
	_log.custom_minimum_size = Vector2(0, 160)
	_log.scroll_following = true
	vbox.add_child(_log)

func setup(player_units: Array[BattleUnit]) -> void:
	_player_units = player_units
	for unit in player_units:
		unit.died.connect(_on_unit_died)

func append_log(text: String) -> void:
	_log.append_text(text + "\n")

func update_action_pool(remaining: int, total: int) -> void:
	_actions_remaining = remaining
	_pool_label.text = "Actions: %d / %d" % [remaining, total]
	_refresh_confirm_state()

func on_orb_grid_changed(grid: Array[BattleEnums.Role]) -> void:
	_orb_grid = grid
	_clear_selection()
	for i in range(_orb_buttons.size()):
		var orb_button := _orb_buttons[i]
		orb_button.self_modulate = UnitView.color_for_role(grid[i])

func on_phase_changed(phase: BattleManager.Phase) -> void:
	_input_enabled = phase == BattleManager.Phase.PLAYER
	if not _input_enabled:
		_clear_selection()
	for orb_button in _orb_buttons:
		orb_button.disabled = not _input_enabled
	_refresh_confirm_state()

func show_result(victory: bool) -> void:
	_input_enabled = false
	_clear_selection()
	for orb_button in _orb_buttons:
		orb_button.disabled = true
	_confirm_button.disabled = true
	_result_label.visible = true
	_result_label.text = "VICTORY!" if victory else "DEFEAT..."

func _on_unit_died(_dead_unit: BattleUnit) -> void:
	_refresh_confirm_state()

func _on_orb_toggled(pressed: bool, index: int) -> void:
	if not _input_enabled:
		_orb_buttons[index].set_pressed_no_signal(not pressed)
		return
	if pressed:
		if not _selected_indices.is_empty() and _orb_grid[_selected_indices[0]] != _orb_grid[index]:
			for other in _selected_indices.duplicate():
				_orb_buttons[other].set_pressed_no_signal(false)
			_selected_indices.clear()
		_selected_indices.append(index)
	else:
		_selected_indices.erase(index)
	_refresh_confirm_state()

func _on_confirm_pressed() -> void:
	if not _input_enabled or _selected_indices.is_empty():
		return
	orb_selection_confirmed.emit(_selected_indices.duplicate())

func _clear_selection() -> void:
	for index in _selected_indices:
		if index < _orb_buttons.size():
			_orb_buttons[index].set_pressed_no_signal(false)
	_selected_indices.clear()
	_refresh_confirm_state()

## Read-only preview: mirrors BattleManager.resolve_orb_selection's rules
## locally so the player sees what an action would do before confirming.
func _refresh_confirm_state() -> void:
	if _preview_label == null:
		return
	if _selected_indices.is_empty():
		_preview_label.text = "Select matching orbs (1, 2, or 4)"
		_confirm_button.disabled = true
		return
	if not [1, 2, 4].has(_selected_indices.size()):
		_preview_label.text = "Select 1, 2, or 4 matching orbs"
		_confirm_button.disabled = true
		return
	var color: BattleEnums.Role = _orb_grid[_selected_indices[0]]
	var actor: BattleUnit = null
	for unit in _player_units:
		if unit.role == color and unit.is_alive():
			actor = unit
			break
	if actor == null:
		_preview_label.text = "No living unit for that color"
		_confirm_button.disabled = true
		return
	var skill: Skill = null
	for s in actor.skills:
		if s.orb_cost == _selected_indices.size():
			skill = s
			break
	if skill == null:
		_preview_label.text = "%s has no matching action" % actor.display_name
		_confirm_button.disabled = true
		return
	_preview_label.text = "%s -> %s" % [actor.display_name, skill.skill_name]
	_confirm_button.disabled = not _input_enabled or _actions_remaining <= 0
