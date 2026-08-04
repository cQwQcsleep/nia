extends Node3D
var _is_interior: bool = false
var lightning_interior: bool = false
func _ready() -> void : %thunder.hide()
func _on_thunder_timer_timeout() -> void :
 await lightning()
 match randi_range(0, 3):
  2: await lightning()
 await get_tree().create_timer(randf_range(1.0, 6.0)).timeout
 await audio.play_snd_spatial(game.ran_array(game.thunder_sfx), game.pos_around_player(), randf_range(90.0, 130.0), 1.0, 1.0, "ceiling_fade")
 $thunder_timer.start(randf_range(1.0, 32.0))
func lightning():
 if !lightning_interior:
  if _is_interior: return
 %lightning_particle.emitting = true
 %storm_cloud_particle.emitting = true

 var _time: float = randf_range(0.04, 0.15)
 %thunder.color.a = 0.0
 %thunder.show()
 await create_tween().tween_property( %thunder, "color:a", randf_range(0.1, 0.4), _time).finished
 await create_tween().tween_property( %thunder, "color:a", 0.0, _time).finished
 %thunder.hide()
func is_interior(_state: bool):
 _is_interior = _state
 match _is_interior:
  true:
   $particle.emitting = false
   $rain_ripple.emitting = false
   %rain_feedback.emitting = false
  _:
   $particle.emitting = true
   $rain_ripple.emitting = true
   %rain_feedback.emitting = true
