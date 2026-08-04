extends CPUParticles3D
class_name moveable_motion
var _rigibody: RigidBody3D
var _mesh: MeshInstance3D
func _ready() -> void :
 self.emitting = false
 self.add_to_group("stage_lit")
 set_physics_process_internal(false)
 await get_tree().current_scene.ready
 _mesh = get_parent()
 _rigibody = _mesh.get_parent()
 var _temp_grad = Gradient.new()
 _temp_grad.offsets = []
 _temp_grad.colors = []
 await get_tree().process_frame
 _temp_grad.add_point(0.0, Color.TRANSPARENT)
 _temp_grad.add_point(0.1, Color.WHITE)
 _temp_grad.add_point(0.3, Color.WHITE)
 _temp_grad.add_point(1.0, Color.TRANSPARENT)
 self.amount = 4
 self.color_ramp = _temp_grad
 self.gravity.y = 0
 self.one_shot = true
 self.lifetime = 0.3
 self.mesh = _mesh.mesh.duplicate()
 self.color.a = 0.1
 self.scale_amount_min = _mesh.scale.x
 for _x in self.mesh.get_surface_count():
  var _temp_mat = self.mesh.surface_get_material(_x).duplicate()
  _temp_mat.transparency = 4
  _temp_mat.render_priority = -2
  _temp_mat.vertex_color_use_as_albedo = true
  self.mesh.surface_set_material(_x, _temp_mat)
 set_physics_process_internal(true)
func _physics_process(_delta: float) -> void :
 var _length = _rigibody.angular_velocity.length() + _rigibody.linear_velocity.length()
 if _length > 3.0: self.emitting = true
 else: if self.emitting: self.emitting = false
