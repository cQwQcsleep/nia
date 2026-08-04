extends Node
class_name stage
@export var is_static: bool = false
@export var stage_name: String = ""
@export var stage_name_alt: String = ""
@export var has_anomaly: bool = true
@export var is_2d: bool = false
var anomaly_occurring: bool = false
var anomaly_monochrome: bool = false
@export var _bloom: float = 0.3
@export_enum("none:0", "suburban:1", "chaos:2") var _extra_snd_bank = 0
var _temp_snd_bank: Array
@export var bgm: AudioStream
@export var bgm_pitch: float = 1.0
@export var bgm_volume: float = 0.5
@export var _has_reverb: bool = false
@export var _entrance: Array[entrance]
@export_enum("none:0", "rain:1", "snow:2", "rain_random:3", "snow_storm:4", "snow_random:5") var weather = 0
@export var weather_height: int = 0
@export var allow_run: bool = true
@export var sit_override: bool = false
@export var respawn_y: int = -10
@export var respawn_random: bool = false
@export var gravity_override: float = 0
@export var _stage_light: Color = Color.WHITE
@export var sequence: int = 0
@export_enum("none:0", "capsule:1", "shooting_star:2") var _special = 0

var _buffer_timer: Timer
var environment: Environment
var _world_env: WorldEnvironment
func _ready() -> void :
 randomize()
 game.active_stage = self
 game.active_stage_light = self._stage_light
 _play_mus()
 get_window().exclude_from_capture = false
 if stage_name_alt:
  match randi_range(0, 8):
   2: stage_name = stage_name_alt
 if is_static:
  game.capture_mice(false)
  return
 for _e in self.get_children(): if _e is WorldEnvironment:
  _world_env = _e
  if _e.environment:
   environment = _e.environment
   break
 if !game.nia:
  var _temp_player = game.loadres("nia").instantiate()

  if gravity_override: _temp_player.gravity = gravity_override

  self.add_child(_temp_player)
  if _entrance:
   var _temp_entrance = _entrance[game.to_entrance % len(_entrance)]
   if _temp_entrance.environment:
    _world_env.environment = _temp_entrance.environment
    environment = _temp_entrance.environment
   if _temp_entrance.stage_light != Color.WHITE:
    game.active_stage_light = _temp_entrance.stage_light
   if _temp_entrance.ignore:
    _temp_entrance.ignore.call_deferred("hide")
    _temp_entrance.ignore.set_deferred("process_mode", PROCESS_MODE_DISABLED)
   _temp_player.set_rot(_temp_entrance.global_rotation_degrees.y)
   _temp_player.global_position = _entrance[game.to_entrance % len(_entrance)].global_position
  else: _temp_player.global_position = Vector3.ZERO
















 _temp_snd_bank = game.anomaly_snd_bank_0.duplicate()
 if _extra_snd_bank: _temp_snd_bank.append_array(game.get("anomaly_snd_bank_%s" % _extra_snd_bank))
 get_viewport().minimize_disabled = false
 if has_anomaly:
  _buffer_timer = Timer.new()
  _buffer_timer.one_shot = true
  _buffer_timer.autostart = true
  _buffer_timer.wait_time = randi_range(1, 24)
  _buffer_timer.timeout.connect(random_event)
  self.call_deferred("add_child", _buffer_timer)
  var _mesh = game.findall_type("MeshInstance3D")
  if config.outlived > 660:
   if game.find("stage_bgm"): game.find("stage_bgm").pitch_scale -= randf_range(0.0, 0.4)
   match randi_range(0, 5):
    1: game.corrupt_textures()
   for _a in clamp(randi_range(1, config.outlived - 660), 0, len(_mesh) / 1.1):
     var _temp_mesh = game.ran_array(_mesh)
     if is_instance_valid(_temp_mesh):
      match randi_range(0, 8):
       3: _temp_mesh.queue_free()
       _: _temp_mesh.hide()
 var _temp_window_title: String = "nophenia"
 match randi_range(0, 64):
  2, 3: _temp_window_title = "n☻︎ph𝙴n✦a"
  4: _temp_window_title = "nophenia (PAL)"
  10: _temp_window_title = "nophenia (NTSC)"
  12: _temp_window_title = tr("apophenia")
 if game._temp_stage_name in ["world_fog", "world_fog_alt"]:
  _temp_window_title = tr("world_fog")
  DisplayServer.window_request_attention()
 if config.outlived >= 511:
  match randi_range(0, 17):
   2: _temp_window_title = tr(game.ran_array(game.location_nonsense)).to_upper()
   _: _temp_window_title = _temp_window_title.md5_text()
 DisplayServer.window_set_title(_temp_window_title)
 match _special:
  1:
   var _special_timer = Timer.new()
   _special_timer.one_shot = true
   _special_timer.autostart = true
   _special_timer.timeout.connect( func():
    game.nia.capsule_rot()
    _special_timer.start(randi_range(1, 20)))
   DisplayServer.window_set_title("New Project (%s)" % randi_range(1, 20))
   self.call_deferred("add_child", _special_timer)
  2:
   self.call_deferred("add_child", game.loadres("anomaly_shooting_star").instantiate())
 if environment and _world_env:
  _world_env.environment.glow_enabled = bool(_bloom)
  _world_env.environment.glow_bloom = _bloom
  if has_anomaly:
   match randi_range(0, 270):

    5, 8, 10:
     get_window().request_attention()
     anomaly_monochrome = true
     _world_env.environment.adjustment_enabled = true
     _world_env.environment.adjustment_saturation = 0.1
     _world_env.environment.adjustment_contrast = 1.1
     _world_env.environment.adjustment_color_correction = null
    15: get_window().request_attention()
    17:
      get_window().request_attention()
      get_window().exclude_from_capture = true
      anomaly_occurring = true
      var _mesh = game.findall_type("MeshInstance3D")
      if _mesh:
       for _n in _mesh:
        _n.material_override = preload("res://gdshader/material/mat_rotten_00.tres")
        _n.material_overlay = null
      _world_env.environment.fog_mode = Environment.FOG_MODE_DEPTH
      _world_env.environment.fog_light_color = "601f26"
      _world_env.environment.fog_depth_begin = 0.0
      _world_env.environment.fog_depth_end = 32.0
      _world_env.environment.adjustment_saturation = 0.4
      _world_env.environment.adjustment_brightness = 0.7
      _world_env.environment.fog_sky_affect = 1.0
      _world_env.environment.adjustment_contrast = 1.1
      _world_env.environment.fog_density = 0.98
      _world_env.environment.adjustment_enabled = true
      _world_env.environment.adjustment_color_correction = game.loadres("rotten_gradient")
      if game.nia: audio.play_snd_spatial(preload("res://audio/amb/heartbeat.ogg"), game.nia.global_position, 16, randf_range(0.4, 0.8))
      for _a in game.findall_type("AudioStreamPlayer3D"): _a.pitch_scale -= 0.3
      _bye()
      await get_tree().process_frame
      if game.find("stage_bgm"): game.find("stage_bgm").pitch_scale -= 0.3
    20:

     get_window().request_attention()
     get_viewport().minimize_disabled = true
     anomaly_occurring = true
     _world_env.environment.fog_enabled = true
     _world_env.environment.fog_light_color = Color.BLACK
     _world_env.environment.fog_depth_begin = 0.0
     _world_env.environment.fog_depth_end = 12.0

     _world_env.environment.fog_sky_affect = 0.0
     _world_env.environment.fog_density = 1.0

     _world_env.environment.background_mode = Environment.BG_SKY
     _world_env.environment.sky = preload("res://resource/sky_eyes.tres")
     _world_env.environment.adjustment_enabled = true
     _world_env.environment.adjustment_contrast = 1.2
     _world_env.environment.adjustment_brightness = 0.5
     _world_env.environment.adjustment_saturation = 0.5
     var _looper = game.tween(create_tween())
     _looper.set_loops(0)
     _looper.tween_property(_world_env.environment.sky.sky_material, "shader_parameter/exposure", 1.0, 6.0).set_trans(Tween.TRANS_SINE)
     _looper.tween_property(_world_env.environment.sky.sky_material, "shader_parameter/exposure", 0.2, 6.0).set_trans(Tween.TRANS_SINE)
     for _amb in game.active_stage.get_children():
      if _amb is AudioStreamPlayer3D:
       _amb.pitch_scale = 0.3
     if game.nia:
      game.nia.empty_face()
      audio.play_snd_spatial(preload("res://audio/amb/heartbeat.ogg"), game.nia.global_position, 12, 0.6)
     DisplayServer.window_set_title("???")
     get_window().exclude_from_capture = true
     _bye()
     await get_tree().process_frame
     if game.find("stage_bgm"): game.find("stage_bgm").pitch_scale = 0.2



    24:
     if game.nia: game.nia.acc_hair_loop.show()
    25:
     if game.nia: game.nia.acc_hair_ribbon.show()
 _handle_weather()




 if _has_reverb:
  AudioServer.set_bus_effect_enabled(2, 0, true)
 else:
  AudioServer.set_bus_effect_enabled(2, 0, false)
 if config.disable_all_light:
  for _a in self.get_children():
   if _a is LightmapGI:
    _a.light_data = null
    break

 if !anomaly_occurring and !anomaly_monochrome:
  var _stage_name: String = self.scene_file_path.get_file().get_basename()
  if _stage_name not in config.visited:
   config.visited.append(_stage_name)
   game.unlock_random_wallpaper()
  if !is_static and !sequence:
   config.last_visited = _stage_name
  game.apply_config()
 await get_tree().process_frame
 for _n in game.findall("stage_lit"):
  if is_instance_valid(_n):
   if _n is MeshInstance3D:
    if _n.get_active_material(0).next_pass:
     _n.get_active_material(0).next_pass.albedo_color = game.active_stage_light
    else:
     if _n.get_active_material(0) is StandardMaterial3D:
      _n.get_active_material(0).albedo_color = game.active_stage_light
   elif _n is CPUParticles3D:
    if _n.is_in_group("stage_lit_particle_color"):
     _n.color = game.active_stage_light
    else:
     if _n.material_override is StandardMaterial3D: _n.material_override.albedo_color = game.active_stage_light
   elif _n is Light3D:
    _n.light_color = game.active_stage_light.lightened(0.4)
   else:
    if _n.get("color"): _n.color = game.active_stage_light
    if _n.get("modulate"): _n.modulate = game.active_stage_light
func _bye():
 await get_tree().create_timer(randi_range(10, 90)).timeout
 await audio.fade_mus()
 game.damage_her()
 get_window().exclude_from_capture = false
 get_viewport().minimize_disabled = false
 game.change_stage("stage_fog")
func _play_mus():
 if !bgm or config.outlived >= 720: return
 var _audio_stream = AudioStreamPlayer.new()
 _audio_stream.stream = bgm
 _audio_stream.pitch_scale = bgm_pitch
 _audio_stream.autoplay = true
 _audio_stream.playback_type = AudioServer.PLAYBACK_TYPE_STREAM

 _audio_stream.bus = "mus"
 _audio_stream.add_to_group("stage_bgm")
 create_tween().tween_property(_audio_stream, "volume_linear", bgm_volume, 2.0).from(0)
 self.call_deferred("add_child", _audio_stream)
func _handle_weather():
 if !game.nia or anomaly_occurring: return
 match weather:
  1:
   var _rain = game.loadres("weather_rain").instantiate()
   add_child(_rain)
  2:
   match randi_range(0, 3):
    2:
     weather = 4
     _handle_weather()
    _:
     var _snow = game.loadres("weather_snow").instantiate()
     add_child(_snow)
  3:
   match randi_range(0, 5):
    2:
     weather = 1
     _handle_weather()
  4:
   var _snow = game.loadres("weather_storm_snow").instantiate()
   add_child(_snow)
  5:
   match randi_range(0, 5):
    2:
     weather = 2
     _handle_weather()
func random_event():
 if anomaly_occurring: return
 match randi_range(0, 12):

  1, 2:
   var _mesh = game.findall_type("MeshInstance3D")
   if _mesh:
    _mesh = game.ran_array(_mesh)
    if _mesh.visible:
     _mesh.hide()
     var _temp_mesh = _mesh.duplicate()
     _temp_mesh.material_override = game.loadres("anomaly_wireframe")

     _temp_mesh.process_mode = Node.PROCESS_MODE_DISABLED
     add_child.call_deferred(_temp_mesh)
     _temp_mesh.show()
     audio.play_snd_spatial(game.loadres("glitch"), game.nia.global_position, 6.0)
     await get_tree().create_timer(randf_range(0.1, 0.7)).timeout

     _temp_mesh.queue_free()
     _mesh.show()

  5: await audio.buffer_audio()
  8: game.nia.capsule_rot()
  _:
   await audio.play_snd_spatial(_temp_snd_bank, game.pos_around_player(), randf_range(40.0, 60.0))










 if is_instance_valid(_buffer_timer): _buffer_timer.start(randi_range(10, 80))
