extends CharacterBody3D

var _gravity: float = 24.0
var _hurry_speed = 6
var _walk_speed = 3
var _move_speed = _walk_speed

var look_dir: Vector2

var _jump_height = 8
var _cam_sens = 3.0

var _walk_step: int = 0
var _buffer_y: float
var _can_kneel: bool = true
var _kneel_strafe: float = 1.0
func _ready() -> void :
 Input.mouse_mode = Input.MOUSE_MODE_CAPTURED



 pass
var _smooth_dir: Vector2
func _physics_process(delta):
 if Input.is_action_just_pressed("ui_cancel"):
  Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
 if Input.is_action_just_pressed("ui_accept"):
  Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
 _tilt(_buffer_y)
 _buffer_y = self.rotation.y
 velocity.y += - _gravity * delta
 var input = Input.get_vector("left", "right", "up", "down")
 var movement_dir = transform.basis * Vector3(input.x, 0, input.y)

 velocity.x = move_toward(velocity.x, movement_dir.x * (_move_speed * _kneel_strafe), 16.0 * delta)
 velocity.z = move_toward(velocity.z, movement_dir.z * (_move_speed * _kneel_strafe), 16.0 * delta)








 if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
  _handle_joypad_camera_rotation(delta)


 move_and_slide()
 if movement_dir && is_on_floor():
  if $walk_step.is_stopped():
   _take_step()
   $walk_step.start(clamp(0.6 - ((_move_speed * _kneel_strafe) / 10.0), 0.2, 1.0))
 else:
  $walk_step.stop()
 if is_on_floor() and Input.is_action_pressed("jump"):
  velocity.y = _jump_height * _kneel_strafe
 if self.position.y < -100:
  self.position = Vector3(0, 2, 0)






 self.rotation.y = _cam_dir.y
 %view.rotation.x = _cam_dir.x
 %view.rotation.x = clampf( %view.rotation.x, - deg_to_rad(80), deg_to_rad(80))

 look_dir = Vector2.ZERO


 if Input.is_action_just_pressed("right_mouse"):
  movement_dir = Vector3.ZERO
 if Input.is_action_pressed("right_mouse"):
  _adjust_pov(-3, 0.1)
func _input(event):
 if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:






  var scale_factor: Vector2
  scale_factor.x = get_viewport().size.x / get_viewport().get_visible_rect().size.x
  scale_factor.y = get_viewport().size.y / get_viewport().get_visible_rect().size.y
  look_dir = Vector2(event.relative.x * scale_factor.x, event.relative.y * scale_factor.y) * 0.001

  _rotate_camera()

 if Input.is_action_just_pressed("shift"):
  if velocity && is_on_floor():
   _move_speed = _hurry_speed * _kneel_strafe


   _adjust_pov(10, 0.1)
 if Input.is_action_just_released("shift"):
  _move_speed = _walk_speed * _kneel_strafe

  _adjust_pov(true, 0.4)
 if Input.is_action_just_pressed("kneel"): _kneel(true)
 if Input.is_action_just_released("kneel"): _kneel()
 if Input.is_action_just_released("right_mouse"):
  _adjust_pov(true, 0.1)

var _cam_dir: Vector3
func _rotate_camera(sens_mod: float = 1.0) -> void :




 _cam_dir.y = self.rotation.y - (look_dir.x * _cam_sens * sens_mod)
 _cam_dir.x = clampf( %view.rotation.x - look_dir.y * _cam_sens * sens_mod, -1.5, 1.5)







var _fov_tween: Tween
func _adjust_pov(_fov, _time: float):
 var _temp_fov
 if _fov is bool:
  _temp_fov = 60
 else:
  _temp_fov = %view.fov + _fov
  pass
 if _fov_tween: if _fov_tween.is_running: _fov_tween.kill()



 _fov_tween = create_tween()
 _fov_tween.tween_property( %view, "fov", clamp(_temp_fov, 40, 100), _time)
 pass
func _take_step():
 create_tween().tween_property( %view, "position:y", randf_range(0.05 * _kneel_strafe, 0.1 * _kneel_strafe), 0.1)
 create_tween().tween_property( %view, "position:y", 0.0, 0.2).set_delay(0.1).set_trans(Tween.TRANS_CIRC)
func _tilt(_a: float, _b: bool = false):

 if abs(_a - self.rotation.y) < 1:
  %view_box.rotation.z = lerp( %view_box.rotation.z, (deg_to_rad(clamp((_a - self.rotation.y) * 14, -22.0, 22.0))), 0.4)
 pass
func _kneel(_do: bool = false):
 match _do:
  true:
   if !_can_kneel: return
   _can_kneel = false
   _adjust_pov(-4, 0.3)
   await create_tween().tween_property( %collider, "scale:y", 0.4, 0.1).finished
   _kneel_strafe = 0.6

  _:
   _can_kneel = false
   _adjust_pov(true, 0.1)
   await create_tween().tween_property( %collider, "scale:y", 1.0, 0.1).finished
   _kneel_strafe = 1.0
   _can_kneel = true
func _handle_joypad_camera_rotation(delta: float, sens_mod: float = 1.0) -> void :
 var joypad_dir: Vector2 = Input.get_vector(&"look_left", &"look_right", &"look_up", &"look_down")
 if joypad_dir.length() > 0:
  look_dir += (joypad_dir / 2) * delta
  _rotate_camera(sens_mod)
