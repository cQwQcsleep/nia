extends Node3D
class_name dream_looper

@export var _bounds: MeshInstance3D
@export var _all_axis: bool = true
var _aabb: AABB
@export var _world: Node3D
var _to_skip: Array

var _loop_amount: int = 0
@export var _door_probability: int = 6
@export var _fade_on_loop: bool = false
var _is_interact: interactable
var _fade_rect: ColorRect

func _ready() -> void :
 await get_tree().current_scene.ready
 _aabb = _bounds.get_aabb()
 _aabb.position = _bounds.get_aabb().position + _bounds.position
 var _offset = _aabb.size
 _to_skip = game.findall("skip")
 _toggle_loop(false)
 if self.get_child_count() > 0:
  if get_child(0) is interactable: _is_interact = get_child(0)
 if _fade_on_loop:
  var _cv = CanvasLayer.new()
  _fade_rect = ColorRect.new()
  _fade_rect.color = Color.BLACK
  _fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
  _fade_rect.custom_minimum_size = Vector2(640, 480)
  _fade_rect.color.a = 0


  _cv.call_deferred("add_child", _fade_rect)

  self.add_child(_cv)
 for x in [-1, 0, 1]:
  for z in [-1, 0, 1]:
   if x == 0 and z == 0: continue
   if !_all_axis and (z != 0 or x == 0):
    continue


   var _temp_world: Node3D
   _temp_world = _world.duplicate(2)
   _temp_world.transform.origin = Vector3(x * _offset.x, _world.global_position.y, z * _offset.z)
   self.call_deferred("add_child", _temp_world)
 await get_tree().process_frame
 for _skipped in game.findall("skip"):
  if _skipped not in _to_skip: _skipped.queue_free()
var _loop_cd: bool = false
func _process(_delta: float) -> void :
 if game.active_stage.is_static:
  set_process(false)
  return
 var _player_pos = game.nia.global_transform.origin
 var _loop = false

 if _fade_on_loop:
  if _player_pos.x - 1.0 < _aabb.position.x:
   _fade_rect.color.a = 0.9 - (_player_pos.x - _aabb.position.x)
  elif _player_pos.x + 1.0 > _aabb.position.x + _aabb.size.x:
   _fade_rect.color.a = 0.9 + (_player_pos.x - (_aabb.position.x + _aabb.size.x))
  if _all_axis:
   if _player_pos.z - 1.0 < _aabb.position.z:
    _fade_rect.color.a = 0.9 - (_player_pos.z - _aabb.position.z)
   elif _player_pos.z + 1.0 > _aabb.position.z + _aabb.size.z:
    _fade_rect.color.a = 0.9 + (_player_pos.z - (_aabb.position.z + _aabb.size.z))
 if _player_pos.x < _aabb.position.x:
  _player_pos.x += _aabb.size.x
  _loop = true
 elif _player_pos.x > _aabb.position.x + _aabb.size.x:
  _player_pos.x -= _aabb.size.x
  _loop = true
 if _player_pos.z < _aabb.position.z and _all_axis:
  _player_pos.z += _aabb.size.z
  _loop = true
 elif _player_pos.z > _aabb.position.z + _aabb.size.z and _all_axis:
  _player_pos.z -= _aabb.size.z
  _loop = true
 if _loop:
  game.nia.global_transform.origin = _player_pos
  _add_loop()
  if _loop_amount > randi_range(clamp(2, 0, _door_probability), _door_probability):
   _toggle_loop(true)
   if _is_interact: _is_interact.interact()
  await get_tree().process_frame
  for _particle_loop in game.findall("loop_particle_restart"):
   _particle_loop.restart(true)
func _add_loop():
 if !_loop_cd:
  _loop_cd = true
  _loop_amount = clamp(_loop_amount + 1, 0, 99)
  await get_tree().create_timer(8.0).timeout
  _loop_cd = false
func _toggle_loop(_state: bool = false):
 if game.findall("loop_only"):
   for _toggle in game.findall("loop_only"):
    match _state:
     false: _toggle.process_mode = PROCESS_MODE_DISABLED
     _: _toggle.process_mode = PROCESS_MODE_INHERIT
    if _toggle.visible != _state:
     _toggle.visible = _state
