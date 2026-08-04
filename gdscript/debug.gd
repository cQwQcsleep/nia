extends CanvasLayer

func _ready() -> void :
 if !game.is_debug: self.queue_free()



 var _clipboard_txt: String
 for _stage in DirAccess.get_files_at("res://stage/"):
  if _stage.get_extension() != "tscn": continue
  var _button = Button.new()
  _button.pressed.connect( func():
   game.to_entrance = 0
   game.change_stage(_stage.get_basename())
   self.visible = false
   )
  _button.text = _stage.get_file().replace("stage_", "").replace(".tscn", "")

  _button.tooltip_text = _stage
  %debug_rooms.add_child(_button)











 %room_amount.text = "total rooms: %s" % %debug_rooms.get_child_count()
 if OS.has_feature("web"):
  self.visible = false
 for _x in 10:
  await get_tree().process_frame




func _input(event: InputEvent) -> void :
 if Input.is_action_just_pressed("debug_2"):
  self.visible = !self.visible
  game.capture_mice( !self.visible)
  %debug_rooms.get_child( %debug_rooms.get_child_count() - 1).grab_focus()
 if event is InputEventKey:
  match event.keycode:

   KEY_R:
    _reload()
   KEY_T:
    game.change_stage()
   KEY_L:
    _on_lightning_pressed()
   KEY_U:
    game.nia.position = game.nia.get_node("%freecam").global_position
func _process(_delta: float) -> void :
 var _player_pos: Vector3
 var _can_interact: bool
 var _is_paused: bool
 if game.nia:
  _player_pos = game.nia.global_position
  _can_interact = game.nia.can_interact
  _is_paused = game.nia.is_paused
 %debug_label.text = "\n\t[FPS] %s\n\t[draw calls] %s [tris] %s\n\t[vram usage] %s MB [objects] %s\n\t[player position] %s\n\t[phone battery] %s\n\t[visited] %s\n\t[last_visited] %s\n\t[can_interact] %s\n\t[is_paused] %s\n\t[is_using_gamepad] %s\n\t[transing]\n\t"\
\
\
\
\
\
\
\
\
\
\
\
%[Performance.get_monitor(0), Performance.get_monitor(13), Performance.get_monitor(12), Performance.get_monitor(14) / 1000000, Performance.get_monitor(11), _player_pos, game.battery_status, config.visited, config.last_visited, _can_interact, _is_paused, game.is_using_gamepad]
func _on_button_toggled(toggled_on: bool) -> void :
 get_tree().set_debug_collisions_hint(toggled_on)
 debuginfo("show collision %s" % toggled_on)
 _reload()
func _reload():

 if game.nia:
  _position = game.nia.global_position
  debuginfo("saved position")
 if is_instance_valid(get_tree().current_scene):
  game.change_stage(get_tree().current_scene.scene_file_path)

func _on_show_snd_toggled(toggled_on: bool) -> void :
 audio.show_snd = toggled_on
 debuginfo("visualize sound %s" % toggled_on)
var _position: Vector3
func debuginfo(_text: String):
 %debuginfo.text = _text
 await get_tree().create_timer(2).timeout
 %debuginfo.text = ""
 pass
func _on_save_pos_pressed() -> void :
 if game.nia:
  _position = game.nia.global_position
  debuginfo("saved position")

func _on_load_pos_pressed() -> void :
 if game.nia:
  game.nia.global_position = _position
  debuginfo("loaded position")


func _on_disable_light_toggled(toggled_on: bool) -> void :
 config.disable_all_light = toggled_on
 debuginfo("light %s" % !toggled_on)
 _reload()


func _on_random_event_pressed() -> void :

 if is_instance_valid(get_tree().current_scene): get_tree().current_scene.random_event()
 debuginfo("random event occuring")


func _on_toggle_fog_toggled(toggled_on: bool) -> void :
 for _e in game.active_stage.get_children():
  if _e is WorldEnvironment:
   if _e.environment:
    _e.environment.fog_enabled = toggled_on
 debuginfo("fog %s" % toggled_on)


func _on_transition_pressed() -> void :
 game.trans_id = %transition_id.selected
 await game.trans(true)
 game.trans(false)
 pass


func _on_lang_eng_pressed() -> void :
 TranslationServer.set_locale("en")

func _on_lang_jp_pressed() -> void :
 TranslationServer.set_locale("ja")

func _on_lang_ger_pressed() -> void :
 TranslationServer.set_locale("de")



func _on_reset_config_pressed() -> void :
 config.visited.clear()
 game.apply_config()
 debuginfo("reset config")


func _on_toggle_audio_toggled(toggled_on: bool) -> void :
 config.audio_master_volume = float(toggled_on)
 game.apply_config()
 debuginfo("audio %s" % toggled_on)


func _on_lightning_pressed() -> void :
 if game.find("weather"):
  game.find("weather").lightning()
 pass


func _on_reload_player_pressed() -> void :
 load("res://resource/nia.tscn")
 _reload()


func _on_lang_ru_pressed() -> void :
 TranslationServer.set_locale("ru")


func _on_damage_player_pressed() -> void :
 game.damage_her()


func _on_damage_player_2_pressed() -> void :
 config.unlocked_wallpaper.clear()
 for _debug in len(game.all_wallpaper): config.unlocked_wallpaper.append(_debug)
 game.apply_config()
