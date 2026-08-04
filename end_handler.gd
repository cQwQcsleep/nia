extends Node3D
@export var _train: Node3D
@export var _world: Node3D
@export var _train_distant: Node3D
@export var _fishlings: Node3D
@export var _enviroment: WorldEnvironment
var _train_init_pos: Vector3
var _timer_vibrate: Timer
var _timer_fish: Timer
var _timer_train_bassby: Timer
@export var _nebel: Node3D
@export var _train_wheel_sfx: Array[AudioStream]
func _ready() -> void :
 set_process_input(false)
 _train_distant.hide()
 _train_init_pos = _train.global_position
 _timer_fish = Timer.new()
 _timer_fish.one_shot = true
 _timer_fish.autostart = true
 _timer_fish.timeout.connect(_fish)
 call_deferred("add_child", _timer_fish)
 for _fishling in _fishlings.get_children():
  if _fishling is CPUParticles3D: _fishling.amount = randi_range(8, 32)
 _timer_vibrate = Timer.new()
 _timer_vibrate.one_shot = true
 _timer_vibrate.autostart = true
 _timer_vibrate.timeout.connect(_vibrate)
 call_deferred("add_child", _timer_vibrate)

 _timer_train_bassby = Timer.new()
 _timer_train_bassby.one_shot = true


 _timer_train_bassby.timeout.connect( func():
  return
  _train_distant.show()
  await create_tween().tween_property(_train_distant, "global_position:z", 500.0, 15.0).from(-400.0).finished
  _train_distant.hide()
  _timer_train_bassby.start(randi_range(20, 180))
  pass
  )
 _timer_train_bassby.timeout.emit()
 call_deferred("add_child", _timer_train_bassby)

 await get_tree().process_frame
 if game.find("weather"):
  game.find("weather").lightning_interior = true
func _fish():
 for _fish in _fishlings.get_children():
  if _fish is CPUParticles3D:
   match randi_range(0, 3):
    2: _fish.emitting = true
 _timer_fish.start(randf_range(3.0, 15.0))
func _vibrate():
 audio.play_snd_spatial(game.ran_array(_train_wheel_sfx), game.nia.global_position, 16, -1.0, randf_range(0.1, 0.4), "amb")
 game.rumble(0, randf_range(0.1, 0.2), randf_range(0.1, 0.2), 0.05)
 create_tween().tween_method(_tween_global_shader_param, 0.0, 0.04, 0.1).set_trans(Tween.TRANS_SINE)
 _dim_light()
 await create_tween().tween_property(_train, "global_position:y", _train_init_pos.y + randf_range(0.01, 0.12), randf_range(0.1, 0.3)).set_trans(Tween.TRANS_SINE).finished
 create_tween().tween_method(_tween_global_shader_param, 0.04, 0.0, 0.3).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
 await create_tween().tween_property(_train, "global_position:y", _train_init_pos.y, randf_range(0.1, 0.3)).set_trans(Tween.TRANS_SINE).finished
 _timer_vibrate.start(randf_range(0.1, 3.0))
func _tween_global_shader_param(_value: float):
 RenderingServer.global_shader_parameter_set("end_train_handle_vibration_mult", _value)
func _physics_process(_delta: float) -> void :
 RenderingServer.global_shader_parameter_set("nia_pos", game.nia.global_position)
 %end_outside.position.y = _train.position.y





func _start_final_sequence():
 game.find("pause_menu").process_mode = Node.PROCESS_MODE_DISABLED
 if _has_ended: return
 game.nia.stop(true)
 game.nia.is_paused = true
 game.nia.unconscious = true
 game.nia.sequence = 10
 game.nia._is_sequence = true
 audio.fade_mus()
 DisplayServer.window_request_attention()
 %end_trans_invert.modulate.a = 0.0
 %end_trans_fade.modulate.a = 0.0
 %end_trans_invert.show()
 %end_trans_fade.show()
 create_tween().tween_property( %end_trans_invert, "modulate:a", 1.0, 3.0).set_trans(Tween.TRANS_SINE)
 await create_tween().tween_property( %end_trans_fade, "modulate:a", 1.0, 3.0).set_delay(0.5).finished
 await game.trans(true, false)
 await get_tree().create_timer(3.0).timeout
 game.trans(false, false)
 _nebel.global_position = %sequence_nebel_position.global_position
 _nebel.global_rotation = %sequence_nebel_position.global_rotation
 _nebel._float_freq = 0.0
 game.nia.global_position = %sequence_nia_position.global_position
 game.nia.chara.global_rotation = %sequence_nia_position.global_rotation
 game.nia.sequence = 1
 game.nia.get_node("%water_ripple").emitting = false

 %sequence_cam_anim.play("sequence_00")
 audio.play_snd(preload("res://audio/sfx/title_camera_pan.ogg"), 0.4, 1.4, "Master")
 audio.play_snd(game.loadres("sit_soft"), 1.0, 1.0)

 _nebel.get_node("%amelia_model").rotation = Vector3.ZERO
 _nebel.sequence_playing = true
 _nebel.get_node("%nia_look_at").target_node = _nebel.get_node("%nia_marker").get_path()
 _nebel.get_node("%nia_marker").position = Vector3(-0.236, 1.502, 0.786)
 _nebel.get_node("%anim").play(&"RESET")
 _nebel.get_node("%anim").advance(0)
 _nebel.get_node("%anim").play("sequence_00")
 audio.play_snd(game.loadres("attention_jiggle"), 1.0, 0.4)
 create_tween().tween_property( %end_trans_invert, "modulate:a", 0.0, 2.0).set_trans(Tween.TRANS_SINE)
 await create_tween().tween_property( %end_trans_fade, "modulate:a", 0.0, 8.0).finished
 %sequence_cam_anim.play("sequence_01")
 audio.play_snd(game.ran_array([game.loadres("purr_00"), game.loadres("purr_01")]), -1.0, 0.2)
 audio.fade_mus(true, game.active_stage.bgm_volume)
 await %sequence_cam_anim.animation_finished
 %chapter_two.modulate.a - 0.0
 %chapter_two.show()
 for _x in %chapter_two.get_children():
  create_tween().tween_property(_x, "visible_ratio", 1.0, 3.0).from(0.0).set_trans(Tween.TRANS_SINE)
 create_tween().tween_property( %chapter_two, "visible_ratio", 1.0, 3.0).from(0.0).set_trans(Tween.TRANS_SINE)
 await create_tween().tween_property( %chapter_two, "modulate:a", 1.0, 5.0).from(0.0).set_trans(Tween.TRANS_SINE).finished
 game.capture_mice(false)
 set_process_input(true)

func _end_final_sequence():
 pass
var _has_ended: bool = false
var _exit_sequence: int = 0
func _input(event: InputEvent) -> void :
 if _has_ended: return

 if Input.is_action_just_pressed("interact"):
  _exit_sequence += 1
  create_tween().tween_property( %chapter_two, "scale", Vector2(0.8, 1.6), 0.1).from(Vector2(0.75, 1.55))
  audio.play_key_snd()
  if _exit_sequence >= randi_range(2, 8):
   _has_ended = true

   %end_trans_invert.modulate.a = 0.0
   %end_trans_fade.modulate.a = 0.0
   %end_trans_invert.show()
   %end_trans_fade.show()
   audio.play_snd(preload("res://audio/sfx/start.ogg"), 0.7, 0.1, "Master")
   create_tween().tween_property( %end_trans_invert, "modulate:a", 1.0, 3.0).set_trans(Tween.TRANS_SINE)
   await create_tween().tween_property( %end_trans_fade, "modulate:a", 1.0, 3.0).set_delay(0.5).finished
   await game.trans(true, false)
   await get_tree().create_timer(3.0).timeout
   game.trans(false, false)
   audio.play_snd(game.loadres("sit_soft"), 1.0, 1.0)
   game.nia.is_paused = false
   game.nia.unconscious = false
   game.nia.sequence = 0
   game.nia._is_sequence = false
   game.nia.is_sitting = true
   %sequence_cam.current = false
   _nebel.queue_free()
   %chapter_two.hide()
   create_tween().tween_property( %end_trans_invert, "modulate:a", 0.0, 2.0).set_trans(Tween.TRANS_SINE)
   await create_tween().tween_property( %end_trans_fade, "modulate:a", 0.0, 8.0).finished
   game.find("pause_menu").process_mode = Node.PROCESS_MODE_INHERIT
   %end_layer.queue_free()


 pass
func _on_sequence_trigger_body_entered(body: Node3D) -> void :
 if body is player:

  _start_final_sequence()
  pass

func _on_sequence_trigger_body_exited(_body: Node3D) -> void :
 pass
var _is_dimmed: bool = false
func _dim_light(_dim: float = 0.8, _length: float = 0.0, _dur: float = 0.2):
 if _is_dimmed: return
 _is_dimmed = true
 await create_tween().tween_method(_dim_light_tween, 1.0, _dim, _dur).finished
 if _length: await get_tree().create_timer(_length).timeout
 await create_tween().tween_method(_dim_light_tween, _dim, 1.0, _dur).finished
 _is_dimmed = false

func _dim_light_tween(_value):
 _enviroment.camera_attributes.exposure_multiplier = _value


func _on_button_2_pressed() -> void :
 _dim_light(0.1, 2.0, 1.0)
 pass
