extends Control
## Composition root for the POC: builds the units, the domain/orchestration
## objects, and the view layer, then wires them together with signals. No
## other script in the project is allowed to know about all three layers
## at once — that knowledge is deliberately concentrated here.

var battle_manager: BattleManager
var _views_by_unit: Dictionary = {}

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var root_vbox := VBoxContainer.new()
	root_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root_vbox)

	var enemy_row := HBoxContainer.new()
	enemy_row.alignment = BoxContainer.ALIGNMENT_CENTER
	enemy_row.custom_minimum_size = Vector2(0, 120)
	root_vbox.add_child(enemy_row)

	var player_row := HBoxContainer.new()
	player_row.alignment = BoxContainer.ALIGNMENT_CENTER
	player_row.custom_minimum_size = Vector2(0, 120)
	root_vbox.add_child(player_row)

	var hud := BattleHUD.new()
	root_vbox.add_child(hud)

	var player_units := UnitFactory.create_default_player_party()
	var enemy_units := UnitFactory.create_default_enemy_wave()

	for unit in enemy_units:
		_create_view(unit, enemy_row)
	for unit in player_units:
		_create_view(unit, player_row)

	battle_manager = BattleManager.new()
	add_child(battle_manager)

	hud.setup(player_units)
	hud.orb_selection_confirmed.connect(func(indices: Array[int]) -> void:
		battle_manager.submit_orb_selection(indices)
	)
	battle_manager.log_message.connect(hud.append_log)
	battle_manager.log_message.connect(func(_text: String) -> void: _refresh_fronts())
	battle_manager.action_pool_changed.connect(hud.update_action_pool)
	battle_manager.orb_grid_changed.connect(hud.on_orb_grid_changed)
	battle_manager.phase_changed.connect(hud.on_phase_changed)
	battle_manager.phase_changed.connect(func(_phase: BattleManager.Phase) -> void: _refresh_fronts())
	battle_manager.battle_ended.connect(hud.show_result)

	battle_manager.start_battle(player_units, enemy_units)
	_refresh_fronts()

func _create_view(unit: BattleUnit, parent: Node) -> void:
	var view := UnitView.new()
	parent.add_child(view)
	view.setup(unit)
	_views_by_unit[unit] = view

func _refresh_fronts() -> void:
	var context := battle_manager.context
	if context == null:
		return
	var front_player := context.get_front_unit(BattleEnums.Team.PLAYER)
	var front_enemy := context.get_front_unit(BattleEnums.Team.ENEMY)
	for unit in _views_by_unit.keys():
		var view: UnitView = _views_by_unit[unit]
		view.set_is_front(unit == front_player or unit == front_enemy)
