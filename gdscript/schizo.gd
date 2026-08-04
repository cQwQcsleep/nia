extends VisibleOnScreenNotifier3D
@export var _to_toggle: Array[Node3D]
var _can_toggle: bool = false

func _ready() -> void :
 if get_parent() is Node3D:
  _to_toggle.append(get_parent())
func _on_area_body_entered(_body: Node3D) -> void :
 if _body is player: _can_toggle = true
func _on_area_body_exited(_body: Node3D) -> void :
 if _body is player: _can_toggle = false

func _on_screen_exited() -> void :
 if _to_toggle and _can_toggle:
  for _a in _to_toggle:
   _a.process_mode = Node.PROCESS_MODE_DISABLED
   _a.hide()
