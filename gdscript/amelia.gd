extends Node3D
var _float_time: float
var _float_freq: float = 1.2
var _float_amp: float = 0.2
@export var _mesh_body: MeshInstance3D
@export var _sequence: bool = false
@export var sequence_playing: bool = false
func _ready() -> void :








 set_process_unhandled_input(false)

 await get_tree().process_frame
 if !_sequence:
  if is_instance_valid(game.active_stage):
   if game.active_stage.anomaly_occurring or config.outlived > 400 or randi_range(0, 410) > 6:
    self.queue_free()
func _physics_process(delta: float) -> void :
 if !is_instance_valid( %amelia_model) or !is_instance_valid( %blob_shadow): return
 _float_time += delta
 var _sin = sin(_float_time * _float_freq) * _float_amp
 %amelia_model.position.y = 1.0 + _sin
 if !sequence_playing: %amelia_model.rotation.x = 0.1 + sin(_float_time * _float_freq) * (_float_amp / 4.0)
 %blob_shadow.size = Vector3(1.2 - _sin, 1.0, 1.2 - _sin)

 if game.nia and !sequence_playing:
  if self.global_position.distance_to(game.nia.global_position) < 6.0:
   if ! %nia_look_at.target_node:
    %nia_look_at.target_node = %nia_marker.get_path()
   %nia_marker.global_position = lerp( %nia_marker.global_position, game.nia.global_position + Vector3(0, 1, 0), 0.9 * delta)
  else:
   if %nia_look_at.target_node:
    %nia_look_at.target_node = NodePath("")

  var _angle = atan2( %amelia_model.global_position.x - game.nia.global_position.x, %amelia_model.global_position.z - game.nia.global_position.z)
  %amelia_model.rotation.y = lerp_angle( %amelia_model.rotation.y, _angle + PI, 0.6 * delta)

func _tween_blendshape(_value):
 _mesh_body.set_blend_shape_value(3, _value)
func _on_timer_timeout() -> void :
 await create_tween().tween_method(_tween_blendshape, _mesh_body.get_blend_shape_value(3), randf_range(0.4, 0.9), randf_range(0.5, 2.0)).finished
 %timer.start(randf_range(1.0, 4.0))

func _on_text_trigger_body_entered(body: Node3D) -> void :
 if _im_done or game.nia.is_paused or game.nia.is_freecam or _sequence: return
 if body is player:
  _written = []
  writer("......?")
  game.find("pause_menu").process_mode = Node.PROCESS_MODE_DISABLED
  %writer_enable_timer.start()

var _written: Array[String]
var _speaking: bool = false
var _current_written: int = 0
func writer(_text): _written.append("[shake rate=10.0 level=1 connected=1]%s" % _text)
var _temp_vc: int = 0
var _typer_tween: Tween
var _im_done: bool = false
func _advance_writer():
 if _current_written >= len(_written):
  _im_done = true
  game.unlock_random_wallpaper()
  _on_text_trigger_body_exited(game.nia)
  return
 %control_hint.hide()
 game.nia.vignette(true)
 _speaking = true
 if config.outlived > 180:
  game.nia.respawn()
  self.hide()
 %dialogue_text.text = _written[_current_written]
 %dialogue_text_shadow.text = _written[_current_written]
 _typer_tween = game.tween(_typer_tween)
 await _typer_tween.tween_method(_visualize_dialogue, 0.0, 1.0, len( %dialogue_text.get_parsed_text()) * 0.06).finished
 if !_im_done:
  _end_writer()
func _end_writer():
 if _im_done: return
 _typer_tween.kill()
 %dialogue_text.visible_ratio = 1.0
 %dialogue_text_shadow.visible_ratio = 1.0
 _speaking = false
 %control_hint.show()
 _current_written = (_current_written + 1)
func _visualize_dialogue(_value):
 if _im_done: return
 if %dialogue_text.visible_characters != _temp_vc:
  if _temp_vc == snapped(_temp_vc, 2): audio.play_snd(game.loadres("amelia_talk"), randf_range(1.1, 1.2), 0.3)
 _temp_vc = %dialogue_text.visible_characters
 %dialogue_text.visible_ratio = _value
 %dialogue_text_shadow.visible_ratio = %dialogue_text.visible_ratio
func _unhandled_input(_event: InputEvent) -> void :
 if Input.is_action_just_pressed("interact"):
  if _speaking:
   if %dialogue_text.visible_ratio > 0.2: _end_writer()
  else: _advance_writer()

func _on_text_trigger_body_exited(_body: Node3D) -> void :
 if !is_instance_valid( %writer_enable_timer): return
 %writer_enable_timer.stop()
 %dialogue_layer.hide()
 game.nia.vignette(false)
 if _typer_tween: _typer_tween.kill()
 set_process_unhandled_input(false)
 if game.find("pause_menu"): game.find("pause_menu").process_mode = Node.PROCESS_MODE_INHERIT

func _on_writer_enable_timer_timeout() -> void :
 if _im_done: return
 set_process_unhandled_input(true)
 _advance_writer()
 game.nia.stop()
 %dialogue_layer.show()
 get_window().request_attention()
func _on_visible_on_screen_notifier_3d_screen_exited() -> void :
 if _im_done:
  game.add_stat("stat_nebel")
  $amelia_model / text_trigger.queue_free()
  audio.fade_mus()
  if game.find("weather"): game.find("weather").lightning()
  self.queue_free()
