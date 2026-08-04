extends CanvasLayer
@export var click: Array[AudioStream]
@export var cat_noise: Array[AudioStream]
@export var _cat: Array[Texture]
var _init_x: float
func _ready() -> void :
 audio.play_snd(game.loadres("meow"), -1.0, randf_range(0.5, 0.8), "Master")
 _init_x = $cat.position.x
 %cat.grab_focus()
 audio.play_key_snd()
 %cat.texture_normal = game.ran_array(_cat)
func _on_texture_button_pressed() -> void :
 create_tween().tween_property( %cat, "scale", Vector2(0.7, 0.7), 0.1).from(Vector2(randf_range(1.0, 1.3), randf_range(0.3, 0.9)))
 audio.play_key_snd()
 %cat.texture_normal = game.ran_array(_cat)
 match randi_range(0, 2):
  1: %cat.flip_h = ! %cat.flip_h
  2:
   audio.play_snd(cat_noise, -1.0, randf_range(0.5, 0.8), "Master")
 audio.play_snd(game.loadres("cloth_00"), randf_range(1.1, 1.7), randf_range(0.1, 0.2), "Master")
 if %cat.flip_h: %cat.position.x = _init_x - 24
 else: %cat.position.x = _init_x
 %timer.start(clamp( %timer.time_left + randf_range(0.01, 0.1), 0.0, 5.0))
func _on_timer_timeout() -> void :


 %cat.disabled = true
 create_tween().tween_property( %cat, "modulate:a", 0.0, 0.8)
 create_tween().tween_property( %title, "modulate:a", 1.0, 1.0)
 await get_tree().create_timer(3.0).timeout






 game.change_stage("stage_title")
