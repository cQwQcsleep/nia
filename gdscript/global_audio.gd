extends Node

var show_snd: bool = false
func _ready() -> void : self.process_mode = Node.PROCESS_MODE_ALWAYS

func play_snd(_sndstream, _pitch: float = -1.0, _volume: float = 1.0, _bus: String = "snd"):
 if !_sndstream: return
 if _sndstream is Array: _sndstream = game.ran_array(_sndstream)
 var _audio_stream = AudioStreamPlayer.new()

 self.add_child(_audio_stream)
 _audio_stream.bus = _bus
 if _pitch == -1.0: _audio_stream.set_pitch_scale(randf_range(0.8, 1.2))
 else: _audio_stream.pitch_scale = _pitch
 _audio_stream.volume_linear = _volume
 _audio_stream.stream = _sndstream
 _audio_stream.play()
 await _audio_stream.finished
 if is_instance_valid(_audio_stream): _audio_stream.queue_free()
func play_snd_spatial(_sndstream, _sndpos: Vector3 = Vector3.ZERO, _dist: float = 4.0, _pitch: float = -1.0, _volume: float = 1.0, _bus: String = "snd"):
 if !_sndstream: return
 if _sndstream is Array: _sndstream = game.ran_array(_sndstream)
 var _audio_stream = AudioStreamPlayer3D.new()
 if game.nia: game.nia.add_child(_audio_stream)
 else: get_tree().current_scene.add_child(_audio_stream)
 _audio_stream.global_position = _sndpos
 _audio_stream.bus = _bus
 _audio_stream.panning_strength = 0.8
 _audio_stream.max_distance = _dist
 _audio_stream.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
 if _pitch == -1.0: _audio_stream.set_pitch_scale(randf_range(0.8, 1.2))
 else: _audio_stream.pitch_scale = _pitch
 _audio_stream.max_db = linear_to_db(_volume)
 _audio_stream.stream = _sndstream
 _audio_stream.play()
 if game.is_debug and show_snd:
  var _debug_sphere = MeshInstance3D.new()
  var _debug_mesh = SphereMesh.new()
  var _debug_text = Label3D.new()
  _debug_text.text = _sndstream.resource_path.get_file()
  _debug_text.position.y = 0.3
  _debug_text.billboard = BaseMaterial3D.BILLBOARD_ENABLED
  _debug_text.no_depth_test = true
  _debug_mesh.radius = 0.2
  _debug_mesh.height = _debug_mesh.radius * 2
  _debug_sphere.mesh = _debug_mesh
  _audio_stream.add_child(_debug_text)
  _audio_stream.add_child(_debug_sphere)
 await _audio_stream.finished
 if is_instance_valid(_audio_stream): _audio_stream.queue_free()
func play_key_snd():
 play_snd([game.loadres("mice_click_00"), game.loadres("mice_click_01")], -1.0, randf_range(0.2, 0.6), "Master")

func fade_mus(_in: bool = false, _volume: float = 1.0):
 var _audio_stream = game.find("stage_bgm")
 if _audio_stream: await create_tween().tween_property(_audio_stream, "volume_linear", _volume * float(_in), 12.0).finished
func buffer_audio(_type: int = 0) -> void :
 var _audio_stream = game.find("stage_bgm")
 if !is_instance_valid(_audio_stream) and is_instance_valid(game.active_stage):
  for _n in game.active_stage.get_children():
   if _n is AudioStreamPlayer3D:
    if _n.bus == &"amb":
     _audio_stream = _n
     break
 if is_instance_valid(_audio_stream):
  _audio_stream.process_mode = Node.PROCESS_MODE_ALWAYS
  match _type:
   1:


    var _temp_audio_stream = [_audio_stream]
    for _amb in game.active_stage.get_children():
      if _amb is AudioStreamPlayer3D:
       _temp_audio_stream.append(_amb)
    for _audio in _temp_audio_stream:
     if is_instance_valid(_audio):
      create_tween().tween_property(_audio, "pitch_scale", 0.0, 3.0)

    await get_tree().create_timer(3.0).timeout
   _:
    var _stream_position = _audio_stream.get_playback_position()
    for a in randi_range(10, 30):
     await get_tree().create_timer(0.1).timeout
     if is_instance_valid(_audio_stream): _audio_stream.play(_stream_position)
