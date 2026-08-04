extends Area3D


@export var _door: MeshInstance3D
@export var _shut_sfx: AudioStream
var _close_timer: Timer = Timer.new()
var _is_open: bool = false

func _ready() -> void :
 if !_door: self.queue_free()
 _close_timer.one_shot = true
 _close_timer.autostart = false
 _close_timer.timeout.connect(_toggle_door.bind(true))
 self.call_deferred("add_child", _close_timer)
func _on_body_entered(body: Node3D) -> void :
 if body is player:
  _close_timer.stop()
  _toggle_door()

func _on_body_exited(body: Node3D) -> void :
 if body is player:
  _close_timer.start(randf_range(1.0, 4.0))
var _cd_sfx: bool = false
func _play_sfx(_close: bool = false):
 if _is_open == _close and !_cd_sfx:
  _cd_sfx = true
  audio.play_snd_spatial(_shut_sfx, self.global_position, 24.0, 1.2 - (0.2 * int(_close)), 0.7)
  await get_tree().create_timer(2.0).timeout
  _cd_sfx = false
func _toggle_door(_close: bool = false):

 _play_sfx(_close)
 _is_open = !_close



 if is_instance_valid(_door):
  create_tween().tween_property(_door, "position:x", -1.1 * int( !_close), 0.9).set_ease(Tween.EASE_OUT_IN).set_trans(Tween.TRANS_SINE)
