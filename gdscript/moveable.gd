extends RigidBody3D
class_name buoyancy
@export var type: int = 0
@export var float_force: = 1.0
@export var water_drag: = 0.05
@export var water_angular_drag: = 0.05
@export var _height: float = 0.0
@export var _can_move: bool = false
@export var _col_sfx: AudioStream
@export var _is_floating: bool = false
var _cd_col: bool = false
var _init_rot: Vector3
@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var submerged: = false
var spin_velocity: = 0.0
func _ready() -> void :
 self._height = self.global_position.y + float_force
 _init_rot = self.global_rotation
 if !_can_move:
  self.axis_lock_linear_x = true
  self.axis_lock_linear_z = true
  self.axis_lock_angular_x = true
  self.axis_lock_angular_y = true
  self.axis_lock_angular_z = true
  if _is_floating:
   var _float_timer = Timer.new()
   _float_timer.autostart = true
   _float_timer.one_shot = true
   _float_timer.wait_time = 1.5
   _float_timer.timeout.connect( func():
    self.apply_central_impulse(Vector3(0, 0.8, 0))
    _float_timer.start(randf_range(1.2, 1.6))
    )
   self.call_deferred("add_child", _float_timer)
 if !self.angular_damp:
  self.angular_damp = 10.0
 if _col_sfx:
  self.contact_monitor = true
  self.max_contacts_reported = 2
  self.body_entered.connect( func(_value):
   if _cd_col: return
   _cd_col = true
   game.rumble(0, 0.2, 0.2, 0.05)
   await audio.play_snd_spatial(_col_sfx, self.global_position, randf_range(8.0, 14.0))
   _cd_col = false

   )
func _physics_process(_delta):
 submerged = false


 var depth = _height - self.global_position.y
 if depth > 0:
  submerged = true
  apply_force(Vector3.UP * float_force * gravity * depth, self.global_position - global_position)
func _integrate_forces(state: PhysicsDirectBodyState3D):

 if submerged:
  state.linear_velocity *= 1 - water_drag
  state.angular_velocity *= 1 - water_angular_drag


 match type:
  2:
   var current_quat: = Quaternion(state.transform.basis)
   var target_quat: = Quaternion(Basis.from_euler(_init_rot))

   var diff: = current_quat.inverse() * target_quat
   var angle: = diff.get_angle()
   var axis: = diff.get_axis().normalized()


   state.angular_velocity = axis * angle * 2.2
