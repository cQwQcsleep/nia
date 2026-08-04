extends Control

@export var _action: String
@export var _input_action: String
func _ready() -> void :
 set_process_unhandled_input(false)
 if _action:

  %hint_key_info.text = _action
 else: %hint_key_info.hide()
 game.translation_changed.connect( func():
  _size_fix()
  _determine_key()
  )
 game.input_changed.connect( func():
  _size_fix()
  _determine_key()
  )
 _size_fix()
 _determine_key()
func _determine_key():
 for _key in InputMap.action_get_events(_input_action):
  if !game.is_using_gamepad:
   if _key is InputEventKey:
    %hint_key.text = "[pulse freq=0.5 color=#ffffff50 ease=-1.0]%s" % _parse_key(_key)
    %hint_key_outline.text = %hint_key.text
    break
  else:
   if _key is InputEventJoypadButton or _key is InputEventJoypadMotion:
    %hint_key.text = "[pulse freq=0.5 color=#ffffff50 ease=-1.0]%s" % _parse_key(_key)
    %hint_key_outline.text = %hint_key.text
    break


func _size_fix():
 await RenderingServer.frame_post_draw



 %hint_preview.custom_minimum_size.x = 42.0 + %hint_key.get_theme_default_font().get_string_size( %hint_key.get_parsed_text(), 0, -1, 29).x


 self.custom_minimum_size.x = %hint_preview.custom_minimum_size.x
 %hint.pivot_offset = %hint.size / 2.0
 %hint.position.x = - %hint.pivot_offset.x / 2.0
 await RenderingServer.frame_post_draw
 %hint_key_info.position.x = %hint_preview_outline.get_rect().size.x * 0.6


func _on_visibility_changed() -> void :
 set_process_unhandled_input(self.is_visible_in_tree())
 match self.is_visible_in_tree():
  true:
   _size_fix()
   %hint_key.add_theme_color_override("font_outline_color", %hint_key.get_theme_color("font_outline_color").inverted())



   create_tween().tween_property( %hint, "scale", Vector2(0.6, 0.7), 0.4).from(Vector2.ZERO).set_trans(Tween.TRANS_CUBIC)
  _:
   %hint.scale = Vector2.ZERO
   self.modulate.v = 1.0

func _parse_key(_key):
 var _key_name: String
 if !game.is_using_gamepad:
  _key_name = OS.get_keycode_string(_key.keycode)
  match _key_name.to_lower():
   "escape": _key_name = "ESC"
   "control": _key_name = tr("keyboard_ctrl")
   "space": _key_name = tr("keyboard_space")
   "shift": _key_name = tr("keyboard_shift")
 else:

  if _key is InputEventJoypadButton:
   match _key.button_index:
    0: _key_name = "A"
    1: _key_name = "B"
    2: _key_name = "X"
    3: _key_name = "Y"
    4: _key_name = "SELECT"
    6: _key_name = "START"
    9: _key_name = "L1"
    10: _key_name = "R1"
    11: _key_name = tr("keyboard_gamepad_up").to_upper()
    12: _key_name = tr("keyboard_gamepad_down").to_upper()
    13: _key_name = tr("keyboard_gamepad_left").to_upper()
    14: _key_name = tr("keyboard_gamepad_right").to_upper()

  if _key is InputEventJoypadMotion:
   match _key.axis:
    4: _key_name = "L2"
    5: _key_name = "R2"
 return _key_name

func _unhandled_input(_event: InputEvent) -> void :
 if Input.is_action_just_pressed(_input_action):
  audio.play_key_snd()
 if Input.is_action_pressed(_input_action):
  %hint.scale = Vector2(0.5, 0.6)
  self.modulate.v = 0.7
 if Input.is_action_just_released(_input_action):
  %hint.scale = Vector2(0.6, 0.7)
  self.modulate.v = 1.0
