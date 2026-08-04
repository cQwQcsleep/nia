class_name attach_player
extends Node3D
@export var _ignore_y: bool = false
@export var _ignore_x: bool = false
@export var _y_limit: Vector2 = Vector2(1.0, -1.0)
@export var _update_rotation = true
@export var _attach_to_chara: bool = false
@export var _attach_to_cam: bool = false
@export var _ignore_freecam: bool = false
var _init_y: float
var _init_x: float
var _remote: RemoteTransform3D

func _ready() -> void :
 set_physics_process(_ignore_y)
 if _ignore_x: set_physics_process(true)
 _init_y = self.global_position.y
 _init_x = self.global_position.x
 await get_tree().current_scene.ready
 if game.nia:
  _remote = RemoteTransform3D.new()
  _remote.update_scale = false
  _remote.update_rotation = _update_rotation
  _remote.remote_path = get_parent().get_path()
  if _attach_to_cam: game.nia.get_node("%view").add_child(_remote)
  else:
   game.nia.add_child(_remote)
   if !_ignore_freecam:
    game.nia.active_remote.append(_remote)
 else:
  set_physics_process(false)
func _physics_process(_delta: float) -> void :
 if game.nia:
  if _ignore_y: _remote.global_position.y = _init_y
  if _ignore_x: _remote.global_position.x = _init_x
 if game.nia: _remote.global_rotation.x = clampf(_remote.global_rotation.x, _y_limit.y, _y_limit.x)
