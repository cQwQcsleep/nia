extends Control
@export var _scroll_box: Control
@export var _is_down: bool
@export var is_horizontal: bool = false
func _ready():
 await get_tree().process_frame
 if !is_horizontal:
  _scroll_box.get_v_scroll_bar().value_changed.connect(_upd_cat_scroll_status)
 else:
  _scroll_box.get_h_scroll_bar().value_changed.connect(_upd_cat_scroll_status)


 _upd_cat_scroll_status()
func _upd_cat_scroll_status(_value: int = 0):
 await RenderingServer.frame_post_draw
 const _offset: int = 28
 game.find("pause_menu").add_ghosting()
 if game.find("pause_menu").get_node("%screen").process_mode != Node.PROCESS_MODE_DISABLED: audio.play_snd(game.loadres("ui_click"), -1.0, 0.1)
 if !is_horizontal:
  if _scroll_box.get_v_scroll_bar().max_value > (_scroll_box.size.y - _offset):
   if _is_down:
    if _scroll_box.get_v_scroll_bar().value + 8 >= _scroll_box.get_v_scroll_bar().max_value - _scroll_box.size.y:
     if self.visible: self.hide()
    else: if !self.visible: self.show()
   else:
    if _scroll_box.get_v_scroll_bar().value > 8:
     if !self.visible:
      self.show()
    else:
     if self.visible:
      self.hide()
  else: if self.visible: self.hide()
 else:
  if _scroll_box.get_h_scroll_bar().max_value > (_scroll_box.size.x - _offset):
   if _is_down:
    if _scroll_box.scroll_horizontal + 12 > _scroll_box.get_h_scroll_bar().max_value - _scroll_box.size.x + _offset:
     if self.visible: self.hide()
    else: if !self.visible: self.show()
   else:
    if _scroll_box.scroll_horizontal > 8:
     if !self.visible:
      self.show()
    else:
     if self.visible:
      self.hide()
  else: if self.visible: self.hide()
