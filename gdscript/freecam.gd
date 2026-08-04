extends Node3D

const SHIFT_MULTIPLIER = 2.5
const ALT_MULTIPLIER = 1.0 / SHIFT_MULTIPLIER

@export_range(0.0, 1.0) var sensitivity: float = 0.25

var _mouse_position = Vector2(0.0, 0.0)


var _direction = Vector3(0.0, 0.0, 0.0)
var _velocity = Vector3(0.0, 0.0, 0.0)
var _acceleration = 20
var _deceleration = -5


var _w = false
var _s = false
var _a = false
var _d = false
var _q = false
var _e = false
var _shift = false
var _alt = false

var _cd_filter: bool = false

func _ready() -> void :
 %freecam_idle_timer.timeout.connect( func():
  if game.nia.is_freecam:
   %photo_mode_layer.hide())
 set_process(false)
 set_process_input(false)
 set_process_unhandled_input(false)
 self.hide()
var _cd_fov: bool = false
func _adjust_fov(_value: int = 2):
 self.fov = clampi(self.fov + _value, 30, 95)
 if !_cd_fov and int(self.fov) not in [30, 95]:
  _cd_fov = true
  audio.play_snd_spatial(game.loadres("camera_lens"), self.global_position, 14.0, randf_range(1.0, 1.1), randf_range(0.6, 0.9))
  await get_tree().create_timer(0.1).timeout
  _cd_fov = false
func _input(event):
 if event is InputEventMouseMotion: _mouse_position = event.relative









 var _temp_vector: Vector2 = Input.get_vector(&"left", &"right", &"up", &"down")
 _w = - _temp_vector.y if Input.is_action_pressed("up") else 0
 _s = _temp_vector.y if Input.is_action_pressed("down") else 0
 _a = - _temp_vector.x if Input.is_action_pressed("left") else 0
 _d = _temp_vector.x if Input.is_action_pressed("right") else 0
 _q = Input.is_action_pressed("down_photo_mode")
 _e = Input.is_action_pressed("up_photo_mode")
 _shift = Input.is_action_pressed("run_freecam")
 if Input.is_action_just_pressed("reset_freecam"):
  if self.fov != 55:
   audio.play_snd_spatial(game.loadres("swish"), self.global_position, 8.0, -1.0, 0.3)
   _adjust_fov(0)
   self.fov = 55
 if Input.is_action_pressed("wheel_up"):
  _adjust_fov(-2)
 if Input.is_action_pressed("wheel_down"):
  _adjust_fov()
 if Input.is_action_just_pressed("photo_mode_view_pictures"):
  game.view_screenshots()
 if Input.is_action_just_pressed("photo_mode_screen_filter"):
  if _cd_filter: return
  _cd_filter = true
  config.screen_filter = !config.screen_filter
  game.apply_config()
  await get_tree().create_timer(1.0).timeout
  _cd_filter = false












 if game.nia.is_freecam and _velocity:
  _handle_hint_idle()
func _handle_hint_idle():
 %freecam_idle_timer.start()
 if !config.cam_hide_ui: %photo_mode_layer.show()
func _physics_process(delta: float) -> void :

 _update_movement(delta)
 _handle_joypad_camera_rotation(delta)

func _unhandled_input(event: InputEvent) -> void :
 if event is InputEventMouseMotion: if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: _rotate_camera(event)
func _update_movement(delta):
 _direction = Vector3(
  (_d as float) - (_a as float), 
  (_e as float) - (_q as float), 
  (_s as float) - (_w as float))

 var offset = _direction * _acceleration * config.cam_vel_mul * delta\
+ _velocity.normalized() * _deceleration * config.cam_vel_mul * delta
 var speed_multi = 1
 if _shift: speed_multi *= SHIFT_MULTIPLIER
 if _alt: speed_multi *= ALT_MULTIPLIER
 if _direction == Vector3.ZERO and offset.length_squared() > _velocity.length_squared(): _velocity = Vector3.ZERO
 else:
  _velocity.x = clamp(_velocity.x + offset.x, - config.cam_vel_mul, config.cam_vel_mul)
  _velocity.y = clamp(_velocity.y + offset.y, - config.cam_vel_mul, config.cam_vel_mul)
  _velocity.z = clamp(_velocity.z + offset.z, - config.cam_vel_mul, config.cam_vel_mul)
  translate(_velocity * delta * speed_multi)
  if !game.is_debug:
   var global_bounds = AABB(game.nia.global_transform.origin + %photo_mode_bounds.custom_aabb.position, %photo_mode_bounds.custom_aabb.size)
   var clamped_position = global_transform.origin.clamp(global_bounds.position, global_bounds.position + global_bounds.size)
   self.global_transform.origin = clamped_position












func _rotate_camera(_input = Vector2.ZERO, _is_joy: bool = false) -> void :
 if _input is InputEvent: _input = Vector2(_input.relative.x, _input.relative.y)
 var _screen_size_adjust: Vector2 = Vector2.ONE
 if !_is_joy: _screen_size_adjust = Vector2(get_viewport().get_final_transform().get_scale().x, get_viewport().get_final_transform().get_scale().y)

 self.rotation.x -= (-1.0 if config.cam_invert_y else 1.0) * (_input.y * _screen_size_adjust.x * (config.cam_sens * 0.01))
 self.rotation.y -= (-1.0 if config.cam_invert_x else 1.0) * (_input.x * _screen_size_adjust.y * (config.cam_sens * 0.01))
 self.rotation_degrees.x = clamp(self.rotation_degrees.x, -80, 60)
 if game.nia.is_freecam: _handle_hint_idle()
func _handle_joypad_camera_rotation(_delta: float) -> void :
 var joypad_dir: Vector2 = Input.get_vector(&"look_left_photo_mode", &"look_right_photo_mode", &"look_up_photo_mode", &"look_down_photo_mode")
 if joypad_dir.length() > 0: _rotate_camera(joypad_dir * 8.0, true)
func _on_visibility_changed() -> void :
 match self.is_visible_in_tree():
  true: _toggle_self(true)
  false: _toggle_self(false)
func _toggle_self(_state: bool):
 self.current = _state
 game.nia.get_node("%view").current = !_state
 set_process(_state)
 set_process_input(_state)
 set_process_unhandled_input(_state)
 $audio_listener_3d.current = _state
 _adjust_fov(0)
