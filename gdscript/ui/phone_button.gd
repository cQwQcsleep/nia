extends Button
@export var variant: Array[AtlasTexture]
@export var _variant_text: String
@export var _screen: Control
@export var _is_option: bool = false
@export var _hide_option: bool = false
@export var _is_slider: bool = false
@export var _config_option: String
@export var exclude_steamdeck: bool = false
@export var gamepad_only: bool = false
var _press_cd: bool = false
func _ready() -> void :
 if exclude_steamdeck:
  if game.is_steam():
   if game.steam_api.isSteamRunningOnSteamDeck():
    self.queue_free()
    return
 if gamepad_only:
  if !game.is_using_gamepad:
   self.hide()
  game.input_changed.connect( func():
   if game.is_using_gamepad:
    self.show()
   else:
    if %screen_view.gui_get_focus_owner() == self:
     self.find_valid_focus_neighbor(3).grab_focus()
    self.hide()
   )
 if _variant_text:
  match randi_range(0, 70):
   20:
    self.text = _variant_text
 self.tooltip_text = self.text
 self.focus_entered.connect( func():
  audio.play_snd(game.loadres("phone_keypad_short"), -1.0, 0.5)
  game.find("pause_menu").add_ghosting()
  game.rumble(0, 0.1, 0.1, 0.05)
  self.scale = Vector2(1.01, 1.01)
  _title_size_check()
  %preview_tex.material.set_shader_parameter("invert", true)
  )
 self.focus_exited.connect( func():
  if _display_title_tween:
   _display_title_tween.kill()
   %display_title.position.x = 0
  self.scale = Vector2.ONE
  %preview_tex.material.set_shader_parameter("invert", false)
  )
 self.mouse_entered.connect(self.grab_focus)
 self.mouse_exited.connect(self.release_focus)
 game.translation_changed.connect(
  func():




    _title_size_check())
 upd_preview()
 _title_size_check()
 self.pressed.connect( func():
  if _press_cd: return
  _press_cd = true
  audio.play_snd(game.loadres("phone_keypad_long"), 1.0)
  audio.play_snd(game.loadres("keypad"))
  self.pivot_offset = Vector2(self.size.x / 2, self.size.y / 2)
  create_tween().tween_property(self, "scale", Vector2.ONE, 0.1).from(Vector2(0.9, 0.9))
  if _screen:
   game.find("pause_menu").change_screen(_screen.get_index())
  if _is_option:
   match _config_option:
    "open_snapshots":
     game.view_screenshots()
    _:
     %check_box.button_pressed = ! %check_box.button_pressed
     config.set(_config_option, %check_box.button_pressed)
     game.apply_config()
  if _is_slider:
   %slider_option.show()
   %slider.grab_focus()
   self.custom_minimum_size.y = 42.0
   %display_title.vertical_alignment = VERTICAL_ALIGNMENT_TOP
  await game.find("pause_menu").phone_feedback()
  await get_tree().create_timer(0.1).timeout
  _press_cd = false)
 if _is_option: game.config_updated.connect(_config_adjust)
 _config_adjust()
func _config_adjust():
 if _is_option: if !_hide_option: %check_box.button_pressed = config.get(_config_option)
 if _is_slider:
  %slider.set_value_no_signal(config.get(_config_option) * 100.0)
  %slider_value.text = "%s" % int( %slider.value)
func disable(_state: bool):
 self.disabled = _state
 match _state:
  true:
   self.focus_mode = Control.FOCUS_NONE
   self.modulate.a = 0.8
   self.mouse_filter = Control.MOUSE_FILTER_IGNORE
  _:
   self.focus_mode = Control.FOCUS_ALL
   self.modulate.a = 1.0
   self.mouse_filter = Control.MOUSE_FILTER_STOP
func upd_preview():
 self.mouse_default_cursor_shape = Control.CURSOR_CROSS
 if self.text:
  %display_title.text = self.text
  self.text = ""
 else:
  %display_title.text = ""
  self.text = ""
 %preview_tex.visible = !self._is_option if !_hide_option else true
 if self.icon:
  %preview_tex.texture = self.icon
  self.icon = null
 else: %preview_tex.hide()
 %check_box.visible = self._is_option if !_hide_option else false
var _display_title_tween: Tween
func _title_size_check():
 await RenderingServer.frame_post_draw
 var _size = %display_title.get_theme_default_font().get_string_size(tr( %display_title.text), 0, -1, 17).x

 if _size >= 68 and get_viewport().gui_get_focus_owner() == self:



  %display_title_box.clip_contents = true
  _display_title_tween = game.tween(_display_title_tween).set_loops()
  _display_title_tween.tween_property( %display_title, "position:x", - abs(_size - 52), 1.0).set_delay(0.5)
  _display_title_tween.tween_property( %display_title, "position:x", 0.0, 1.0).set_delay(0.5)

 else:
  if _display_title_tween: _display_title_tween.kill()
  %display_title.position.x = 0
func _on_slider_focus_exited() -> void :
 return
 %slider_option.hide()
 self.custom_minimum_size.y = 19.0
 %display_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
func _on_slider_value_changed(value: float) -> void :
 config.set(_config_option, value / 100.0)
 game.apply_config()
 game.find("pause_menu").phone_feedback()
 var _bus = "snd"




 %slider_value.text = "%s" % int(value)
 if _config_option.begins_with("audio"): _bus = _config_option.split("_")[1]
 audio.play_snd(game.loadres("menu_slider"), -1, 0.6, _bus)
 audio.play_snd(game.loadres("phone_keypad_short"), -1, 0.6, _bus)
func _on_toggled(toggled_on: bool) -> void :
 match toggled_on:
  false:
   %slider_option.hide()
   self.custom_minimum_size.y = 19.0
