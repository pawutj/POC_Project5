class_name BattleHUD
extends Control
## The only interactive surface in the POC: pick an actor, then pick one of
## that actor's skills. Targeting is never shown here — Skill resolves it.
## Talks to the outside world purely through `action_chosen`; battle_scene
## is responsible for wiring that to BattleManager.

signal action_chosen(actor: BattleUnit, skill: Skill)

var _actor_buttons: Dictionary = {}
var _selected_actor: BattleUnit = null
var _input_enabled: bool = true

var _pool_label: Label
var _actor_row: HBoxContainer
var _skill_row: HBoxContainer
var _result_label: Label
var _log: RichTextLabel

func _ready() -> void:
	var vbox := VBoxContainer.new()
	add_child(vbox)

	_pool_label = Label.new()
	_pool_label.text = "Actions: - / -"
	vbox.add_child(_pool_label)

	_actor_row = HBoxContainer.new()
	vbox.add_child(_actor_row)

	_skill_row = HBoxContainer.new()
	vbox.add_child(_skill_row)

	_result_label = Label.new()
	_result_label.visible = false
	_result_label.add_theme_font_size_override("font_size", 28)
	vbox.add_child(_result_label)

	_log = RichTextLabel.new()
	_log.custom_minimum_size = Vector2(0, 160)
	_log.scroll_following = true
	vbox.add_child(_log)

func setup(player_units: Array[BattleUnit]) -> void:
	for unit in player_units:
		var button := Button.new()
		button.text = unit.display_name
		button.modulate = UnitView.color_for_role(unit.role)
		button.pressed.connect(_on_actor_pressed.bind(unit))
		unit.died.connect(_on_unit_died)
		_actor_row.add_child(button)
		_actor_buttons[unit] = button

func append_log(text: String) -> void:
	_log.append_text(text + "\n")

func update_action_pool(remaining: int, total: int) -> void:
	_pool_label.text = "Actions: %d / %d" % [remaining, total]

func on_phase_changed(phase: BattleManager.Phase) -> void:
	_input_enabled = phase == BattleManager.Phase.PLAYER
	if not _input_enabled:
		_selected_actor = null
		_clear_skill_buttons()
	_refresh_actor_buttons()

func show_result(victory: bool) -> void:
	_input_enabled = false
	_selected_actor = null
	_clear_skill_buttons()
	_refresh_actor_buttons()
	_result_label.visible = true
	_result_label.text = "VICTORY!" if victory else "DEFEAT..."

func _on_unit_died(dead_unit: BattleUnit) -> void:
	var button: Button = _actor_buttons.get(dead_unit)
	if button != null:
		button.disabled = true
	if _selected_actor == dead_unit:
		_selected_actor = null
		_clear_skill_buttons()

func _on_actor_pressed(unit: BattleUnit) -> void:
	if not _input_enabled or not unit.is_alive():
		return
	_selected_actor = unit
	_clear_skill_buttons()
	for skill in unit.skills:
		var button := Button.new()
		button.text = skill.skill_name
		button.pressed.connect(_on_skill_pressed.bind(unit, skill))
		_skill_row.add_child(button)

func _on_skill_pressed(unit: BattleUnit, skill: Skill) -> void:
	if not _input_enabled:
		return
	action_chosen.emit(unit, skill)
	_selected_actor = null
	_clear_skill_buttons()

func _clear_skill_buttons() -> void:
	for child in _skill_row.get_children():
		child.queue_free()

func _refresh_actor_buttons() -> void:
	for unit in _actor_buttons.keys():
		var button: Button = _actor_buttons[unit]
		button.disabled = (not _input_enabled) or (not unit.is_alive())
