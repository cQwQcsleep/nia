@tool
extends EditorScenePostImport
@export var test: bool

func _post_import(scene):
 iterate(scene)
 return scene


func iterate(node):
 if node != null:
  if node is PhysicsBody3D:
   if node.has_meta("extras"):
    if node.get_meta("extras") is Dictionary:
     for _tag in node.get_meta("extras"):
      if _tag == "cam":
       node.set_collision_layer_value(1, false)
       node.set_collision_layer_value(10, true)
  if node is RigidBody3D:
   node.set_script(load("res://gdscript/moveable.gd"))
  elif node is CollisionShape3D:
   if node.shape:
    if node.shape is ConcavePolygonShape3D:
     node.shape.backface_collision = true
  elif node is MeshInstance3D:
   for _x in node.get_surface_override_material_count():
    if node.get_active_material(_x) is BaseMaterial3D:
     node.get_active_material(_x).texture_filter = 5
     node.get_active_material(_x).roughness = 1.0
   if node.has_meta("extras"):
    if node.get_meta("extras") is Dictionary:
     for _tag in node.get_meta("extras"):
      if _tag == "cam":
       for _a in node.get_children():
        if _a is PhysicsBody3D:
         _a.set_collision_layer_value(1, false)
         _a.set_collision_layer_value(10, true)

   if "-nolight" in node.name:
    node.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
























  for child in node.get_children():
   iterate(child)
