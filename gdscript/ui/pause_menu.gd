extends CanvasLayer

var _is_open: bool = false
var _open_cooldown: bool = false
var _signal_tween: Tween
var _afterimage_tween: Tween
var dreamtime_timer = Timer.new()
var dreamtime: int
@export var _nav_info_left: Label
@export var _nav_info_right: Label
@export var _cam: MeshInstance3D
@export var _cam_screen: MeshInstance3D
@export var _butterfly: MeshInstance3D
var _temp_credits_names: String
func _ready() -> void :
 await get_tree().current_scene.ready
 add_child(dreamtime_timer)
 dreamtime = randi_range(0, 1440)
 dreamtime_timer.wait_time = 4.0
 dreamtime_timer.start()
 dreamtime_timer.connect("timeout", 
 func():
  dreamtime = (dreamtime + randi_range(0, 1)) % 1440
  _upd_time())
 _upd_time()
 _temp_credits_names = %credit_names.text
 game.translation_changed.connect( func():
  _upd_info()
  _upd_time()
  )
 var _butterfly_timer: Timer = Timer.new()
 _butterfly_timer.autostart = true
 _butterfly_timer.one_shot = true
 _butterfly_timer.timeout.connect( func():
  if _butterfly.visible and %screen.process_mode != Node.PROCESS_MODE_DISABLED:
   var _rand_time: Array = [randf_range(0.2, 0.6), randf_range(0.2, 0.6)]
   var _colour_in: Color = Color(0.68, 0.714, 0.85, 1.0)
   var _colour_out: Color = Color(1.0, 1.0, 1.0, 1.0)
   audio.play_snd(game.loadres("butterfly_wing_flap"), randf_range(1.5, 2.4), 0.03)
   create_tween().tween_property(_butterfly.get_active_material(0), "shader_parameter/color2", _colour_in, _rand_time[0]).set_trans(Tween.TRANS_CIRC)
   await create_tween().tween_property(_butterfly.get_active_material(0), "shader_parameter/flock_progress", randf_range(0.1, 0.3), _rand_time[0]).from(0.0).set_trans(Tween.TRANS_SINE).finished
   create_tween().tween_property(_butterfly.get_active_material(0), "shader_parameter/color2", _colour_out, _rand_time[1]).set_trans(Tween.TRANS_CIRC)
   await create_tween().tween_property(_butterfly.get_active_material(0), "shader_parameter/flock_progress", 0.0, _rand_time[1]).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).finished
  _butterfly_timer.start(randf_range(1.0, 3.0))
  )
 self.call_deferred("add_child", _butterfly_timer)
 %screen.set_visibility_layer_bit(0, false)
 if game.active_stage.anomaly_monochrome:
  %menu_view.world_3d.environment.adjustment_saturation = 0.2
  %menu_view.world_3d.environment.adjustment_contrast = 1.2
 else:
  %menu_view.world_3d.environment.adjustment_saturation = 0.9
  %menu_view.world_3d.environment.adjustment_contrast = 1.1
  %menu_view.world_3d.environment.glow_bloom = game.active_stage._bloom
 %menu_view.world_3d.environment.ambient_light_color = game.active_stage_light
 %menu_view.world_3d.environment.ambient_light_color.s = game.active_stage_light.s - 0.1





 if config.outlived > 400:
  var _temp_childs: Array
  _temp_childs.append_array( %phone.get_children())
  _temp_childs.append_array( %screen_view.get_children())
  for _ruin_it in _temp_childs:
   if _ruin_it.has_method("hide"):
    if _ruin_it.visible:
     _ruin_it.visible = bool(randi_range(-1, 1))
 if config.last_visited in ["stage_fog", "stage_bedroom"]: %option_new_save.hide()
 set_physics_process(false)
 %screen.process_mode = Node.PROCESS_MODE_DISABLED
 self.hide()
 %screen.hide()
 _current_wallpaper = config.active_wallpaper
 upd_wallpaper()
func _upd_info():
 %credit_names.text = _temp_credits_names
 %credit_names.scroll_to_line(0)
 %credit_names.text = %credit_names.text.replace("%author", game.author)
 var _temp_supporter: String = tr("credits_dreamers") if randi_range(0, 10) > 5 else tr("credits_dreamers_alt")
 %credit_names.text = %credit_names.text.replace("%credits_everything", tr("credits_everything")).replace("%credits_music", tr("credits_music")).replace("%credits_emotional_support", tr("credits_emotional_support")).replace("%credits_other", tr("credits_other")).replace("%credits_honorable", tr("credits_honorable")).replace("%credits_dreamers", _temp_supporter).replace("%credits_a", tr("credits_a")).replace("%credits_b", tr("credits_b")).replace("%credits_c", tr("credits_c")).replace("%credits_d", tr("credits_d")).replace("%credits_russian", tr("credits_russian")).replace("%credits_german", tr("credits_german")).replace("%credits_japanese", tr("credits_japanese"))
 %credit_names.text = %credit_names.text.replace("%memorial", "[img=90x90]res://texture/charlotte.png[/img]")




 var _temp_total_length: int = len( %credit_names.get_parsed_text())
 match randi_range(0, 12):
  5: _temp_total_length = config.outlived
 %info_length.text = "%s/1" % clamp(_temp_total_length, 0, 999)

func _upd_time():
 var _meridian: String = "PM"
 if dreamtime <= 719: _meridian = "AM"
 var int_time = int(dreamtime)
 var _m = (int_time) % 60
 var _h: int
 match config.language:
  0:
   if ! %meridian.visible: %meridian.show()
   if int_time in range(0, 60): _h = 12
   elif int_time in range(720, 780): _h = 12
   else: _h = (int_time / (60)) % 12
  _:
   if %meridian.visible: %meridian.hide()
   _h = (int_time / (60)) % 24

 var _d: String = "%02d" % _m
 %time.text = "%01d:%02d" % [_h, _m]
 %meridian.text = _meridian
 %time_date.text = tr("phone_date_format").replace("%mm", str(Time.get_date_dict_from_system().month)).replace("%dd", str(Time.get_date_dict_from_system().day))
var _breathe_time: float
func _physics_process(_delta: float) -> void :
 if _is_open:
  if !_open_cooldown:
   var _sens: Vector2 = Vector2(0.008, 0.02)
   var _mouse: Vector2 = game.mouse_position()
   var _phone: Vector2 = %menu_cam.unproject_position( %phone.global_position)
   var _cam_project: Vector2 = %menu_cam.unproject_position(_cam.global_position)
   _breathe_time += _delta
   %menu_cam.v_offset = sin(_breathe_time * 1.2) * (0.2 / 4.0)
   %phone.rotation_degrees = lerp( %phone.rotation_degrees, Vector3((( - _mouse.y) * _sens.y) - _cam_project.y * _sens.y, ((_mouse.x) * _sens.x) - _cam_project.x * _sens.x, 0), 0.2)
   %phone.rotation_degrees.y = clamp( %phone.rotation_degrees.y, -24.0, 24.0)

   _cam.rotation_degrees = lerp(_cam.rotation_degrees, Vector3((( - _mouse.y) * _sens.y) - _phone.y * _sens.y, ((_mouse.x) * _sens.x) - _phone.x * _sens.x, 0), 0.2)
   _cam.rotation_degrees.y = clamp(_cam.rotation_degrees.y, -24.0, 24.0)


   if Input.get_last_mouse_velocity().length() > 2000: _play_keychain_snd(true)
   %phone_light.position.x = %menu_cam.project_position(game.mouse_position(), 10).x
   %screen.scale = Vector2(0.93, 0.92)
   %screen.set_rotation( - %screen_texture.global_rotation.y - deg_to_rad(183))
   %screen.global_position = %menu_cam.unproject_position( %screen_reference.global_position)

func _unhandled_input(_event: InputEvent) -> void :
 if Input.is_action_just_pressed("menu"): _toggle_menu()
func handle_freecam_anim(_open):
 _cam.show()


 %temp_freecam_cam_box.global_position = game.nia.get_node("%view").global_position

 %temp_freecam_cam.global_rotation = game.nia.get_node("%view").global_rotation
 %temp_freecam_cam.fov = game.nia.get_node("%view").fov
 audio.play_snd(game.loadres("swish"), 0.6, 0.4)
 %camera_anim.speed_scale = randf_range(1.1, 1.4)
 match _open:
  true:
   %temp_freecam_view.process_mode = Node.PROCESS_MODE_INHERIT
   %camera_anim.play("open")
   await create_tween().tween_property( %canvas_modulate, "color:a", 0.0, 0.2).set_delay(0.64).finished
   _cam.hide()
  _:
   %temp_freecam_view.process_mode = Node.PROCESS_MODE_DISABLED
   %camera_anim.play_backwards("open")
   create_tween().tween_property( %canvas_modulate, "color:a", 1.0, 0.1)

 pass
func _toggle_menu(_close: bool = false):
 if _open_cooldown or game.nia.is_freecam or !game.nia.is_on_floor(): return
 if game.active_stage.anomaly_occurring:
  game.nia.no()
  return
 _open_cooldown = true
 _is_open = !_is_open

 if _close: _is_open = false

 OS.low_processor_usage_mode = _is_open

 _keychain_cd = false
 _play_keychain_snd()
 game.rumble(0, 0.1, 0.3, 0.2)
 match _is_open:
  true:
   match randi_range(0, 50):
    5: %location_info.text = tr(game.ran_array(game.location_nonsense))
    _:
     if game.active_stage.stage_name:
      if %location_info.get_theme_default_font().get_string_size(tr(game.active_stage.stage_name), 0, -1, 17).x >= 58:
       %location_info.add_theme_font_size_override("font_size", 14)

      %location_info.text = game.active_stage.stage_name
     else: %location_info.text = "???"
   match randi_range(0, 45):
    10: %after_damage.show()
    _:
     if config.outlived < 400: %after_damage.hide()
     else: %after_damage.show()
   match randi_range(0, 2):
    1: _butterfly.show()
    _: _butterfly.hide()
   _visited_screens = [1]
   _current_screen = 0
   game.nia.is_paused = true


   audio.play_snd(game.loadres("phone_open"), -1.0, 0.7)
   change_screen(0)
   upd_battery()
   _upd_option_language()
   _upd_mail()


   %signal_status.text = "phone_searching_signal"

   %no_signal_tower.texture.region.position.y = 12
   _upd_info()
   _adjust_brightness()
   var _temp_tween = ( func(_temp):
    add_ghosting()
    if !game.active_stage.has_anomaly:
     %signal_status.text = "phone_signal_found"
     %no_signal_tower.texture.region.position.y = 24
    else:
     if config.has_killed_her:
      match randi_range(0, 12):
       2: %signal_status.text = "signal_reset_afterthought_alt"
       3: %signal_status.text = "signal_reset_afterthought_alt_002"
       4: %signal_status.text = "signal_reset_afterthought_alt_003"
       5: %signal_status.text = "signal_reset_afterthought_alt_004"
       6: %signal_status.text = "signal_reset_afterthought_alt_005"
       7: %signal_status.text = "signal_reset_afterthought_alt_006"
       8: %signal_status.text = "signal_reset_afterthought_alt_007"
       _: %signal_status.text = "signal_reset_afterthought"
      config.has_killed_her = false

     else:
      match randi_range(0, 88):
       10: %signal_status.text = game.ran_array(game.lane).replace("%s", tr(game.active_stage.stage_name))
       _: %signal_status.text = "phone_no_signal"
     %no_signal_tower.texture.region.position.y = 0)
   _signal_tween = game.tween(_signal_tween)
   _signal_tween.tween_method(_temp_tween, 0.0, 0.0, 0).set_delay(randf_range(3.5, 10.0))
   self.show()
   %screen.show()
   set_physics_process(true)
   %phone_anim.play("clam")
   if game.nia:
    game.nia.vignette(true)
    game.nia.stop()
   %nav_info_right_btn.grab_focus()
   await %phone_anim.animation_finished
   _open_cooldown = false
   %screen.process_mode = Node.PROCESS_MODE_INHERIT
   game.nia.is_paused = true



  _:
   $screen / screen_view.gui_release_focus()
   %phone_anim.play_backwards("clam")

   audio.play_snd(game.loadres("phone_off"), 1.0, 0.7)
   if game.nia:
    if !game.nia.is_sitting: game.nia.vignette(false)
    game.nia.stop(false)
   await %phone_anim.animation_finished
   _open_cooldown = false
   set_physics_process(false)
   %screen.process_mode = Node.PROCESS_MODE_DISABLED

   %screen.hide()
   await get_tree().process_frame
   game.nia.is_paused = false
 game.capture_mice( !_is_open)
var _keychain_cd: bool = false
func _play_keychain_snd(_short: bool = false):
 if _keychain_cd: return
 var _audio = game.loadres("phone_keychain")
 if _short: _audio = game.ran_array([game.loadres("keychain"), game.loadres("keychain_01")])
 _keychain_cd = true
 audio.play_snd(_audio, -1.0, 0.6)
 await get_tree().create_timer(randf_range(0.1, 0.4)).timeout
 _keychain_cd = false
var _battery_deplet: bool = false
func upd_battery():
 if !_is_open or _battery_deplet: return
 %status_battery.value = game.battery_status
 if game.battery_status >= 70: %status_battery.tint_progress = Color("#52859b")
 elif (game.battery_status >= 30 && game.battery_status < 70): %status_battery.tint_progress = Color("#a3b99d")
 else:
  var _deplet_tween = create_tween().set_loops()
  _deplet_tween.tween_property( %status_battery, "modulate:a", 0.1, 0).set_delay(1.0)
  _deplet_tween.tween_property( %status_battery, "modulate:a", 1.0, 0).set_delay(0.5)
  %status_battery.tint_progress = Color("#ce3a40")
  _battery_deplet = true
 add_ghosting()
var _visited_screens: Array[int]
var _current_screen: int = 0
func change_screen(_screen: int):
 var _left_nav_text: String
 var _right_nav_text: String
 var _menu_title: String = ""
 var _screen_node = %menu.get_child(_screen)
 if _screen_node.has_meta("title"): _menu_title = %menu.get_child(_screen).get_meta("title")
 %option_language.hide()

 match _screen:
  1:
   %option_language.show()
   %nav_info_left_btn.disable(true)
  2: %nav_info_left_btn.disable(true)

  0, 8: %nav_info_left_btn.disable(false)
 if _screen_node.has_meta("left_text"):
  _left_nav_text = _screen_node.get_meta("left_text")
 if _screen_node.has_meta("right_text"):
  _right_nav_text = _screen_node.get_meta("right_text")
 %menu_title.text = _menu_title
 for _a in %menu.get_child_count(): %menu.get_child(_a).hide()
 _screen_node.show()
 if (_screen != 0) and (_screen not in _visited_screens):
  _visited_screens.append(_screen)
 _current_screen = _screen
 _nav_info_left.text = _left_nav_text
 _nav_info_right.text = _right_nav_text
 _nav_info_left.tooltip_text = _left_nav_text
 _nav_info_right.tooltip_text = _right_nav_text
 if _screen_node.has_meta("hide_title"):
  %menu_title.hide()
  %static_bg.hide()
 else:
  %menu_title.show()
  %static_bg.show()
 if _screen_node.has_meta("focus"):
  _screen_node.get_node(_screen_node.get_meta("focus")).get_child(0).grab_focus()

  _screen_node.get_node(_screen_node.get_meta("focus")).get_child(-1).focus_neighbor_bottom = %nav_info_right_btn.get_path()
  %nav_info_right_btn.focus_neighbor_top = %nav_info_right_btn.get_path_to(_screen_node.get_node(_screen_node.get_meta("focus")).get_child(-1))


 add_ghosting()
func _on_nav_info_left_btn_pressed() -> void :
 match _current_screen:
  8:
   await _toggle_menu(true)
   if game.nia: game.nia.empty_face()
   if game.find("stage_bgm"): game.find("stage_bgm").pitch_scale = 0.0
   audio.play_snd(preload("res://audio/sfx/delete.ogg"), 1.0, 0.1, "Master")
   game.reset_game()
  _: change_screen(1)

func _on_nav_info_right_btn_pressed() -> void :
 match _current_screen:
  0: _toggle_menu(true)
  1: change_screen(0)
  _:
   _visited_screens.pop_back()
   change_screen(_visited_screens.pop_back())
func upd_wallpaper():
 var _temp_random_wallpaper: int
 if !config.unlocked_wallpaper: return
 if config.active_wallpaper == 0:
  _temp_random_wallpaper = clamp(game.ran_array(config.unlocked_wallpaper), 1, len(game.all_wallpaper))
 else: _temp_random_wallpaper = config.unlocked_wallpaper[_current_wallpaper]
 var _wallpaper: wallpaper = load(game.all_wallpaper[_temp_random_wallpaper])
 %amount_wallpaper.text = "%s / %s" % [_current_wallpaper + 1, len(config.unlocked_wallpaper)]
 if config.active_wallpaper == 0:

  %name_wallpaper.text = "wallpaper_random"
 else:
  %name_wallpaper.text = _wallpaper.name
 if config.outlived >= 555: %bg.texture = game.no_tex
 else: %bg.texture = _wallpaper.texture
 var _accent_colour = _wallpaper.accent_colour
 %static_bg.self_modulate = _accent_colour.darkened(0.5)
 %colored_thing.self_modulate = _accent_colour

 %phone_light.light_color = _accent_colour.lightened(0.1)

 for _n in game.findall("accent_color_backlit"):
  _n.get_active_material(0).backlight_enabled = true
  _n.get_active_material(0).backlight = _accent_colour.inverted()
  _n.get_active_material(0).stencil_color = _accent_colour.inverted()
  _n.get_active_material(0).stencil_color.a = 0.5
  _n.get_active_material(0).stencil_outline_thickness = 0.02
 for _n in game.findall("accent_color"):
  if _n is MeshInstance3D:
   if _n.get_active_material(0) is StandardMaterial3D:
    var _temp_light: Color = game.active_stage_light
    _temp_light.ok_hsl_l = clamp(_temp_light.ok_hsl_l, 0.8, 1.0)


    _n.get_active_material(0).albedo_color = _temp_light

  else: _n.modulate = _accent_colour
 for _n in game.findall("accent_color_invert"): _n.modulate = _accent_colour.inverted()
 var _temp_theme = ThemeDB.get_project_theme()

 _temp_theme.get_stylebox("focus", "Button").modulate_color = _accent_colour.inverted()
 _temp_theme.get_stylebox("scroll", "VScrollBar").modulate_color = _accent_colour

 _temp_theme.get_stylebox("panel", "TooltipPanel").border_color = _accent_colour.inverted()



var _cd_ghosting: bool = false
func add_ghosting():
 if _cd_ghosting: return
 _cd_ghosting = true
 var _capture = ImageTexture.create_from_image( %screen_view.get_texture().get_image())
 %afterimage.texture = _capture
 _afterimage_tween = game.tween(_afterimage_tween)
 create_tween().tween_property( %bg.material, "shader_parameter/saturation", 0.3, 0.4).from(0.6)
 await _afterimage_tween.tween_property( %afterimage, "modulate:a", 0.2, 0.2).from(1.0).set_trans(Tween.TRANS_CUBIC).finished
 _cd_ghosting = false
 _afterimage_tween = game.tween(_afterimage_tween)
 _afterimage_tween.tween_property( %afterimage, "modulate:a", 0.0, randf_range(0.2, 1.0)).set_trans(Tween.TRANS_SINE)
func phone_feedback():
 add_ghosting()
 _play_keychain_snd(true)
 await create_tween().tween_property( %phone, "scale", Vector3.ONE, 0.1).from(Vector3(0.96, 1.02, 1.01)).set_trans(Tween.TRANS_SINE).finished

func _on_option_exitgame_pressed() -> void :
 await _toggle_menu(true)
 game.close_game()

func _on_option_freecam_pressed() -> void :
 _toggle_menu(true)
 game.nia.toggle_freecam()

var _current_wallpaper: int
func _next_wallpaper():
 _cycle_wallpaper(1)
func _last_wallpaper():
 _cycle_wallpaper(-1)
var _cycling: bool = false
func _cycle_wallpaper(_a: int):
 if _cycling: return
 game.new_mail = 0
 _cycling = true
 _current_wallpaper = wrapi(_current_wallpaper + _a, 0, len(config.unlocked_wallpaper))
 config.active_wallpaper = _current_wallpaper
 game.apply_config()
 upd_wallpaper()
 _upd_mail()
 %bg_clip.size.y = 0
 for _n in range(0, randi_range(0, 8)):
  %bg_clip.size.y += randi_range(10, 50)
  await get_tree().create_timer(randf_range(0.01, 0.1)).timeout
 %bg_clip.size.y = 200
 _cycling = false

func _on_credit_names_meta_clicked(meta: Variant) -> void :
 phone_feedback()
 OS.shell_open(meta)

func _on_credit_names_meta_hover_started(meta: Variant) -> void :
 match randi_range(0, 10):
  4: %credit_names.tooltip_text = game.ran_array(game.location_nonsense)
  _: %credit_names.tooltip_text = meta

func _on_option_language_pressed() -> void :
 config.language = (config.language + 1) % 4
 _upd_option_language()
 game.apply_config()

func _upd_option_language():
 %option_language.icon = %option_language.variant[config.language]
 %option_language.upd_preview()
func _upd_mail():
 if game.new_mail: %amount_mail.text = "%s" % clamp(game.new_mail, 1, 99)
 else: %amount_mail.text = ""
 %amount_mail_wallpaper.text = %amount_mail.text
 %amount_mail.add_theme_color_override("font_color", %amount_mail.get_theme_color("font_color").inverted())
 %amount_mail_wallpaper.add_theme_color_override("font_color", %amount_mail_wallpaper.get_theme_color("font_color").inverted())

func _on_kitten_pressed() -> void :
 phone_feedback()
 create_tween().tween_property( %kitten, "scale", Vector2.ONE, 0.1).from(Vector2(randf_range(1.0, 1.3), randf_range(0.3, 0.9)))
 audio.play_key_snd()
 match randi_range(0, 3):
  1: %kitten.flip_h = ! %kitten.flip_h
  2:
   game.add_stat("stat_meow")
   audio.play_snd(game.loadres("meow"), -1.0, randf_range(0.1, 0.3))
  _: audio.play_snd(game.ran_array([game.loadres("purr_00"), game.loadres("purr_01")]), -1.0, randf_range(0.5, 0.8))
 match randi_range(0, 10):
  5: game.nia._howl()
func _on_slider_value_changed(_value: float) -> void :
 await get_tree().process_frame
 _adjust_brightness()
func _adjust_brightness():
 %screen_texture.material_override.emission_energy_multiplier = config.phone_screen_brightness
 _cam_screen.material_override.emission_energy_multiplier = config.phone_screen_brightness
 %phone_light.light_energy = 0.02 + (config.phone_screen_brightness / 2.0)


func _on_credit_names_meta_hover_ended(_meta: Variant) -> void :
 %credit_names.tooltip_text = ""
