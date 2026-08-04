extends CanvasLayer
## 移动端（Android）虚拟触控层
## 移植适配组件：通过 Input.action_press/release 模拟游戏已有的输入动作，
## 完全复用原版输入系统（player.gd 的 left/right/up/down 与 look_* 动作），
## 不改动任何游戏逻辑。仅在移动设备上启用，桌面/手柄玩法不受影响。

var _enabled: bool = false

# 动作按钮（右缘竖排）
const BUTTONS: Array[Dictionary] = [
	{"action": "jump", "label": "J"},
	{"action": "interact", "label": "E"},
	{"action": "run", "label": "RUN"},
	{"action": "sit", "label": "SIT"},
	{"action": "howl", "label": "HOWL"},
	{"action": "menu", "label": "MENU"},
]

const _STICK_RADIUS: float = 62.0
const _DEADZONE: float = 0.16
const _CAM_SENS: float = 1.0

# 触摸点角色管理：index -> role ("move"/"cam"/"btn_<action>")
var _roles: Dictionary = {}
var _move_origin: Vector2 = Vector2.ZERO
var _cam_last: Vector2 = Vector2.ZERO

# 视觉节点
var _root: Control
var _move_drawer: MoveDrawer
var _btn_nodes: Dictionary = {}  # action -> {rect, label, panel}
var _tap_hint: Label

func _ready() -> void:
	_enabled = OS.has_feature("mobile") or DisplayServer.get_name() == "Android"
	if not _enabled:
		process_mode = Node.PROCESS_MODE_DISABLED
		return
	layer = 200
	_build_ui()

func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	_move_drawer = MoveDrawer.new()
	_move_drawer.layer_owner = self
	_move_drawer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_move_drawer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_move_drawer)

	var _rect := get_viewport().get_visible_rect()
	_resize_ui(_rect)

	_tap_hint = Label.new()
	_tap_hint.text = "TAP TO START"
	_tap_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tap_hint.add_theme_font_size_override("font_size", int(_rect.size.y * 0.07))
	_tap_hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
	_tap_hint.visible = false
	_root.add_child(_tap_hint)

func _input(event: InputEvent) -> void:
	if not _enabled or not _root or not _root.visible:
		return
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)

func _handle_touch(event: InputEventScreenTouch) -> void:
	var _idx := event.index
	if event.pressed:
		# 1. 按钮命中优先
		for _action in _btn_nodes:
			if _btn_nodes[_action].rect.has_point(event.position):
				_press_action(_action)
				_roles[_idx] = "btn_%s" % _action
				return
		# 2. 左半屏 → 移动摇杆
		var _rect := get_viewport().get_visible_rect()
		if event.position.x < _rect.size.x * 0.45 and not _roles.has_value("move"):
			_roles[_idx] = "move"
			_move_origin = event.position
			return
		# 3. 其余 → 视角
		_roles[_idx] = "cam"
		_cam_last = event.position
	else:
		var _role: String = _roles.get(_idx, "")
		match _role:
			"move":
				_release_move()
			"cam":
				_release_cam()
			_:
				if _role.begins_with("btn_"):
					_release_action(_role.substr(4))
		_roles.erase(_idx)

func _handle_drag(event: InputEventScreenDrag) -> void:
	match _roles.get(event.index, ""):
		"move":
			var _delta: Vector2 = (event.position - _move_origin) / _STICK_RADIUS
			_apply_move(_delta.limit_length(1.0))
		"cam":
			var _d: Vector2 = event.position - _cam_last
			_cam_last = event.position
			_apply_cam(_d)

func _apply_move(v: Vector2) -> void:
	var _x := 0.0 if absf(v.x) < _DEADZONE else v.x
	var _y := 0.0 if absf(v.y) < _DEADZONE else v.y
	Input.action_press("left", clampf(-_x, 0.0, 1.0))
	Input.action_press("right", clampf(_x, 0.0, 1.0))
	Input.action_press("up", clampf(-_y, 0.0, 1.0))
	Input.action_press("down", clampf(_y, 0.0, 1.0))

func _release_move() -> void:
	for _a in ["left", "right", "up", "down"]:
		Input.action_release(_a)

func _apply_cam(d: Vector2) -> void:
	var _mag := clampf(d.length() / 24.0, 0.0, 1.0) * _CAM_SENS
	if _mag <= 0.0:
		return
	var _dir := d / maxf(d.length(), 0.0001)
	Input.action_press("look_left", clampf(-_dir.x * _mag, 0.0, 1.0))
	Input.action_press("look_right", clampf(_dir.x * _mag, 0.0, 1.0))
	Input.action_press("look_up", clampf(-_dir.y * _mag, 0.0, 1.0))
	Input.action_press("look_down", clampf(_dir.y * _mag, 0.0, 1.0))

func _release_cam() -> void:
	for _a in ["look_left", "look_right", "look_up", "look_down"]:
		Input.action_release(_a)

func _press_action(_action: String) -> void:
	Input.action_press(_action)
	if _btn_nodes.has(_action):
		_btn_nodes[_action].panel.modulate = Color(1, 1, 1, 0.55)

func _release_action(_action: String) -> void:
	Input.action_release(_action)
	if _btn_nodes.has(_action):
		_btn_nodes[_action].panel.modulate = Color(1, 1, 1, 1.0)

func _process(_delta: float) -> void:
	_update_visibility()

func _update_visibility() -> void:
	if not _enabled:
		return
	var _nia: Node = game.nia if is_instance_valid(game.nia) else null
	var _in_game: bool = is_instance_valid(_nia) and not _nia.is_paused and not game.transing
	var _rect := get_viewport().get_visible_rect()
	var _scene_path: String = get_tree().current_scene.scene_file_path if get_tree().current_scene else ""
	var _menu_scene: bool = _scene_path.contains("title") or _scene_path.contains("splash")

	if _move_drawer.size != _rect.size:
		_resize_ui(_rect)

	for _a in _btn_nodes:
		_btn_nodes[_a].label.visible = _in_game
		_btn_nodes[_a].panel.visible = _in_game
	_move_drawer.visible = _in_game
	_tap_hint.visible = (not _in_game) and _menu_scene
	if not _in_game:
		_release_move()
		_release_cam()
		for _a in _btn_nodes:
			Input.action_release(_a)

func _resize_ui(_rect: Rect2) -> void:
	var _size := _rect.size
	var _margin := _size.y * 0.02
	var _btn_size := _size.y * 0.13
	var _spacing := _size.y * 0.008
	for _i in BUTTONS.size():
		var _b: Dictionary = BUTTONS[_i]
		var _pos := Vector2(_size.x - _margin - _btn_size, _size.y - _margin - ((_btn_size + _spacing) * (_i + 1)))
		var _r := Rect2(_pos, Vector2(_btn_size, _btn_size))
		if _btn_nodes.has(_b.action):
			_btn_nodes[_b.action].rect = _r
			_btn_nodes[_b.action].panel.position = _r.position
			_btn_nodes[_b.action].panel.size = _r.size
			_btn_nodes[_b.action].label.position = _r.position
			_btn_nodes[_b.action].label.size = _r.size
		else:
			var _panel := Panel.new()
			_panel.position = _r.position
			_panel.size = _r.size
			var _sb := StyleBoxFlat.new()
			_sb.bg_color = Color(0, 0, 0, 0.32)
			_sb.border_color = Color(1, 1, 1, 0.55)
			_sb.set_border_width_all(2)
			_sb.set_corner_radius_all(int(_btn_size * 0.24))
			_panel.add_theme_stylebox_override("panel", _sb)
			_root.add_child(_panel)
			var _lbl := Label.new()
			_lbl.text = _b.label
			_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			_lbl.position = _r.position
			_lbl.size = _r.size
			_lbl.add_theme_font_size_override("font_size", int(_btn_size * 0.26))
			_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
			_root.add_child(_lbl)
			_btn_nodes[_b.action] = {"rect": _r, "label": _lbl, "panel": _panel}
	if _move_drawer:
		_move_drawer.size = _size

func _paint_move_stick(c: Control) -> void:
	for _idx in _roles:
		if _roles[_idx] == "move":
			c.draw_circle(_move_origin, _STICK_RADIUS, Color(1, 1, 1, 0.14))
			c.draw_arc(_move_origin, _STICK_RADIUS, 0.0, TAU, 48, Color(1, 1, 1, 0.5), 2.0)
			var _knob: Vector2 = _move_origin + _stick_vector().limit_length(1.0) * _STICK_RADIUS * 0.45
			c.draw_circle(_knob, _STICK_RADIUS * 0.32, Color(1, 1, 1, 0.45))
			return

func _stick_vector() -> Vector2:
	var _x := 0.0
	var _y := 0.0
	for _idx in _roles:
		if _roles[_idx] == "move":
			_x = Input.get_action_strength("right") - Input.get_action_strength("left")
			_y = Input.get_action_strength("down") - Input.get_action_strength("up")
	return Vector2(_x, _y)


# 内部类：负责绘制摇杆
class MoveDrawer extends Control:
	var layer_owner: CanvasLayer

	func _draw() -> void:
		if layer_owner and layer_owner._enabled:
			layer_owner._paint_move_stick(self)

	func _notification(_what: int) -> void:
		if _what == NOTIFICATION_RESIZED:
			queue_redraw()
