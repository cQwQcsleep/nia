class_name player extends CharacterBody3D


@export var _head: MeshInstance3D
@export var _tail: MeshInstance3D
@export var _tail_ribbon: MeshInstance3D
@export var _scarf: MeshInstance3D
@export var chara: Node3D
@export var _skeleton: Skeleton3D

@export var acc_hair_ribbon: MeshInstance3D
@export var acc_hair_loop: MeshInstance3D

var gravity: float = 14.0
var _hurry_speed: float = 5.4
var _walk_speed: float = 2.0
var _move_speed: float = _walk_speed
var _jump_height: float = 0.8
var _acceleration: float = 42

var _puppy_excitement_value: float = 1.0

var _move_dir: Vector2

var _walk_vel: Vector3
var _grav_vel: Vector3
var _jump_vel: Vector3

var _max_zoom: float = 5.0
var _min_zoom: float = 1.2
var strafe: float = 1.0

var _is_sequence: bool = false
var sequence: int = 0
var _is_running: bool = false
var _is_runnig_slow: bool = false
var _is_jumping: bool = false
var _is_in_air: bool = false

var is_paused: bool = false
var can_interact: bool = false
var is_freecam: bool = false

var _cd_cam_reset: bool = false
var _cd_run: bool = false
var _cd_sit: bool = false
var _cd_freecam: bool = false
var _cd_step: bool = false

var active_remote: Array

var _sleepy_timer: Timer = Timer.new()

@export var unconscious: bool = false
@export var remote: RemoteTransform3D
@export var shadow: DecalCompatibility
@onready var indicator_marker = %indicator_marker

func _ready() -> void :
 game.nia = self
 %ray_interact.add_exception(self)
 %cam_arm.add_excluded_object(self.get_rid())
 %cam_arm.spring_length = config.cam_zoom
 %water_ripple.emitting = false
 %run_smoke.emitting = false
 game.capture_mice(true)
 %view.fov = 10
 %trans_vignette.material.set_shader_parameter("alpha", 0.0)
 %trans_saturation.material.set_shader_parameter("value", 1.0)
 AudioServer.get_bus_effect(5, 0).cutoff_hz = 20000
 game.focus_changed.connect(_capture_mice)
 _sleepy_timer.wait_time = 744
 _sleepy_timer.one_shot = true
 _sleepy_timer.timeout.connect( func():
  game.add_stat("stat_sleepy")
  )
 call_deferred("add_child", _sleepy_timer)
 await game.active_stage.ready
 match game.active_stage.weather:
  2, 4:
   _tail_ribbon.hide()
   _scarf.show()
 match randi_range(0, 45):
   10:
    if ! %bug_step.emitting:
     %bug_step.one_shot = false
     %bug_step.emitting = true
 _ceiling_check()
 _rotate_camera(Vector2.ONE)
 if config.outlived >= 280: empty_face()
 var _tween: Tween
 _tween = create_tween()
 _tween.set_loops()
 var _temp_scale = Vector3(1.029, 0.975, 1.034)
 _tween.tween_method(_set_bone, Vector3.ONE, _temp_scale, 1.1).set_delay(0.1).set_trans(Tween.TRANS_SINE)
 _tween.tween_method(_set_bone, _temp_scale, Vector3.ONE, 1.1).set_delay(0.1).set_trans(Tween.TRANS_SINE)
 if game.active_stage.sequence:
  _head.set_blend_shape_value(0, 1.0)
  %cam_arm.spring_length = 4.0
  %cam_arm.collision_mask = 0
  %view.fov = 50
  vignette(true)
  _is_sequence = true
  $anim_player.play("sequence_00")
  audio.play_snd_spatial(game.loadres("cloth_00"), self.global_position, 8.0)
  game.find("pause_menu").process_mode = Node.PROCESS_MODE_DISABLED
  unconscious = true
  is_paused = true
  %nia_outline_trans.show()
  %cam_box.rotation_degrees.y = 40

  create_tween().tween_property( %cam_box, "rotation_degrees:x", -2.0, 7.0).from(15.0).set_trans(Tween.TRANS_SINE)
  create_tween().tween_property( %cam_box, "rotation_degrees:y", 40.0, 8.0).from(50.0).set_trans(Tween.TRANS_SINE)


  game.loadres("mat_player").next_pass.transparency = 4
  game.loadres("mat_player").next_pass.render_priority = 30
  game.loadres("mat_player").next_pass.depth_draw_mode = 1



  await create_tween().tween_property( %nia_outline_trans.get_active_material(0), "albedo_color:a", 0.0, 5.0).from(1.0).set_delay(2.0).finished

  _head.set_blend_shape_value(0, 0.5)
  await get_tree().create_timer(1.0).timeout
  _head.set_blend_shape_value(0, 1.0)
  await get_tree().create_timer(1.0).timeout
  _head.set_blend_shape_value(0, 0.5)
  await get_tree().create_timer(1.0).timeout
  _head.set_blend_shape_value(0, 0.1)
  await get_tree().create_timer(3.0).timeout

  audio.play_snd_spatial(game.loadres("cloth_00"), self.global_position, 8.0)
  %nia_outline_trans.hide()
  unconscious = false
  is_paused = false


  game.find("pause_menu").process_mode = Node.PROCESS_MODE_INHERIT
  _is_sequence = false
  vignette(false)
  $anim_player.stop(true)

  await get_tree().create_timer(0.2).timeout

  %cam_arm.collision_mask = 17
  _take_step()
 game.loadres("mat_player").next_pass.render_priority = -1

var _interactable
var _collision_occured: bool = false
var _collision_tween: Tween
var _vel_len: int
func align_with_y(xform, new_y):
 xform.basis.y = new_y
 xform.basis.x = - xform.basis.z.cross(new_y)
 xform.basis = xform.basis.orthonormalized()
 return xform
func _set_bone(_value):
 _skeleton.set_bone_pose_scale(_skeleton.find_bone("Chest"), _value)

var _vel_phase_fix: float
func _physics_process(delta):

 if is_instance_valid(game.active_stage):
  if self.global_position.y < game.active_stage.respawn_y or _grav_vel.y < -200: respawn()

 _vel_len = (abs(velocity.x) + abs(velocity.z))
 if _vel_phase_fix == sign(velocity.x):
  if (velocity.x + velocity.z): chara.rotation.y = fmod(lerp_angle(chara.rotation.y, atan2( - velocity.x, - velocity.z), ((15 - _vel_len) * strafe) * delta), deg_to_rad(360.0))
 _vel_phase_fix = sign(velocity.x)
 var _fov_vel = abs(velocity.y)
 if !_is_sequence:
  if _vel_len >= 1 and _vel_len < 6 and !_is_running:
   if %view.fov != 60.0: %view.fov = lerpf( %view.fov, 60.0, 0.1)
  elif _vel_len >= 5 and _is_running:
   if %view.fov < 70.0: %view.fov = lerpf( %view.fov, 70.0, 0.2)
  else:
   if !_is_running:
    if %view.fov != 55.0: %view.fov = lerpf( %view.fov, 55.0, 0.1)
 if !_vel_len: if _is_running: _is_running = false
 if !_is_in_air and abs(velocity.y) > 0.4:
  _take_step()
  _is_in_air = true
 elif !velocity.y and _is_in_air:
  _take_step()
  _is_in_air = false

 if _vel_len > 3.0 and !velocity.y:
  if ! %run_smoke.emitting: %run_smoke.emitting = true
 else:
  if %run_smoke.emitting: %run_smoke.emitting = false
 _angle_shadow()
 if %cam_arm.get_hit_length() < 0.3 and !is_freecam: chara.hide()
 else: chara.show()
 if _grav_vel.y < -60.0: respawn()
 if _grav_vel.y < -1.0:
  if is_sitting:
   sit()
 if velocity.y < -2.0:
  if ! %fall_velocity.playing: %fall_velocity.playing = true
  %fall_velocity.max_db = linear_to_db(clamp(abs(2.0 + velocity.y) * 0.06, 0.0, 1.2))
 else:
  if %fall_velocity.playing: %fall_velocity.playing = false
 if %ray_interact.is_colliding() and !is_sitting and !_howling:
  if is_instance_valid(_interactable):
   %control_hint.global_position = %view.unproject_position(_interactable.global_position)
  if is_instance_valid( %ray_interact.get_collider()) and !_collision_occured:
   if %ray_interact.get_collider() is interactable and is_instance_valid( %ray_interact.get_collider()): _interactable = %ray_interact.get_collider()
   match randi_range(0, 2):
    1: %indicator_tex.material.set_shader_parameter("invert", false)
    _: %indicator_tex.material.set_shader_parameter("invert", true)
   %indicator.show()
   %indicator_particle.emitting = true
   %control_hint.show()
   _interactable.highlight()
   _collision_occured = true
   _collision_tween = game.tween(_collision_tween)
   _collision_tween.set_parallel()
   _collision_tween.tween_property( %trans_vignette.material, "shader_parameter/alpha", 1.0, 0.8).set_trans(Tween.TRANS_SINE)
   _collision_tween.tween_property( %indicator, "scale", Vector2(2, 0.5), 0.2).from(Vector2.ZERO).set_trans(Tween.TRANS_SPRING)
   _collision_tween.tween_property( %indicator, "scale", Vector2(0.3, 3), 0.2).set_trans(Tween.TRANS_ELASTIC).set_delay(0.2)
   can_interact = true
   await _collision_tween.tween_property( %indicator, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_SPRING).set_delay(0.4).finished
 else:
  if _collision_occured:
   if is_instance_valid(_interactable):
    _interactable.highlight(true)
    _interactable = null
   _collision_occured = false
   _collision_tween = game.tween(_collision_tween)
   _collision_tween.set_parallel()
   _collision_tween.tween_property( %trans_vignette.material, "shader_parameter/alpha", 0, 0.8).set_trans(Tween.TRANS_SINE)

   await _collision_tween.tween_property( %indicator, "scale", Vector2(), 0.1).finished
   can_interact = false
   %indicator.hide()
   %indicator_particle.emitting = false
   %control_hint.hide()










 $anim_tail.speed_scale = clamp(velocity.length() * 0.2, 0.2, 0.9) * _puppy_excitement_value
 if !is_sitting: %tailwag_marker.position.y = clamp(lerp( %tailwag_marker.position.y, -1.3 + (velocity.length() * 0.5), 0.1), -2.0, 2.0)
 velocity = _walk(delta) + _gravity(delta) + _jump(delta)
 var _body = get_last_slide_collision()
 if _body and velocity:
  if _body.get_collider() is buoyancy:
   var push_force = velocity.length()
   var impulse_vector = - _body.get_normal() * push_force
   match _body.get_collider().type:
    1, 2:
     var _center = _body.get_collider().global_transform.origin
     var _contact_point = _body.get_position()
     var _offset = _contact_point - _center
     var push_direction = _walk_vel
     var torque_direction = _offset.cross(push_direction).normalized()

     _body.get_collider().apply_torque_impulse(torque_direction * push_force)
    _:
     _body.get_collider().apply_central_impulse(impulse_vector * 0.5)




 if is_on_ceiling() and _jump_vel: _jump_vel.y = 0
 move_and_slide()
 _handle_joypad_camera_rotation(delta)
var _zoom_tween: Tween
func _zoom(_dir):
 if is_paused: return
 _zoom_tween = game.tween(_zoom_tween)
 _zoom_tween.tween_property( %cam_arm, "spring_length", clamp( %cam_arm.spring_length + _dir, _min_zoom, _max_zoom), 0.2).set_trans(Tween.TRANS_SINE)
 config.cam_zoom = %cam_arm.spring_length
var _screenshot_cd: bool = false
func _capture_mice():
 if is_paused and !is_freecam: return
 if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE: game.capture_mice(true)
 else: game.capture_mice(false)
func _unhandled_input(event: InputEvent) -> void :
 if Input.is_action_just_pressed("freecam"): if game.is_debug: toggle_freecam()
 if Input.is_action_just_pressed("menu"): if is_freecam: toggle_freecam()
 if Input.is_action_just_pressed("howl"): _howl()
 if Input.is_action_just_pressed("toggle_mice"):
  _capture_mice()
 if Input.is_action_just_pressed("take_picture_photo_mode"):
  if is_freecam and !_screenshot_cd:
   _screenshot_cd = true
   var _was_hidden = %photo_mode_layer.visible
   %photo_mode_layer.hide()

   await RenderingServer.frame_post_draw
   await game.screenshot()
   await RenderingServer.frame_post_draw
   if _was_hidden and !config.cam_hide_ui: %photo_mode_layer.show()

   game.add_stat("stat_memory")
   await get_tree().create_timer(1.0).timeout
   _screenshot_cd = false
 if Input.is_action_just_pressed("smile_photo_mode"): smile()
 if is_freecam: return
 if event is InputEventMouseMotion: if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: _rotate_camera(event)
 if Input.is_action_pressed("wheel_up"): _zoom(-0.8)
 elif Input.is_action_pressed("wheel_down"): _zoom(0.8)
 if Input.is_action_just_pressed("reset_camera") and !_cd_cam_reset:
   if %cam_box.rotation.y == chara.rotation.y or is_paused: return
   _cd_cam_reset = true
   audio.play_snd_spatial(game.loadres("swish"), %cam_box.global_position, 8.0, -1.0, 0.5)
   create_tween().tween_property( %cam_box, "rotation:y", chara.rotation.y, 0.2).set_trans(Tween.TRANS_CIRC)
   await get_tree().create_timer(0.5).timeout
   _cd_cam_reset = false
 if Input.is_action_just_pressed("jump"):
  if ( !unconscious and !is_sitting and !is_paused) and is_on_floor():
   if game.active_stage.anomaly_occurring: no()
   else: _is_jumping = true

 if Input.is_action_just_pressed("sit"): sit()
 if Input.is_action_just_pressed("interact"):
  if _interactable and can_interact and !is_paused and !game.transing:
   stop()
   is_paused = true
   can_interact = false
   config.cam_zoom = %cam_arm.spring_length
   _collision_tween = game.tween(_collision_tween)
   _collision_tween.set_parallel()
   _collision_tween.tween_property( %indicator, "scale", Vector2.ONE, 0.2).from(Vector2(0.8, 0.5)).set_trans(Tween.TRANS_SPRING)

   if await _interactable.interact() == true: can_interact = false
   else:
    is_paused = false
    can_interact = true
 if Input.is_action_pressed("run") and !_cd_run: _run(config.auto_run)
 if Input.is_action_just_released("run"):
  _move_speed = _walk_speed
  _is_running = false
  _is_runnig_slow = false

var is_sitting: bool = false
var _sleep_tween: Tween

func sit(_is_seat: bool = false):
 if !_is_seat:
  if !is_on_floor() or velocity or is_paused or _cd_sit: return
  if game.active_stage.anomaly_occurring:
   no()
   return
  if !is_sitting and !game.active_stage.sit_override:
   if (self.global_position.y + 0.4) < water_begin and is_in_water:
    no()
    return
 stop()
 is_sitting = !is_sitting
 _sleepy_timer.stop()
 vignette(is_sitting)
 _cd_sit = true
 match is_sitting:
  true:
   _sleep_tween = game.tween(_sleep_tween)
   _puppy_excitement_value = 0.3
   %tailwag_marker.position.y = -0.2
   var _temp_bs = (
    func(_time: float): _head.set_blend_shape_value(0, _time)
    )
   _sleep_tween.tween_method(_temp_bs, 0.0, 0.5, 0).set_delay(randf_range(0.5, 3.0))
   _sleep_tween.tween_method(_temp_bs, 0.0, 1.0, 0).set_delay(randf_range(4.0, 10.0))
   _sleepy_timer.start()
  _:
   _puppy_excitement_value = 1.0
   game.tween(_sleep_tween, false)
 _take_step()
 audio.play_snd_spatial(game.loadres("cloth_00"), self.global_position, 8.0)
 await get_tree().create_timer(0.4).timeout
 _cd_sit = false
var is_smiling: bool = false
var _cd_smile: bool = false
func smile():
 if !is_freecam or is_sitting or _cd_smile: return
 if game.active_stage.anomaly_occurring:
  no()
  return
 _cd_smile = true
 _head.set_blend_shape_value(0, 0.0)
 audio.play_snd_spatial(preload("res://audio/sfx/purr_00.ogg"), self.global_position, 14.0, -1.0, randf_range(0.2, 0.4))
 is_smiling = !is_smiling
 match is_smiling:
  true:
   _puppy_excitement_value = 2.0
   %freecam.set_cull_mask_value(19, true)
  false:
   _puppy_excitement_value = 1.0
   %freecam.set_cull_mask_value(19, false)
 game.add_stat("stat_smile")
 await get_tree().create_timer(0.4).timeout
 _cd_smile = false
var _howling: bool = false
func _howl():
 if _howling or is_sitting: return
 if game.active_stage.anomaly_occurring:
  no()
  return
 _howling = true
 _head.set_blend_shape_value(8, 1.0)
 _head.set_blend_shape_value(9, 1.0)
 _head.set_blend_shape_value(12, 1.0)
 audio.play_snd_spatial(game.loadres("awoo"), self.global_position, 12.0, -1.0, 0.6)
 await create_tween().tween_property( %indicator_marker, "position:z", 0.01, 1.4).set_trans(Tween.TRANS_SINE).finished
 await create_tween().tween_property( %indicator_marker, "position:z", 0.008, 0.4).set_trans(Tween.TRANS_CUBIC).set_delay(0.7).finished
 game.add_stat("stat_howl")
 _head.set_blend_shape_value(8, 0.0)
 _head.set_blend_shape_value(9, 0.0)
 _head.set_blend_shape_value(12, 0.0)
 _howling = false
var is_in_water: bool = false
var water_begin: float
func submerge(_a: bool = true):
 self.is_in_water = _a
 if abs(velocity.y) > 0.6:
  %water_splash.explosiveness = 1.0
  %water_splash.emitting = _a

 var _sfx: AudioStream
 match _a:
  true: _sfx = game.loadres("water_splash")
  _:
   self.strafe = 1.0
   self.water_begin = 0
   _sfx = game.loadres("water_splash_out")
 if _sfx: audio.play_snd_spatial(_sfx, self.global_position, 6.0, -1.0, 0.8)
func _walk(delta: float) -> Vector3:
 if unconscious or is_freecam or is_paused: return Vector3.ZERO
 if config.auto_run and !game.active_stage.anomaly_occurring: _run()
 _move_dir = Input.get_vector("left", "right", "up", "down").normalized()
 var _walk_dir: Vector3
 _walk_dir = Vector3(_move_dir.x, 0, _move_dir.y).rotated(Vector3.UP, %cam_box.rotation.y)
 _walk_vel = _walk_vel.move_toward(_walk_dir * (_move_speed * strafe) * _move_dir.length(), _acceleration * delta)
 $anim_tree.set("parameters/idle_walk_run/blend_position", Vector2((_vel_len) * 0.2, 0))
 if is_in_water:

  self.strafe = clamp(1.0 - abs( %water_ripple.position.y / 4.0), 0.7, 1.0)
  if %ray_water.is_colliding():
   self.water_begin = %ray_water.get_collision_point().y
   %water_ripple.global_position.y = self.water_begin
   %water_ripple_constant.global_position.y = self.water_begin
   if %water_bubbles.global_position.y > water_begin:
    %water_splash.global_position.y = self.water_begin + 0.1
    %water_droplet.global_position.y = self.water_begin
   else:
    %water_droplet.global_position.y = self.global_position.y
    %water_splash.global_position.y = self.global_position.y + 0.1
  if %water_bubbles.global_position.y < water_begin:

   if ! %water_bubbles.emitting:
    %water_bubbles.restart()
    %water_bubbles.emitting = true
    %water_bubble_head.show()

   if ! %water_bubbles_tail.emitting:
    %water_bubbles_tail.restart()
    %water_bubbles_tail.emitting = true
    %water_bubble_tail_box.show()
  else:
   %water_bubbles.emitting = false
   %water_bubbles_tail.emitting = false
   %water_bubble_head.hide()
   %water_bubble_tail_box.hide()
  if velocity:
   %water_ripple.emitting = true
   %water_ripple_constant.emitting = false
  else:
   %water_ripple.emitting = false
   %water_ripple_constant.emitting = true
 else:
  %water_ripple_constant.emitting = false
  %water_ripple.emitting = false
  %water_bubbles.emitting = false
  %water_bubbles_tail.emitting = false
  self.strafe = 1.0
 return _walk_vel
func _run(_invert: bool = false):
 if !game.active_stage.allow_run: return
 if game.active_stage.anomaly_occurring:
  no()
  return
 if velocity && is_on_floor() && !_is_running && !_is_runnig_slow:
  _move_speed = _hurry_speed
  _is_running = true
  _cd_run = true
  await get_tree().create_timer(0.1).timeout
  _cd_run = false
 if _invert:
  _is_running = false
  _move_speed = _walk_speed
  _is_runnig_slow = true
  _cd_run = true
  await get_tree().create_timer(0.1).timeout
  _cd_run = false

func _jump(delta: float) -> Vector3:
 if is_paused or is_on_ceiling(): return Vector3.ZERO
 if _is_jumping:
  if is_on_floor(): _jump_vel = Vector3(0, sqrt(4 * _jump_height * gravity), 0)
  _is_jumping = false
  return _jump_vel
 _jump_vel = Vector3.ZERO if is_on_floor() else _jump_vel.move_toward(Vector3.ZERO, gravity * delta)
 return _jump_vel
func _rotate_camera(_input = Vector2.ZERO, _is_joy: bool = false) -> void :
 if is_paused: return
 if _input is InputEvent: _input = Vector2(_input.relative.x, _input.relative.y)
 var _screen_size_adjust: Vector2 = Vector2.ONE
 if !_is_joy: _screen_size_adjust = Vector2(get_viewport().get_final_transform().get_scale().x, get_viewport().get_final_transform().get_scale().y)
 %cam_box.rotation.x -= (-1.0 if config.cam_invert_y else 1.0) * (_input.y * _screen_size_adjust.x * (config.cam_sens * 0.01))
 %cam_box.rotation.y -= (-1.0 if config.cam_invert_x else 1.0) * (_input.x * _screen_size_adjust.y * (config.cam_sens * 0.01))
 %cam_box.rotation_degrees.x = clamp( %cam_box.rotation_degrees.x, -80, 45)
func _gravity(delta: float) -> Vector3:
 var _final_gravity: float = gravity
 if is_in_water: _final_gravity = gravity / 2.0
 _grav_vel = Vector3.ZERO if is_on_floor() else _grav_vel.move_toward(Vector3(0, velocity.y - _final_gravity, 0), _final_gravity * delta)
 return _grav_vel

var _beneath_ceiling: bool = false
var _ceiling_tween: Tween

var _pawprint_queue: Array
var _step_tween: Tween
func _take_step():
 var _temp_height: float = clamp(_vel_len, 1.6, 5.0)
 var _to_play: Array
 match game.active_stage.weather:
  1:
   if !_beneath_ceiling:
    _to_play.append(game.loadres("step_rain"))
  2, 4:
   _to_play.append(game.loadres("step_snowy"))
 var _pitch: float = randf_range(0.9, 1.1)
 if _is_running: _pitch += 0.2
 if _is_in_air:
  _pitch -= 0.3
  %run_smoke.emitting = true
 if game.active_stage.anomaly_occurring:
  _to_play.append(game.loadres("step_fleshy"))
  _pitch -= 0.5
 if is_in_water:
  _pitch -= %water_ripple.position.y / 2.4
  _to_play.append(game.loadres("step_wet"))
  _to_play.append([game.loadres("step_wet_01"), game.loadres("step_wet_02"), game.loadres("step_wet_03"), game.loadres("step_wet_04"), game.loadres("step_wet_05"), game.loadres("step_wet_06"), game.loadres("step_wet_07"), game.loadres("step_wet_08")])
  _to_play.append(game.loadres("step_rain"))
  if _is_running:
   %water_splash.explosiveness = 0
   %water_splash.emitting = true
  if velocity: %water_droplet.emitting = true
 else:
  _to_play.append(game.loadres("step_regular"))
  match randi_range(0, 110):
   5: if ! %bug_step.emitting: %bug_step.emitting = true
 var _temp_floors: Array
 if %ray_foot.is_colliding():

  if %ray_foot.get_collider().has_meta("extras"):
   _temp_floors.append( %ray_foot.get_collider())
  else:
   _temp_floors.append( %ray_foot.get_collider().get_parent() if %ray_foot.get_collider() is not RigidBody3D else %ray_foot.get_collider())

 for _s in get_slide_collision_count():
  var _sc = get_slide_collision(_s).get_collider() if get_slide_collision(_s).get_collider() is RigidBody3D else get_slide_collision(_s).get_collider().get_parent()

  if _sc not in _temp_floors: _temp_floors.append(_sc)
 for _floor in _temp_floors:
  if _floor.has_meta("extras"):
   if _floor.get_meta("extras") is Dictionary:
    for _n in _floor.get_meta("extras"):
     var _step = game.loadres("step_%s" % _n)
     if _step:
      if _n == "mattress" and !is_on_floor(): game.add_stat("stat_mattress")
      if _n == "fleshy": game.add_stat("stat_meat")
      _to_play.append(_step)
     if "footprint" in _n:
      var _pawprint = game.loadres("pawprint").instantiate()
      game.active_stage.call_deferred("add_child", _pawprint)
      _pawprint.set_deferred("global_position", %ray_foot.get_collision_point())
      _pawprint.set_deferred("global_rotation", chara.global_rotation)
      _pawprint_queue.append(_pawprint)
      if len(_pawprint_queue) > 10:
       var _temp_pawprint = _pawprint_queue.pop_front()
       if is_instance_valid(_temp_pawprint): _temp_pawprint.remove()
 _pitch = clamp(_pitch, 0.4, 2.0)
 if velocity:
  _step_tween = game.tween(_step_tween)
  _step_tween.tween_property(chara, "position:y", 0.02 * _temp_height, 0.5 / _temp_height).set_trans(Tween.TRANS_SINE)
  _step_tween.tween_property(chara, "position:y", 0.0, 0.5 / _temp_height).set_trans(Tween.TRANS_SINE)
 for _a in _to_play:
  var _vol_adjust: float
  if _a is not Array:
   if _a.bpm:
    _vol_adjust = _a.bpm
  elif _a is Array:
   for _x in _a:
    if _x.bpm:
     _vol_adjust = _x.bpm

  if !_cd_step: audio.play_snd_spatial(_a, self.global_position, 16.0, _pitch, clamp(randf_range(2.4, 2.8) - _vol_adjust, 0.0, 5.0))
 game.rumble(0, 0.1, 0.1, 0.05)
 _ceiling_check()
 _cd_step = true
 await get_tree().create_timer(0.1).timeout
 _cd_step = false
func _tween_audio_filter(_value):
 AudioServer.get_bus_effect(5, 0).cutoff_hz = _value
func stop(_freeze: bool = true):
 unconscious = _freeze
 _walk_vel = Vector3.ZERO
 velocity = Vector3.ZERO
 _move_speed = _walk_speed
 $anim_tree.set("parameters/idle_walk_run/blend_position", Vector2.ZERO)
func _ceiling_check():
 $ray_ceiling.force_raycast_update()
 if $ray_ceiling.is_colliding() and !_beneath_ceiling:
  _beneath_ceiling = true
  _ceiling_tween = game.tween(_ceiling_tween)
  _ceiling_tween.tween_method(_tween_audio_filter, 20000, 5000, 0.4).set_trans(Tween.TRANS_SINE)
  AudioServer.set_bus_effect_enabled(5, 0, true)
 elif !$ray_ceiling.is_colliding() and _beneath_ceiling:
   _beneath_ceiling = false
   _ceiling_tween = game.tween(_ceiling_tween)
   await _ceiling_tween.tween_method(_tween_audio_filter, 5000, 20000, 0.3).set_trans(Tween.TRANS_CIRC).finished
   AudioServer.set_bus_effect_enabled(5, 0, false)
 if game.active_stage.weather_height:
  if _beneath_ceiling:
   if self.global_position.y >= game.active_stage.weather_height:
    if game.find("weather"):
     game.find("weather").is_interior(false)
     return
   if game.find("weather"): game.find("weather").is_interior(true)
  else: if game.find("weather"): game.find("weather").is_interior(false)
var _vignette_tween: Tween
func vignette(_in: bool = false):
 _vignette_tween = game.tween(_vignette_tween)
 _vignette_tween.tween_property( %trans_vignette.material, "shader_parameter/alpha", 1.0 * int(_in), 0.8).set_trans(Tween.TRANS_SINE)
 _vignette_tween.tween_property( %trans_saturation.material, "shader_parameter/value", 1.0 * int( !_in) + (0.4 * int(_in)), 1.8).set_trans(Tween.TRANS_SINE)
func change_poi(_node = null):
 if _node:
  %indicator_lookat.target_node = _node.get_path()
  _puppy_excitement_value = 2.0
 else:
  %indicator_lookat.target_node = %indicator_marker.get_path()
  _puppy_excitement_value = 1.0

func _angle_shadow():
 var _blob_shadow_size = snapped(clamp(0.8 - (( %blob_shadow_arm.get_hit_length() - 0.8) / 3.0), 0.4, 0.8), 0.1)
 %blob_shadow.size = Vector3(_blob_shadow_size, 1.0, _blob_shadow_size)
 if get_floor_angle(): %blob_shadow_fix.global_transform = align_with_y( %blob_shadow_fix.global_transform, %ray_foot.get_collision_normal())

func _handle_joypad_camera_rotation(_delta: float) -> void :
 if is_freecam: return
 var joypad_dir: Vector2 = Input.get_vector(&"look_left", &"look_right", &"look_up", &"look_down")
 if joypad_dir.length() > 0: _rotate_camera(joypad_dir * 8.0, true)

func respawn():

 is_paused = true
 stop(true)

 empty_face()
 game.damage_her()
 if game.active_stage.anomaly_occurring:
  game.change_stage("stage_fog")
 else:

  game.change_stage(get_tree().current_scene.scene_file_path)
var _denial: bool = false
var _no_tween: Tween
func no():
 if _denial or is_sitting or _howling: return
 audio.play_snd_spatial(game.loadres("no"), self.global_position, 7.0)
 _denial = true
 _no_tween = game.tween(_no_tween)
 _no_tween.set_loops(2)
 _no_tween.tween_property( %indicator_marker, "position:x", -0.001, 0.2).set_trans(Tween.TRANS_SINE)
 _no_tween.tween_property( %indicator_marker, "position:x", 0.001, 0.1).set_trans(Tween.TRANS_CIRC)
 await _no_tween.finished
 _no_tween = game.tween(_no_tween)
 _no_tween.set_loops(1)
 await _no_tween.tween_property( %indicator_marker, "position:x", 0, 0.1).set_trans(Tween.TRANS_SINE).finished
 _denial = false
func empty_face():
 _head.set_blend_shape_value(7, 0.5)
 _tail.hide()
 match randi_range(0, 5):
  2: _head.hide()
func capsule_rot():
 chara.hide()
 %rotten_capsule.show()
 audio.play_snd_spatial(game.loadres("glitch"), self.global_position, 8.0, -1, 0.8)
 await get_tree().create_timer(randf_range(0.1, 0.8)).timeout
 audio.play_snd_spatial(game.loadres("glitch"), self.global_position, 12.0, -1, 0.8)
 chara.show()
 %rotten_capsule.hide()
func set_rot(_y):
 chara.rotation_degrees.y = _y
 %cam_box.rotation_degrees.y = _y + 180
 _rotate_camera()
func toggle_freecam():
 if _cd_freecam or can_interact or !is_on_floor(): return
 audio.play_snd(game.loadres("toggle_photo_mode"))
 _cd_freecam = true
 is_freecam = !is_freecam
 var _temp_remote_node = self
 if is_freecam:
  _temp_remote_node = %freecam
  await game.find("pause_menu").handle_freecam_anim(is_freecam)
 else:
  game.find("pause_menu").handle_freecam_anim(is_freecam)
 for _reparent in active_remote:
  if _reparent is RemoteTransform3D:
   _reparent.reparent(_temp_remote_node)
   _reparent.position = Vector3.ZERO
   _reparent.rotation = Vector3.ZERO
 %freecam.set_cull_mask_value(19, false)
 if !config.cam_hide_ui: %photo_mode_layer.visible = is_freecam
 %control_hint_smile_howl.visible = !is_sitting
 %freecam.global_position = %view.global_position
 %freecam.global_rotation = %cam_arm.global_rotation
 %freecam.fov = %view.fov
 %freecam.visible = is_freecam
 is_smiling = false
 if !is_freecam:
  if is_sitting: vignette(true)
  await game.trans(false)
 if is_freecam:
  vignette(false)
 _cd_freecam = false
 stop(true)
func _on_plinktimer_timeout() -> void :
 if !is_sitting and _head.get_blend_shape_value(3) == 0.0 and !_howling:
  if !is_paused:
   _head.set_blend_shape_value(0, 0.5)
   audio.play_snd_spatial(game.loadres("blink"), _head.global_position)
  await get_tree().create_timer(0.1).timeout
  _head.set_blend_shape_value(0, 1.0)
  if !is_paused:
   await get_tree().create_timer(randf_range(0.05, 0.4)).timeout
   _head.set_blend_shape_value(0, 0.5)
   await get_tree().create_timer(0.1).timeout
   _head.set_blend_shape_value(0, 0.0)
 $plinktimer.start(randf_range(0, 5.0))
var _head_timer: Tween
func _on_headtimer_timeout() -> void :
 if %indicator_lookat.duration != 2.0: %indicator_lookat.duration = 2.0
 if !is_sitting && !_is_running && !_howling && !_denial && !_is_sequence:
  _head_timer = game.tween(_head_timer)
  await _head_timer.tween_property( %indicator_marker, "position:x", randf_range(-0.004, 0.004), randf_range(0.2, 1.1)).set_trans(Tween.TRANS_QUINT).finished
 else:
  if %indicator_marker.position.x != 0:
   _head_timer = game.tween(_head_timer)
   await _head_timer.tween_property( %indicator_marker, "position:x", 0.0, randf_range(0.2, 1.1)).set_trans(Tween.TRANS_QUINT).finished
 var _time: float = randf_range(0.5, 12.0)
 if game.active_stage.anomaly_occurring: _time = randf_range(0.1, 0.5)
 $headtimer.start(_time)
func _on_eartimer_timeout() -> void :
 $anim_ear_twitch.play("twitch")
 $eartimer.start(randi_range(1, 12))
