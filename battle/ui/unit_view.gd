class_name UnitView
extends PanelContainer
## Purely presentational: displays one BattleUnit's name/HP/front status and
## reacts to its signals. Never mutates battle state and never talks to
## BattleManager directly.

var unit: BattleUnit

var _front_label: Label
var _name_label: Label
var _hp_bar: ProgressBar
var _hp_label: Label

func setup(p_unit: BattleUnit) -> void:
	unit = p_unit
	custom_minimum_size = Vector2(140, 90)
	self_modulate = color_for_role(unit.role)

	var vbox := VBoxContainer.new()
	add_child(vbox)

	_front_label = Label.new()
	_front_label.text = "▶ FRONT"
	_front_label.visible = false
	_front_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_front_label)

	_name_label = Label.new()
	_name_label.text = unit.display_name
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_name_label)

	_hp_bar = ProgressBar.new()
	_hp_bar.max_value = unit.stats.max_hp
	_hp_bar.value = unit.current_hp
	_hp_bar.show_percentage = false
	vbox.add_child(_hp_bar)

	_hp_label = Label.new()
	_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_hp_label)
	_update_hp_label()

	unit.health_changed.connect(_on_health_changed)
	unit.died.connect(_on_died)

func set_is_front(is_front: bool) -> void:
	_front_label.visible = is_front and unit.is_alive()

static func color_for_role(role: BattleEnums.Role) -> Color:
	match role:
		BattleEnums.Role.TANK:
			return Color(0.35, 0.55, 0.95)
		BattleEnums.Role.DPS:
			return Color(0.95, 0.45, 0.35)
		BattleEnums.Role.SUPPORT:
			return Color(0.45, 0.9, 0.55)
		BattleEnums.Role.ENEMY:
			return Color(0.75, 0.4, 0.85)
		_:
			return Color(1, 1, 1)

func _on_health_changed(current_hp: int, _max_hp: int) -> void:
	_hp_bar.value = current_hp
	_update_hp_label()

func _on_died(_dead_unit: BattleUnit) -> void:
	modulate.a = 0.4
	_front_label.visible = false

func _update_hp_label() -> void:
	_hp_label.text = "%d / %d" % [unit.current_hp, unit.stats.max_hp]
