extends Node3D
var _transing: bool = true
func _ready() -> void :
 get_window().request_attention()







 if config.outlived >= 660: %logo.texture = game.no_tex
 if config.outlived >= 720: %stage_overlook.hide()
 create_tween().tween_property( %info_start, "modulate:a", 1.0, 5.0).from(0.0).set_trans(Tween.TRANS_CIRC)
 %trans_fade_invert.modulate.a = 0.8
 %logo.self_modulate.a = 0.0
 %nia.self_modulate.a = 0.0
 var _date: String = "2026"
 var _author: String = game.author
 match randi_range(0, 50):
  2: _date = "2005"
  3: _date = "2007"
  5: _date = "1970"
  6: _date = "2001"
  7: _date = "2022"
  8: %info_start_start.text = "[pulse freq=0.3 color=#ffffff20 ease=-1.0]%s" % tr(game.ran_array(game.location_nonsense)).to_upper()
  10: _author = tr(game.ran_array(game.location_nonsense)).to_lower()
 %info_start_press.text = "[pulse freq=0.3 color=#ffffff20 ease=-1.0]%s " % tr("start_game_notice_00")
 %info_start_start.text = "[pulse freq=0.3 color=#ffffff20 ease=-1.0]%s" % tr("start_game_notice_01")
 %info_start_continue.text = "[pulse freq=0.3 color=#ffffff20 ease=-1.0]  %s" % tr("start_game_notice_03")
 %info_copyright.text = %info_copyright.text.replace("%date", _date).replace("%author", _author).replace("%rights", tr("start_legal"))
 %info_version.text = "v%s" % ProjectSettings.get_setting("application/config/version")
 await RenderingServer.frame_post_draw
 create_tween().tween_property( %nia, "self_modulate:a", 0.0, 2.0).from(0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
 %logo.pivot_offset = %logo.size / 2.0
 %info_copyright.pivot_offset = %info_copyright.size / 2.0
 %info_start.pivot_offset = %info_start.size / 2.0
 audio.play_snd(preload("res://audio/sfx/title_camera_pan.ogg"), 0.6, 1.6, "Master")
 create_tween().tween_property( %trans_fade_invert, "modulate:a", 0.0, 3.0).from(0.8).set_trans(Tween.TRANS_CIRC)
 create_tween().tween_property( %logo, "self_modulate:a", 1.0, 5.0).from(0.0).set_trans(Tween.TRANS_CUBIC)
 await create_tween().tween_property( %scene_cam, "position:y", 0.0, 5.1).from(20.0).set_trans(Tween.TRANS_SINE).finished
 _transing = false
 %trans_fade_invert.hide()
 game.capture_mice(false)
func _unhandled_input(event: InputEvent) -> void :
 %logo_light.global_position = game.mouse_position() + Vector2(0, 64)
 if Input.is_action_just_pressed("interact"): audio.play_key_snd()
 if event is InputEventMouseButton: if event.button_index in [4, 5]: return
 if event is InputEventMouseMotion or _transing or !get_window().has_focus(): return
 if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("right_mouse") or Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("sit") or Input.is_action_just_pressed("howl") or Input.is_action_just_pressed("menu"):
  create_tween().tween_property( %logo, "scale", Vector2(1.0, 1.2), 0.2).from(Vector2(1.1, 1.3)).set_trans(Tween.TRANS_CIRC)
  audio.play_snd(preload("res://audio/sfx/start.ogg"), 1.0, 0.1, "Master")
  game.rumble(0, 0.2, 0.2, 0.2)
  if game.find("weather"): game.find("weather").lightning()
  audio.play_snd(preload("res://audio/sfx/title_camera_pan.ogg"), 0.6, 1.6, "Master")
  _transing = true
  game.capture_mice(true)
  %info_copyright_glow.hide()
  %trans_fade_black.color.a = 0.0
  %trans_fade_black.show()
  create_tween().tween_property( %nia, "self_modulate:a", 0.8, 4.0).set_trans(Tween.TRANS_CIRC)
  create_tween().tween_property( %scene_cam, "fov", 40.0, 5.0).set_trans(Tween.TRANS_SINE)
  create_tween().tween_property( %info_start, "modulate:a", 0.0, 2.0).set_trans(Tween.TRANS_CIRC)
  create_tween().tween_property( %logo, "self_modulate:a", 0.0, 2.0).set_trans(Tween.TRANS_CUBIC)
  create_tween().tween_property( %scene_cam, "position:y", 20.0, 10.0).set_trans(Tween.TRANS_SINE)

  %scene_cam.fov = 91
  if game.find("stage_bgm"):
   create_tween().tween_property(game.find("stage_bgm"), "volume_linear", 0.0, 2.0)
  await get_tree().create_timer(1.0).timeout
  for _fade in 10:
   %trans_fade_black.color.a += 1.0 / 10.0
   await get_tree().create_timer(0.16).timeout
  await get_tree().create_timer(2.0).timeout





  game.change_stage("stage_bedroom")
