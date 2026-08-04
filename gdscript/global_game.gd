extends Node

@export var lane: Array[String]
@export var location_nonsense: Array[String]
@export var thunder_sfx: Array[AudioStream]
@export var anomaly_snd_bank_0: Array[AudioStream]
@export var anomaly_snd_bank_1: Array[AudioStream]
@export var anomaly_snd_bank_2: Array[AudioStream]

@export_file("*.tres") var all_wallpaper: Array[String]
var author: String = "lane (emiwa)"
var startup_seed: int = 0
var is_debug: bool = OS.is_debug_build()
var active_stage: stage
var active_stage_light: Color = Color.WHITE
var to_entrance: int = 0

var _temp_config = ConfigFile.new()

var battery_status: int = 100
var new_mail: int = 0
var visited_dreams: Array[int]

var no_tex: Texture2D = PlaceholderTexture2D.new()

var nia: player

@export_file("*.tscn") var _traverse_random: Array[String]

func _init() -> void :
 RenderingServer.set_debug_generate_wireframes(true)

func _ready() -> void :

 _init_steam()
 self.process_mode = Node.PROCESS_MODE_ALWAYS
 var _error = _temp_config.load("user://config.ini")
 if !_error:
  for _key in _temp_config.get_section_keys("setting"):
   config.set(_key, _temp_config.get_value("setting", _key, config.get(_key)))
 if DisplayServer.window_get_current_screen() != config.current_screen: DisplayServer.window_set_current_screen(config.current_screen)
 apply_config()
 get_window().set_min_size(Vector2i(320, 240))
 var _battery_timer = Timer.new()
 _battery_timer.autostart = true
 _battery_timer.wait_time = randf_range(15.0, 80.0)
 _battery_timer.timeout.connect( func():
  battery_status = clamp(battery_status - randi_range(0, 3), 10, 100)
  if find("pause_menu"): find("pause_menu").upd_battery()
  )
 call_deferred("add_child", _battery_timer)

 validate_folder("gallery")
 show_location()
 await _no_render_fix()
 _adjust_window_size()
 for _n in $trans.get_children(): _n.hide()















var steam_api: Object = null
func _init_steam() -> void :
 if Engine.has_singleton("Steam"): steam_api = Engine.get_singleton("Steam")
 else: steam_api = null
func is_steam() -> bool:
 if Engine.has_singleton("Steam"): return true
 return false
func add_stat(_stat: String):
 if game.is_steam():
  steam_api.setStatInt(_stat, steam_api.getStatInt(_stat) + 1)
  steam_api.storeStats()
  print_debug(steam_api.getStatInt(_stat))
var _cd_fullscreen: bool = false
func _input(_event: InputEvent) -> void :
 if _event is not InputEventMouseMotion and _event is not InputEventJoypadMotion:
  if _event is InputEventJoypadButton:
   if !is_using_gamepad:
    is_using_gamepad = true
    input_changed.emit()
    print_debug("Input has been changed to gamepad.")
  else:
   if is_using_gamepad:
    is_using_gamepad = false
    input_changed.emit()
    print_debug("Input has been changed to keyboard.")



 if Input.is_action_just_pressed("screenshot"): screenshot()
 if Input.is_action_just_pressed("screenshot_bad"): screenshot(true)
 if Input.is_action_just_pressed("fullscreen") and !_cd_fullscreen:
  _cd_fullscreen = true
  config.fullscreen = !config.fullscreen
  apply_config()
  await get_tree().create_timer(1.0).timeout
  _cd_fullscreen = false

func close_game():
 if is_instance_valid(active_stage): if active_stage.anomaly_occurring: return
 apply_config()
 if !_game_closing:
  capture_mice(false)
  _game_closing = true
  if nia: nia.empty_face()
  if is_instance_valid(active_stage):
   if active_stage.environment and randi_range(0, 5) == 3:
    active_stage.environment.fog_sky_affect = 0.0
    active_stage.environment.sky = null
    active_stage.environment.background_mode = Environment.BG_COLOR
    active_stage.environment.background_color = Color.BLACK
    active_stage.environment.background_energy_multiplier = 1.0
   corrupt_textures()
  for _tween_clean in get_tree().get_processed_tweens(): _tween_clean.kill()
  get_viewport().scaling_3d_scale = randf_range(0.7, 0.9)

  get_tree().paused = true
  await RenderingServer.frame_post_draw
  RenderingServer.viewport_set_update_mode(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_UPDATE_DISABLED)
  audio.play_snd(loadres("out_of_memory"), -1.0, randf_range(0.2, 0.4))
  await audio.buffer_audio(randi_range(0, 1))
 else: get_tree().quit()
 await get_tree().process_frame
 if OS.has_feature("web"): JavaScriptBridge.eval("window.close()")
 else: get_tree().quit()
func corrupt_textures():
 var _mesh = game.findall_type("MeshInstance3D")
 if _mesh:
  for _n in _mesh:
   for _a in _n.get_surface_override_material_count():
    if _n.get_active_material(_a) is StandardMaterial3D:
     _n.get_active_material(_a).uv1_offset = Vector3(randf_range(-10.0, 10.0), randf_range(-10.0, 10.0), randf_range(-10.0, 10.0))
     _n.get_active_material(_a).uv1_scale = Vector3(randf_range(-2.0, 2.0), randf_range(-2.0, 2.0), randf_range(-2.0, 2.0))
     match randi_range(0, 6):
      2: _n.get_active_material(_a).albedo_texture = no_tex


func reset_game():
 damage_her()
 battery_status = 100
 config.has_ended = false
 config.unlocked_wallpaper = [0, 1]
 config.active_wallpaper = 0
 config.last_visited = ""
 config.visited.clear()
 audio.buffer_audio()
 apply_config()
 if config.outlived >= 320: game.change_stage("stage_fog")
 else: change_stage("title")
 get_window().request_attention()
func rumble(_device: int, _weak_magnitude: float, _strong_magnitude: float, _duration: float = 0):
 if !config.gamepad_use_rumble or !is_using_gamepad: return
 Input.start_joy_vibration(_device, _weak_magnitude, _strong_magnitude, _duration)
func capture_mice(_capture: bool):
 if !get_window().has_focus(): return
 match _capture:
  true: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
  _: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
var trans_id: int = 0
var transing: bool = false
func trans(_in: bool = false, _buffer_audio: bool = true):
 if transing: return
 transing = true
 if _in and _buffer_audio: audio.buffer_audio(randi_range(0, 1))
 var _time_mult = 1.0
 if _is_end: _time_mult = 4.0
 %loading_indicator.show()
 match trans_id:
  1:
   %trans_mosaic.show()
   await create_tween().tween_property( %trans_mosaic.material, "shader_parameter/state", 1 + (78 * int(_in)), 0.6 * _time_mult).from(1 + (78 * int( !_in))).set_trans(Tween.TRANS_SINE).finished
  2:
   %trans_color.modulate.a = 1 * int( !_in)
   %trans_color.show()
   var _a: float = 1.0
   if !_in: _a = -1.0
   for _buffer in range(4):
    %trans_color.modulate.a = %trans_color.modulate.a + (_a * (1.0 / 4.0))
    await get_tree().create_timer(0.08 * _time_mult).timeout
   await get_tree().create_timer(0.4 * _time_mult).timeout
  3:
   %trans_zoom.show()
   await create_tween().tween_property( %trans_zoom.material, "shader_parameter/state", 1.0 + (8.0 * int(_in)), 0.4 * _time_mult).finished










  4:
   %trans_sorting.show()
   await create_tween().tween_property( %trans_sorting.material, "shader_parameter/sort", 3.0 * int(_in), 0.9 * _time_mult).finished
  5:
   %trans_pixel.show()
   await create_tween().tween_property( %trans_pixel.material, "shader_parameter/state", -1.0 + 2.0 * int( !_in), 0.6 * _time_mult).finished
  6:
   %trans_circular.show()
   await create_tween().tween_property( %trans_circular.material, "shader_parameter/state", 1.1 * int( !_in), 0.7 * _time_mult).from(1.1 * int(_in)).set_trans(Tween.TRANS_SINE).finished
  7:
   %trans_invert.show()
   await create_tween().tween_property( %trans_invert, "color:a", 1.0 * int(_in), 0.7 * _time_mult).from(1.0 * int( !_in)).set_trans(Tween.TRANS_SINE).finished





  _:

   var _capture = get_viewport().get_texture().get_image()
   await RenderingServer.frame_post_draw
   %trans_fade.texture = ImageTexture.create_from_image(_capture)
   %trans_fade.show()
 if !_in:
  match trans_id:
   _: await create_tween().tween_property( %trans_fade, "modulate:a", 0.0, 0.7 * _time_mult).from(1.0).set_trans(Tween.TRANS_SINE).finished

  for _n in $trans.get_children(): _n.hide()
  %trans_fade.modulate.a = 1.0

 transing = false









func _no_render_fix():
 get_viewport().scaling_3d_scale = 0.5
 await RenderingServer.frame_post_draw
 get_viewport().transparent_bg = true
 await RenderingServer.frame_post_draw
 get_viewport().transparent_bg = false
 await RenderingServer.frame_post_draw
 get_viewport().scaling_3d_scale = 1.0
 await RenderingServer.frame_post_draw
func _adjust_window_size():
 if !OS.has_feature("web"):
  var _wide: float = (16.0 / 9.0) + (4.0 / 3.0)

  _wide = 640 / _wide

  get_viewport().get_window().size = Vector2(640 + _wide, 480)
signal config_updated
func apply_config():
 match config.widescreen:
  true:
   if get_viewport().content_scale_aspect != 0:
    get_viewport().content_scale_aspect = 0
    _no_render_fix()


    get_viewport().size_changed.emit()







  _:
   if get_viewport().content_scale_aspect != 1:
    get_viewport().content_scale_aspect = 1
    _no_render_fix()







 config.active_wallpaper = clamp(config.active_wallpaper, 0, len(all_wallpaper) - 1)
 AudioServer.set_bus_volume_linear(0, config.audio_master_volume)
 AudioServer.set_bus_volume_linear(2, config.audio_snd_volume)
 AudioServer.set_bus_volume_linear(3, config.audio_mus_volume)
 AudioServer.set_bus_volume_linear(4, config.audio_amb_volume)
 AudioServer.set_bus_volume_linear(6, config.audio_step_volume)
 match config.language:
  1: TranslationServer.set_locale("ja")
  2: TranslationServer.set_locale("de")
  3: TranslationServer.set_locale("ru")
  _: TranslationServer.set_locale("en")
 match config.antialiasing:
  true: if get_viewport().msaa_3d != Viewport.MSAA_2X:
   get_viewport().msaa_3d = Viewport.MSAA_2X
   if game.find("menu_view"): game.find("menu_view").msaa_3d = Viewport.MSAA_2X
  _: if get_viewport().msaa_3d != Viewport.MSAA_DISABLED:
   get_viewport().msaa_3d = Viewport.MSAA_DISABLED
   if game.find("menu_view"): game.find("menu_view").msaa_3d = Viewport.MSAA_DISABLED
 match config.vsync:
  true:

   Engine.max_fps = 0
   DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
  _:
   Engine.max_fps = config.max_framerate
   DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 match config.fullscreen:
  true:

   if DisplayServer.window_get_mode() != 4 and DisplayServer.window_get_mode() == 0 or DisplayServer.window_get_mode() == 2:
    _no_render_fix()
    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

  _:
   if DisplayServer.window_get_mode() == 4:
    _no_render_fix()
    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
    get_window().set_min_size(Vector2i(320, 240))
    _adjust_window_size()
 config.current_screen = DisplayServer.window_get_current_screen()
 if %post_blur.visible != config.screen_filter:
  %post_blur.visible = config.screen_filter
  %post_dither.visible = true
  _no_render_fix()
 for _prop in config.get_script().get_script_property_list(): _temp_config.set_value("setting", _prop.name, config.get(_prop.name))
 _temp_config.save("user://config.ini")
 config_updated.emit()
 if is_debug: print_debug("a change has been made to nophenias configuration.")

func unlock_random_wallpaper():
 var _test = range(len(all_wallpaper))
 _test.shuffle()
 for _a in _test:
  if _a in config.unlocked_wallpaper:
   continue
  config.unlocked_wallpaper.append(_a)
  game.new_mail += 1
  break

var _is_end: bool = false
func change_stage(_stage: String = ""):
 if transing: return
 if !_stage:
  change_stage_rand()
  return
 trans_id = randi_range(0, 7)

 _is_end = true if _stage == "stage_end" else false
 await trans(true)
 await RenderingServer.frame_post_draw
 if !ResourceLoader.exists(_stage): _stage = "res://stage/%s.tscn" % _stage
 get_tree().unload_current_scene()
 var _error = get_tree().change_scene_to_file(_stage)
 if _error: change_stage("stage_title")
 await get_tree().tree_changed
 await get_tree().process_frame
 trans(false)
 show_location()






 if is_instance_valid(active_stage):
  if !active_stage.is_static:
   audio.play_snd(preload("res://audio/sfx/door_shut.ogg"), -1.0, 0.2)
var _location_tween: Tween
var _temp_stage_name: String
func show_location():
 if active_stage:
  if active_stage.stage_name and !active_stage.is_static:
   if active_stage.stage_name == _temp_stage_name: return
   %location.scale.x = 0.6
   if config.language in [1]: %location.scale.x = 0.8
   _temp_stage_name = active_stage.stage_name
   %location.show()

   var _stage_name: String = tr(active_stage.stage_name).replace(" ", "_").to_lower()
   if active_stage.anomaly_occurring:
    _stage_name = "???"
   for _child_name in %location.get_children():
    _child_name.text = "[shake rate=8.0]%s" % _stage_name
    _child_name.add_theme_color_override("font_outline_color", _child_name.get_theme_color("font_outline_color").inverted())
    _child_name.add_theme_color_override("font_shadow_color", _child_name.get_theme_color("font_shadow_color").inverted())
    _child_name.add_theme_color_override("default_color", _child_name.get_theme_color("default_color").inverted())
    %location_gradient.texture.gradient.colors[0] = %location_gradient.texture.gradient.colors[0].inverted()

   _location_tween = tween(_location_tween)
   _location_tween.tween_property( %location, "modulate:a", 1.0, 0.6)
   await _location_tween.tween_property( %location, "modulate:a", 0.0, 2.0).set_delay(5.0).finished

   %location.hide()
   return
 %location.hide()
var _damaging: bool = false
func damage_her():
 if _damaging: return
 get_window().request_attention()
 config.outlived += 1
 config.has_killed_her = true
 loadres("mat_player").next_pass.albedo_color = Color("80131cff")
 if is_instance_valid(nia):
  nia.get_node("%view").fov = 30
  nia.vignette(true)
 _damaging = true
 game.rumble(0, randf_range(0.4, 0.8), randf_range(0.4, 0.8), 0.2)
 %damage_visual.show()
 %damage_visual_overlay.show()
 audio.play_snd(loadres("damage"), -1.0, 0.7)
 audio.play_snd(loadres("nia_damage"), -1.0, 0.1)
 create_tween().tween_property( %damage_visual_overlay, "modulate:a", 0.5, 0.2).from(0)
 await create_tween().tween_property( %damage_visual, "scale:y", 2.8, 0.15).from(0).finished
 create_tween().tween_property( %damage_visual, "scale:y", 0.0, 0.01).set_trans(Tween.TRANS_CIRC)

 await create_tween().tween_property( %damage_visual_overlay, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_CIRC).finished

 %damage_visual_overlay.hide()
 await get_tree().create_timer(1.0).timeout
 _damaging = false



func pos_around_player() -> Vector3:
 if is_instance_valid(nia):
  var _temp_nia = nia
  if nia.is_freecam: _temp_nia.get_node("%freecam")
  var _angle = randf_range(0.0, TAU)
  var _distance = randf_range(20.0, 30.0)
  var _rand_x = _distance * cos(_angle)
  var _rand_y = _temp_nia.global_position.y + randf_range(-2.0, 2.0)
  var _rand_z = _distance * sin(_angle)
  var _offset = Vector3(_rand_x, _rand_y, _rand_z)
  return _temp_nia.global_position + _offset
 return Vector3.ZERO
var _dream_attempt: int = 0
const _max_dream_attempt: int = 128
func change_stage_rand():
 _traverse_random.shuffle()
 to_entrance = 0
 for _n in _traverse_random:
  var _dream = ResourceUID.get_id_path(ResourceUID.text_to_id(_n)).get_file().get_basename()
  if _dream not in config.visited:
   change_stage(_dream)
   return





 config.last_visited = "stage_end"
 _dream_attempt = 0

 change_stage("stage_title")
 get_window().request_attention()












func loadres(_res: String):
 if $resource_preloader.has_resource(_res): return $resource_preloader.get_resource(_res)
func validate_folder(_folder): if !DirAccess.open("user://%s/" % _folder): DirAccess.make_dir_absolute("user://%s/" % _folder)

func screenshot(_lq: bool = false):
 if is_steam(): steam_api.triggerScreenshot()
 var _view = get_viewport().get_texture().get_image()
 validate_folder("gallery")
 var _temp_name: String = "dream"
 if active_stage.stage_name:
  _temp_name = active_stage.stage_name
 var _name: String = "%s_%s.png" % [tr(_temp_name).to_lower().replace(" ", "_"), int(Time.get_unix_time_from_system())]
 var _filename: String = "user://gallery/%s" % _name
 if OS.has_feature("web"):
  if _lq: JavaScriptBridge.download_buffer(_view.save_jpg_to_buffer(randf_range(0.35, 0.4)), _name)
  else: JavaScriptBridge.download_buffer(_view.save_png_to_buffer(), _name)
 else:
  if _lq: _view.save_jpg(_filename, randf_range(0.35, 0.4))
  else: _view.save_png(_filename)

 var _sfx = loadres("screenshot_lq") if _lq else loadres("screenshot")
 audio.play_snd(_sfx, -1.0, 0.5)
 for _temp in 5: await RenderingServer.frame_post_draw
var _screenshot_thread: Thread
func view_screenshots():
 _screenshot_thread = Thread.new()
 _screenshot_thread.start(view_screenshots_thread)
func view_screenshots_thread():
 OS.shell_open(ProjectSettings.globalize_path("user://gallery/"))
 OS.shell_open("steam://open/screenshots/3979330")
func find(_id):
 if get_tree().get_nodes_in_group(_id).size() > 0: return (get_tree().get_nodes_in_group(_id)[0])
 else: return null
func findall(_id) -> Array:
 if get_tree().get_nodes_in_group(_id).size() > 0: return (get_tree().get_nodes_in_group(_id))
 else: return []
func findall_type(_type):
 return get_tree().current_scene.find_children("*", _type)
var _game_closing: bool = false
signal translation_changed
signal focus_changed
signal input_changed
var is_using_gamepad: bool = false
func _notification(_a: int) -> void :
 match _a:
  NOTIFICATION_WM_CLOSE_REQUEST: close_game()
  NOTIFICATION_TRANSLATION_CHANGED: translation_changed.emit()
  NOTIFICATION_APPLICATION_FOCUS_IN: focus_changed.emit()
func mouse_position(): return get_viewport().get_mouse_position().clamp(Vector2.ZERO, get_viewport().get_visible_rect().size)
func tween(_tween: Tween, _create_tween: bool = true):
 if _tween: if _tween.is_running: _tween.kill()
 if _create_tween:
  _tween = create_tween()
  return _tween
func ran_array(_array: Array, _index_only: bool = false):
 if _index_only: return randi_range(0, len(_array) - 1)
 if _array: return _array[randi_range(0, len(_array) - 1)]
func _marry_mio(): return false
