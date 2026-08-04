extends Node3D
@export var _sfx: Array[AudioStream]
var _player_pos
@export var _type: int
@export var _pupil_timer: Timer
@export var _play_blink: bool = true

func _ready() -> void :
 if config.outlived >= 160: self.queue_free()
 set_physics_process( !bool(_type))
 match _type:
  1:
   _pupil_timer = Timer.new()
   _pupil_timer.one_shot = true
   _pupil_timer.autostart = true
   _pupil_timer.timeout.connect(_on_pupil_timer_timeout)
   self.add_child(_pupil_timer)
func _physics_process(_delta: float) -> void :
 _player_pos = game.nia.global_position + Vector3(0, 1, 0)
 self.look_at(_player_pos)

func _on_jitter_timer_timeout() -> void :
 if is_instance_valid($mesh / eye): $mesh / eye.look_at(_player_pos + Vector3(randf_range(-1.4, 1.4), randf_range(-1.4, 1.4), randf_range(-1.4, 1.4)))
 $jitter_timer.start(randf_range(0.1, 2.0))
 audio.play_snd_spatial(game.ran_array(_sfx), self.global_position, 28.0)

func _on_pupil_timer_timeout() -> void :
 match _type:
  1:
   if _play_blink:
    audio.play_snd_spatial(game.ran_array(_sfx), self.global_position, 28.0)
   await create_tween().tween_property($eye, "scale:y", 0.1, 0.2).set_trans(Tween.TRANS_ELASTIC).finished
   await create_tween().tween_property($eye, "scale:y", 1.0, 0.1).set_trans(Tween.TRANS_ELASTIC).finished
  _:
   var _temp_bs = (
   func(_time: float): if is_instance_valid($mesh / eye): $mesh / eye.set_blend_shape_value(0, _time)
   )
   if is_instance_valid($mesh / eye): await create_tween().tween_method(_temp_bs, $mesh / eye.get_blend_shape_value(0), randf_range(-0.8, 1.0), randf_range(0.1, 1.0)).finished

 _pupil_timer.start(randf_range(1.0, 10.0))
func _on_screen_bounds_screen_exited() -> void :
 match randi_range(0, 8):
  4: self.queue_free()
