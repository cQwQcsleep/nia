extends CharacterBody3D
var _moving: bool = false
func _ready() -> void :
 self.queue_free()
 _find_path()
func _physics_process(delta: float) -> void :
 if !$agent.is_target_reached():
  var current_location = global_transform.origin
  var next_location = $agent.get_next_path_position()
  var new_velocity = (next_location - current_location).normalized() * 5.0
  velocity = velocity.move_toward(new_velocity, 0.25)
  move_and_slide()
  $cococnut.look_at(next_location, Vector3.UP)
  $cococnut.rotation.x = 0
func _find_path():
 $agent.target_position = Vector3(randf_range(-13, 13), 0, randf_range(-16, 16))
 $timer.start(randf_range(2.0, 10.0))
 $sfx.stream = preload("res://audio/sfx/amen_break.ogg")
 if !$sfx.playing:
  $sfx.play()
func _on_agent_target_reached() -> void :
 $sfx.stream = preload("res://audio/sfx/amen_break_break.ogg")
 $sfx.play()
