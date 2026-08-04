extends Area3D

func _ready() -> void :
 self.set_collision_mask_value(3, true)
 self.set_collision_layer_value(3, true)
 self.body_entered.connect(_on_body_entered)
 self.body_exited.connect(_on_body_exited)
func _on_body_entered(_body: Node3D) -> void :
 if _body is player: _body.submerge()
func _on_body_exited(_body: Node3D) -> void :
 if _body is player:
  _body.submerge(false)
  audio.play_snd_spatial(preload("res://audio/sfx/water_splash_out.ogg"), _body.global_position, 6.0, -1.0, 0.8)
