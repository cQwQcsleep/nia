extends Area3D
class_name interactable
@export_file("*.tscn") var _to_stage: String
@export var _to_entrance: int = 0
@export var is_trigger: bool = false
@export var uninteractable: bool = false
@export var is_random: bool = false
@export var _id: int = 0
@export var _interact_sfx: AudioStream
@export var _highlight_mesh: MeshInstance3D
@export var _offset: Vector3
@export var _offset_rot: float
@export var voices: bool = true

func _ready() -> void :
 if get_parent() is MeshInstance3D: _highlight_mesh = get_parent()
 if _highlight_mesh:
  %highlight.mesh = _highlight_mesh.mesh
  %highlight.hide()
  var _aabb = _highlight_mesh.mesh.get_aabb()
  var _position = _aabb.position + _aabb.size / 2.0
  var _box_shape = BoxShape3D.new()
  _box_shape.size = _aabb.size
  $collider.shape = _highlight_mesh.mesh.create_convex_shape(true, false)
  $collider.global_position = _highlight_mesh.global_position
 if is_random:
  uninteractable = true
  match randi_range(0, 9):
   4:
    uninteractable = false
 if uninteractable or !voices:
  %listen.queue_free()
func interact() -> bool:
 if !is_trigger:
  if game.active_stage.anomaly_occurring or uninteractable:
   game.nia.no()
   return false
  else:
   game.rumble(0, 0.2, 0.22, 0.06)
   match _id:
    1:
     create_tween().tween_property(game.nia.chara, "global_rotation_degrees:y", _offset_rot, 0.2)
     create_tween().tween_property(game.nia, "global_position", self.global_position + _offset, 0.2)
     await game.nia.sit(true)
     return false
    2:
     audio.play_snd(_interact_sfx, -1.0, 0.2)
     game.to_entrance = _to_entrance
     if config.last_visited and config.last_visited != "stage_bedroom" and config.last_visited != "stage_fog":
      game.change_stage(config.last_visited)
     else:
      game.change_stage(_to_stage)
    _:
     audio.play_snd(_interact_sfx, -1.0, 0.2)
     game.to_entrance = _to_entrance
     game.change_stage(_to_stage)

 return true
func highlight(_unlit: bool = false):
 if !is_instance_valid( %highlight): return


 match _unlit:
  false: %highlight.show()
  _:
   if !is_instance_valid( %highlight): return
   %highlight.material_override.next_pass.set_shader_parameter("albedo", %highlight.material_override.next_pass.get_shader_parameter("albedo").inverted())
   %highlight.hide()
