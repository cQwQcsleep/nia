@tool
extends Node3D
class_name entrance
@export var environment: Environment
@export var stage_light: Color = Color.WHITE
@export var ignore: Node3D
func _enter_tree() -> void :
 if Engine.is_editor_hint():
  for a in self.get_children(): a.queue_free()
  var _debug_arrow = Sprite3D.new()
  _debug_arrow.rotation_degrees.x = 90
  _debug_arrow.texture = load("res://texture/debug_entrance_arrow.png")
  self.add_child(_debug_arrow)
